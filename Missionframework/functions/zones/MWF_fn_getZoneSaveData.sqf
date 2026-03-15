/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_getZoneSaveData
    Project: Military War Framework

    Description:
    Exports strategic zone state for persistence without runtime-only combat details.
    Strict migration from original fn_getZoneSaveData.sqf.
*/

if (!isServer) exitWith {[]};

private _saveData = [];
private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];

{
    private _zone = _x;

    if (!isNull _zone) then {
        _saveData pushBack [
            toLower (_zone getVariable ["MWF_zoneID", ""]),
            toLower (_zone getVariable ["MWF_zoneOwnerState", "enemy"]),
            _zone getVariable ["MWF_isCaptured", false],
            toLower (_zone getVariable ["MWF_zoneType", "town"])
        ];
    };
} forEach _zones;

_saveData
