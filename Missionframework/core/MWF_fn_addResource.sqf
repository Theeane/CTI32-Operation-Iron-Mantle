/*
    Author: Theane / ChatGPT
    Function: MWF_fn_addResource
    Project: Military War Framework

    Description:
    Authoritative shared economy mutator for Supplies / Intel / Notoriety.
*/

if (!isServer) exitWith {};

params [
    ["_amount", 0, [0]],
    ["_type", "", [""]]
];

private _normalizedType = toUpper _type;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];

switch (_normalizedType) do {
    case "SUPPLIES": {
        _supplies = (_supplies + _amount) max 0;
    };

    case "INTEL": {
        _intel = (_intel + _amount) max 0;
    };

    case "NOTORIETY": {
        _notoriety = 0 max (100 min (_notoriety + _amount));
    };
};

[_supplies, _intel, _notoriety] call MWF_fnc_syncEconomyState;
