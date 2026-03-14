/*
    Author: Theane / ChatGPT
    Function: fn_worldManager
    Project: Military War Framework

    Description:
    Initializes and maintains the world progression layer.
    This system sits above zones and exposes stable outputs for threat and mission systems.

    Notes:
    - Uses dirty flags to avoid unnecessary recalculation spam.
    - Includes a timeout fallback so startup cannot soft-lock forever.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_WorldManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_WorldManagerStarted", true, true];
missionNamespace setVariable ["MWF_WorldSystemReady", false, true];
missionNamespace setVariable ["MWF_WorldStateDirty", true, false];
missionNamespace setVariable ["MWF_WorldLastRecalcAt", -1, false];

[] spawn {
    private _startupDeadline = diag_tickTime + 120;

    waitUntil {
        uiSleep 1;
        (missionNamespace getVariable ["MWF_ZoneSystemReady", false]) ||
        {diag_tickTime >= _startupDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_ZoneSystemReady", false])) then {
        diag_log "[MWF World] Startup timeout waiting for zone system. Continuing with current registry state.";
    };

    [] call MWF_fnc_recalculateWorldState;
    missionNamespace setVariable ["MWF_WorldSystemReady", true, true];

    while {true} do {
        private _dirty = missionNamespace getVariable ["MWF_WorldStateDirty", false];
        private _lastRecalc = missionNamespace getVariable ["MWF_WorldLastRecalcAt", -1];
        private _stale = (_lastRecalc < 0) || {(diag_tickTime - _lastRecalc) >= 30};

        if (_dirty || _stale) then {
            [] call MWF_fnc_recalculateWorldState;
        };

        uiSleep 5;
    };
};
