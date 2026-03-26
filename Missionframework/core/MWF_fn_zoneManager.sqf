/*
    Author: Theane / ChatGPT
    Function: MWF_fn_zoneManager
    Project: Military War Framework

    Description:
    Builds the authoritative zone registry from manual overrides and automatic map generation,
    applies persistence, and starts the zone runtime managers.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_ZoneManagerStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_ZoneManagerStarted", true, true];
missionNamespace setVariable ["MWF_ZoneSystemReady", false, true];
missionNamespace setVariable ["MWF_ZoneManagerStage", "START", true];
missionNamespace setVariable ["MWF_all_mission_zones", [], true];
missionNamespace setVariable ["MWF_ActiveZones", [], true];

private _manualZones = [];
if (!isNil "MWF_fnc_loadManualZones") then {
    missionNamespace setVariable ["MWF_ZoneManagerStage", "LOAD_MANUAL", true];
    _manualZones = [] call MWF_fnc_loadManualZones;
};

private _generatedZones = [];
if (!isNil "MWF_fnc_generateZonesFromMap") then {
    missionNamespace setVariable ["MWF_ZoneManagerStage", "GENERATE_MAP", true];
    _generatedZones = [_manualZones] call MWF_fnc_generateZonesFromMap;
};

missionNamespace setVariable ["MWF_ZoneManagerStage", "REGISTER_ZONES", true];
private _allZones = [];
{
    private _zone = _x;
    if (!isNull _zone) then {
        private _registered = [_zone] call MWF_fnc_registerZone;
        if (!isNull _registered) then {
            _allZones pushBackUnique _registered;
        };
    };
} forEach (_manualZones + _generatedZones);

missionNamespace setVariable ["MWF_all_mission_zones", _allZones, true];
missionNamespace setVariable ["MWF_ActiveZones", _allZones, true];

missionNamespace setVariable ["MWF_ZoneManagerStage", "APPLY_SAVE", true];
private _loadedZoneSaveData = missionNamespace getVariable ["MWF_LoadedZoneSaveData", []];
if !(_loadedZoneSaveData isEqualTo []) then {
    [_loadedZoneSaveData] call MWF_fnc_applyZoneSaveData;
} else {
    [] call MWF_fnc_updateZoneProgression;
};

missionNamespace setVariable ["MWF_ZoneManagerStage", "INIT_ZONES", true];
[] call MWF_fnc_initZones;

if (!isNil "MWF_fnc_zoneHandler") then {
    missionNamespace setVariable ["MWF_ZoneManagerStage", "SPAWN_ZONE_HANDLER", true];
    [] spawn MWF_fnc_zoneHandler;
};

if (!isNil "MWF_fnc_abandonManager") then {
    missionNamespace setVariable ["MWF_ZoneManagerStage", "SPAWN_ABANDON_MANAGER", true];
    [] spawn MWF_fnc_abandonManager;
};

missionNamespace setVariable ["MWF_ZoneSystemReady", true, true];
missionNamespace setVariable ["MWF_ZoneManagerStage", "COMPLETE", true];

diag_log format [
    "[MWF Zones] Zone manager initialized %1 zones. Manual: %2 | Generated: %3 | Runtime started.",
    count _allZones,
    count _manualZones,
    count _generatedZones
];
