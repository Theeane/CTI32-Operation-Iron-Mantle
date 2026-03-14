/*
    Author: Theane / ChatGPT
    Function: fn_threatManager
    Project: Military War Framework

    Description:
    Initializes and maintains the threat layer above world progression.

    Notes:
    - Waits for world readiness with timeout fallback.
    - Uses dirty flags to avoid unnecessary recalculation spam.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ThreatManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_ThreatManagerStarted", true, true];
missionNamespace setVariable ["MWF_ThreatSystemReady", false, true];
missionNamespace setVariable ["MWF_ThreatStateDirty", true, false];
missionNamespace setVariable ["MWF_ThreatLastRecalcAt", -1, false];

[] spawn {
    private _startupDeadline = diag_tickTime + 150;

    waitUntil {
        uiSleep 1;
        (missionNamespace getVariable ["MWF_WorldSystemReady", false]) ||
        {diag_tickTime >= _startupDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) then {
        diag_log "[MWF Threat] Startup timeout waiting for world system. Continuing with current world state.";
    };

    [] call MWF_fnc_recalculateThreatState;
    missionNamespace setVariable ["MWF_ThreatSystemReady", true, true];

    while {true} do {
        private _dirty = missionNamespace getVariable ["MWF_ThreatStateDirty", false];
        private _lastRecalc = missionNamespace getVariable ["MWF_ThreatLastRecalcAt", -1];
        private _stale = (_lastRecalc < 0) || {(diag_tickTime - _lastRecalc) >= 20};

        if (_dirty || _stale) then {
            [] call MWF_fnc_recalculateThreatState;
        };

        uiSleep 5;
    };
};
