/*
    Author: OpenAI
    Function: MWF_fnc_initLoadoutSystem
    Project: Military War Framework

    Description:
    Client-side monitor that grants Virtual Arsenal and Save Respawn Loadout
    access while the player is inside a registered loadout zone.
*/

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["MWF_LoadoutSystemInitialized", false]) exitWith {};
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", true];

[] call MWF_fnc_buildLoadoutCaches;
missionNamespace setVariable ["MWF_SavedRespawnProfile", profileNamespace getVariable ["MWF_SavedRespawnProfile", []]];

[] spawn {
    private _boundPlayer = objNull;

    while {true} do {
        waitUntil { !isNull player };

        if (_boundPlayer != player) then {
            private _oldIds = missionNamespace getVariable ["MWF_LoadoutActionIds", []];
            if (!isNull _boundPlayer) then {
                {
                    _boundPlayer removeAction _x;
                } forEach _oldIds;
            };
            missionNamespace setVariable ["MWF_LoadoutActionIds", []];
            missionNamespace setVariable ["MWF_InLoadoutZone", false];

            _boundPlayer = player;
            [] call MWF_fnc_applyRespawnLoadout;
        };

        private _zones = missionNamespace getVariable ["MWF_LoadoutZones", []];
        if (!isNil "MWF_MOB_LoadoutTrigger") then {
            _zones pushBackUnique MWF_MOB_LoadoutTrigger;
        };
        _zones = _zones select { !isNull _x };

        private _insideZone = false;
        {
            if (player inArea _x) exitWith {
                _insideZone = true;
            };
        } forEach _zones;

        private _phaseAllowsLoadout = (missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]) isEqualTo "OPEN_WAR";
        private _hasActions = !((missionNamespace getVariable ["MWF_LoadoutActionIds", []]) isEqualTo []);

        if (_insideZone && {_phaseAllowsLoadout} && {!_hasActions}) then {
            private _actionIds = [];
            _actionIds pushBack (
                player addAction [
                    "<t color='#00d7ff'>Open Virtual Arsenal</t>",
                    { [] call MWF_fnc_openLoadoutArsenal; },
                    nil,
                    1.5,
                    false,
                    true,
                    "",
                    "alive _target"
                ]
            );

            _actionIds pushBack (
                player addAction [
                    "<t color='#ffaa00'>Save Respawn Loadout</t>",
                    { [] call MWF_fnc_saveRespawnLoadout; },
                    nil,
                    1.4,
                    false,
                    true,
                    "",
                    "alive _target"
                ]
            );

            missionNamespace setVariable ["MWF_LoadoutActionIds", _actionIds];
        };

        if ((!_insideZone || {!_phaseAllowsLoadout}) && {_hasActions}) then {
            {
                player removeAction _x;
            } forEach (missionNamespace getVariable ["MWF_LoadoutActionIds", []]);
            missionNamespace setVariable ["MWF_LoadoutActionIds", []];
        };

        missionNamespace setVariable ["MWF_InLoadoutZone", _insideZone];
        uiSleep 1;
    };
};
