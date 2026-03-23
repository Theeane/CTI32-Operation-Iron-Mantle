/*
    Author: Theane / ChatGPT
    Function: fn_threatManager
    Project: Military War Framework

    Description:
    Initializes and maintains the threat layer above world progression.

    Notes:
    - Waits for the world layer before becoming authoritative.
    - Uses dirty flags and stale checks instead of constant recalculation.
    - Prunes old incidents to keep network arrays small and Arma-safe.
    - Projects the threat response queue into authoritative zone runtime variables.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ThreatManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_ThreatManagerStarted", true, true];
missionNamespace setVariable ["MWF_ThreatSystemReady", false, true];
missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];
missionNamespace setVariable ["MWF_ThreatLastRecalcAt", -1, false];

[] spawn {
    private _startupDeadline = diag_tickTime + 120;

    waitUntil {
        uiSleep 1;
        (missionNamespace getVariable ["MWF_WorldSystemReady", false]) ||
        {diag_tickTime >= _startupDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) then {
        diag_log "[MWF Threat] Startup timeout waiting for world system. Continuing with current state.";
    };

    [] call MWF_fnc_recalculateThreatState;
    missionNamespace setVariable ["MWF_ThreatSystemReady", true, true];

    while {true} do {
        private _nowServer = serverTime;
        if ((missionNamespace getVariable ["MWF_TierFreeze_Active", false]) && {_nowServer >= (missionNamespace getVariable ["MWF_TierFreeze_EndTime", 0])}) then {
            missionNamespace setVariable ["MWF_TierFreeze_Active", false, true];
            missionNamespace setVariable ["MWF_TierFreeze_EndTime", 0, true];
            missionNamespace setVariable ["MWF_WorldTierProgressBlockedUntil", 0, true];
            missionNamespace setVariable ["MWF_WorldStateDirty", true, false];
        };

        private _lastDecayAt = missionNamespace getVariable ["MWF_ThreatLastDecayAt", -1];
        if (_lastDecayAt < 0) then {
            missionNamespace setVariable ["MWF_ThreatLastDecayAt", diag_tickTime, true];
            _lastDecayAt = diag_tickTime;
        };

        private _elapsed = (diag_tickTime - _lastDecayAt) max 0;
        if (_elapsed >= 5) then {
            private _decayPerMinute = (missionNamespace getVariable ["MWF_ThreatDecayPerMinute", 2]) max 0;
            private _decayAmount = (_decayPerMinute / 60) * _elapsed;
            private _currentThreat = missionNamespace getVariable ["MWF_GlobalThreatPercent", 0];
            private _newThreat = (_currentThreat - _decayAmount) max 0;
            if (abs (_newThreat - _currentThreat) >= 0.05) then {
                missionNamespace setVariable ["MWF_GlobalThreatPercent", _newThreat, true];
                missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];
            };
            missionNamespace setVariable ["MWF_ThreatLastDecayAt", diag_tickTime, true];
        };

        private _hotZones = + (missionNamespace getVariable ["MWF_ThreatHotZones", []]);
        private _prunedHotZones = _hotZones select { (_x param [1, 0, [0]]) > _nowServer };
        if ((count _prunedHotZones) != (count _hotZones)) then {
            missionNamespace setVariable ["MWF_ThreatHotZones", _prunedHotZones, true];
            missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];
        };

        private _incidentLog = + (missionNamespace getVariable ["MWF_ThreatIncidentLog", []]);
        private _beforeCount = count _incidentLog;
        private _now = diag_tickTime;
        _incidentLog = _incidentLog select { (_now - (_x param [0, 0, [0]])) <= 1800 };
        if ((count _incidentLog) != _beforeCount) then {
            missionNamespace setVariable ["MWF_ThreatIncidentLog", _incidentLog, true];
            missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];
        };

        private _dirty = missionNamespace getVariable ["MWF_ThreatStateDirty", false];
        private _lastRecalc = missionNamespace getVariable ["MWF_ThreatLastRecalcAt", -1];
        private _qrfInterval = missionNamespace getVariable ["MWF_ThreatQRFInterval", 900];
        private _staleThreshold = ((_qrfInterval max 240) min 900) / 3;
        private _stale = (_lastRecalc < 0) || {(diag_tickTime - _lastRecalc) >= _staleThreshold};

        if (_dirty || _stale) then {
            [] call MWF_fnc_recalculateThreatState;
        };

        private _queue = missionNamespace getVariable ["MWF_ThreatResponseQueue", []];
        private _queueIndex = createHashMap;
        {
            private _zoneId = toLower (_x getOrDefault ["zoneId", ""]);
            if (_zoneId != "") then {
                _queueIndex set [_zoneId, _x];
            };
        } forEach _queue;

        private _runtimeChanged = false;
        {
            private _zone = _x;
            if (!isNull _zone) then {
                private _zoneId = toLower (_zone getVariable ["MWF_zoneID", ""]);
                private _entry = if (_zoneId != "") then {
                    _queueIndex getOrDefault [_zoneId, createHashMap]
                } else {
                    createHashMap
                };

                if ((count _entry) > 0) then {
                    private _wasQueued = _zone getVariable ["MWF_zoneResponseQueued", false];
                    private _responseType = _entry getOrDefault ["type", ""];
                    private _profile = _entry getOrDefault ["profile", ""];
                    private _priority = _entry getOrDefault ["priority", 0];
                    private _score = _entry getOrDefault ["score", 0];
                    private _nextReadyAt = _zone getVariable ["MWF_zoneNextQRFReadyAt", 0];
                    if (!_wasQueued || {_nextReadyAt <= 0}) then {
                        _nextReadyAt = _nowServer + _qrfInterval;
                    };

                    if (
                        !_wasQueued ||
                        {(_zone getVariable ["MWF_zoneResponseType", ""]) != _responseType} ||
                        {(_zone getVariable ["MWF_zoneResponseProfile", ""]) != _profile} ||
                        {(_zone getVariable ["MWF_zoneResponsePriority", -1]) != _priority} ||
                        {abs ((_zone getVariable ["MWF_zoneResponseScore", -1]) - _score) > 0.01}
                    ) then {
                        _runtimeChanged = true;
                    };

                    _zone setVariable ["MWF_zoneResponseQueued", true, true];
                    _zone setVariable ["MWF_zoneResponseType", _responseType, true];
                    _zone setVariable ["MWF_zoneResponseProfile", _profile, true];
                    _zone setVariable ["MWF_zoneResponsePriority", _priority, true];
                    _zone setVariable ["MWF_zoneResponseScore", _score, true];
                    _zone setVariable ["MWF_zoneNextQRFReadyAt", _nextReadyAt, true];
                } else {
                    if (_zone getVariable ["MWF_zoneResponseQueued", false]) then {
                        _runtimeChanged = true;
                    };

                    _zone setVariable ["MWF_zoneResponseQueued", false, true];
                    _zone setVariable ["MWF_zoneResponseType", "", true];
                    _zone setVariable ["MWF_zoneResponseProfile", "", true];
                    _zone setVariable ["MWF_zoneResponsePriority", 0, true];
                    _zone setVariable ["MWF_zoneResponseScore", 0, true];
                    _zone setVariable ["MWF_zoneNextQRFReadyAt", 0, true];
                };
            };
        } forEach (missionNamespace getVariable ["MWF_all_mission_zones", []]);

        if (_runtimeChanged) then {
            missionNamespace setVariable ["MWF_WorldStateDirty", true, false];
        };

        uiSleep 5;
    };
};
