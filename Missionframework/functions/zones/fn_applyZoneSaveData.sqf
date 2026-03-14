/*
    Author: Theane / ChatGPT
    Function: fn_applyZoneSaveData
    Project: Military War Framework

    Description:
    Applies persisted strategic zone state to the current runtime zone registry.
*/

if (!isServer) exitWith {};

params [
    ["_saveData", [], [[]]]
];

if (_saveData isEqualTo []) exitWith {};

private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];

{
    private _entry = _x;
    _entry params [
        ["_zoneId", "", [""]],
        ["_ownerState", "enemy", [""]],
        ["_isCaptured", false, [false]],
        ["_zoneType", "town", [""]]
    ];

    private _zoneIndex = _zones findIf { !isNull _x && { toLower (_x getVariable ["MWF_zoneID", ""]) isEqualTo toLower _zoneId } };

    if (_zoneIndex >= 0) then {
        private _zone = _zones select _zoneIndex;
        _zone setVariable ["MWF_zoneType", toLower _zoneType, true];
        _zone setVariable ["MWF_zoneOwnerState", toLower _ownerState, true];
        _zone setVariable ["MWF_isCaptured", _isCaptured, true];
        _zone setVariable ["MWF_underAttack", false, true];
        _zone setVariable ["MWF_contested", false, true];
        _zone setVariable ["MWF_capProgress", if (_isCaptured) then {100} else {0}, true];

        if (!isNil "MWF_fnc_syncZoneMarker") then {
            [_zone] call MWF_fnc_syncZoneMarker;
        };
    };
} forEach _saveData;

if (!isNil "MWF_fnc_updateZoneProgression") then {
    [] call MWF_fnc_updateZoneProgression;
};
