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

        uiSleep 5;
    };
};
