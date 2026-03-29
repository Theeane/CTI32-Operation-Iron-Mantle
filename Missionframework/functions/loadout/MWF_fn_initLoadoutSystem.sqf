/*
    Author: Theane / OpenAI
    Function: MWF_fnc_initLoadoutSystem
    Project: Military War Framework

    Description:
    Client-side monitor that manages only the loadout interactions when inside
    registered loadout zones. HUD rendering is handled by MWF_fnc_updateResourceUI.
*/

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["MWF_LoadoutSystemInitialized", false]) exitWith {};
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", true];

[] call MWF_fnc_buildLoadoutCaches;

private _savedProfile = profileNamespace getVariable ["MWF_SavedRespawnProfile", []];
missionNamespace setVariable ["MWF_SavedRespawnProfile", _savedProfile];

[] spawn {
    private _boundPlayer = objNull;

    while {hasInterface} do {
        waitUntil {
            uiSleep 0.25;
            !isNull player
        };

        if (_boundPlayer != player) then {
            private _oldIds = missionNamespace getVariable ["MWF_LoadoutActionIds", []];
            if (!isNull _boundPlayer) then {
                { _boundPlayer removeAction _x; } forEach _oldIds;
            };
            missionNamespace setVariable ["MWF_LoadoutActionIds", []];
            _boundPlayer = player;
        };

        private _zones = missionNamespace getVariable ["MWF_LoadoutZones", []];
        private _insideZone = false;

        {
            if (!isNull _x && {player inArea _x}) exitWith { _insideZone = true; };
        } forEach _zones;

        if (_insideZone) then {
            private _hasActions = !((missionNamespace getVariable ["MWF_LoadoutActionIds", []]) isEqualTo []);
            if (!_hasActions) then {
                private _actionIds = [];

                _actionIds pushBack (player addAction [
                    "<t color='#00d7ff'>Open Virtual Arsenal</t>",
                    { [] call MWF_fnc_openLoadoutArsenal; },
                    nil, 1.5, false, true, "", "alive _target"
                ]);

                _actionIds pushBack (player addAction [
                    "<t color='#ffaa00'>Save Respawn Loadout</t>",
                    { [] call MWF_fnc_saveRespawnLoadout; },
                    nil, 1.4, false, true, "", "alive _target"
                ]);

                missionNamespace setVariable ["MWF_LoadoutActionIds", _actionIds];
            };
        } else {
            private _currentActionIds = missionNamespace getVariable ["MWF_LoadoutActionIds", []];
            if (_currentActionIds isNotEqualTo []) then {
                { player removeAction _x; } forEach _currentActionIds;
                missionNamespace setVariable ["MWF_LoadoutActionIds", []];
            };
        };

        missionNamespace setVariable ["MWF_InLoadoutZone", _insideZone];
        uiSleep 0.5;
    };
};

diag_log "[MWF] Loadout System Monitor: Initialized (actions only).";
