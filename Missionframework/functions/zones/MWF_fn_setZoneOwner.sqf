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

    if (!isNil "MWF_fnc_applyMissionImpact") then {
        private _zoneThreatDelta = switch (_zoneType) do {
            case "capital": { 10 };
            case "factory": { 8 };
            case "military": { 9 };
            default { 6 };
        };
        private _zoneTierDelta = switch (_zoneType) do {
            case "capital": { 20 };
            case "factory": { 14 };
            case "military": { 16 };
            default { 10 };
        };
        private _profile = createHashMapFromArray [
            ["kind", "world"],
            ["id", format ["zone_capture_%1", _zoneType]],
            ["threatDelta", _zoneThreatDelta],
            ["tierDelta", _zoneTierDelta],
            ["supplies", 0],
            ["intel", 0],
            ["fallbackSupplies", 0],
            ["fallbackIntel", 0]
        ];
        [_profile, createHashMapFromArray [["zoneId", toLower (_zone getVariable ["MWF_zoneID", ""])], ["loud", true]]] call MWF_fnc_applyMissionImpact;
    };

    [format ["%1 secured. %2", _zoneName, _reason]] remoteExec ["systemChat", 0];
};

if ((_newOwner isEqualTo "enemy") && !(_previousOwner isEqualTo "enemy")) then {
    if (!isNil "MWF_fnc_applyMissionImpact") then {
        private _profile = createHashMapFromArray [
            ["kind", "world"],
            ["id", format ["zone_loss_%1", _zoneType]],
            ["threatDelta", -4],
            ["tierDelta", -8],
            ["supplies", 0],
            ["intel", 0],
            ["fallbackSupplies", 0],
            ["fallbackIntel", 0]
        ];
        [_profile, createHashMapFromArray [["zoneId", toLower (_zone getVariable ["MWF_zoneID", ""])], ["loud", true]]] call MWF_fnc_applyMissionImpact;
    };
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
