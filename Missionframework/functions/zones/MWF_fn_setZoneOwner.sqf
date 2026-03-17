/*
    Author: Theane / ChatGPT
    Function: fn_setZoneOwner
    Project: Military War Framework

    Description:
    Applies a strategic ownership change to a zone, updates rewards, progression, and marker state.
*/

if (!isServer) exitWith {};

params [
    ["_zone", objNull, [objNull]],
    ["_ownerState", "enemy", [""]],
    ["_reason", "", [""]]
];

if (isNull _zone) exitWith {};

private _previousOwner = toLower (_zone getVariable ["MWF_zoneOwnerState", "enemy"]);
private _newOwner = toLower _ownerState;
private _zoneType = toLower (_zone getVariable ["MWF_zoneType", "town"]);
private _zoneName = _zone getVariable ["MWF_zoneName", "Unknown Zone"];

_zone setVariable ["MWF_zoneOwnerState", _newOwner, true];
_zone setVariable ["MWF_isCaptured", _newOwner isEqualTo "player", true];
_zone setVariable ["MWF_underAttack", false, true];
_zone setVariable ["MWF_contested", false, true];
_zone setVariable ["MWF_capProgress", if (_newOwner isEqualTo "player") then {100} else {0}, true];

if ((_newOwner isEqualTo "player") && !(_previousOwner isEqualTo "player")) then {
    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
    private _intel = missionNamespace getVariable ["MWF_res_intel", 0];
    private _civRep = missionNamespace getVariable ["MWF_CivRep", 0];

    switch (_zoneType) do {
        case "capital": {
            _supplies = _supplies + 150;
            _civRep = _civRep + 2;
        };
        case "factory": {
            _supplies = _supplies + 200;
        };
        case "military": {
            _intel = _intel + 10;
        };
        default {
            _supplies = _supplies + 100;
            _civRep = _civRep + 1;
        };
    };

    private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
    [_supplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
    missionNamespace setVariable ["MWF_CivRep", _civRep, true];

    [format ["%1 secured. %2", _zoneName, _reason]] remoteExec ["systemChat", 0];
};

if ((_newOwner isEqualTo "enemy") && !(_previousOwner isEqualTo "enemy")) then {
    [format ["%1 lost. %2", _zoneName, _reason]] remoteExec ["systemChat", 0];
};

if (!isNil "MWF_fnc_syncZoneMarker") then {
    [_zone] call MWF_fnc_syncZoneMarker;
};

if (!isNil "MWF_fnc_updateZoneProgression") then {
    [] call MWF_fnc_updateZoneProgression;
};

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};
