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
        missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
        missionNamespace setVariable ["MWF_Supplies", _supplies, true];
    };

    case "INTEL": {
        _intel = (_intel + _amount) max 0;
        missionNamespace setVariable ["MWF_res_intel", _intel, true];
        missionNamespace setVariable ["MWF_Intel", _intel, true];
    };

    case "NOTORIETY": {
        _notoriety = 0 max (100 min (_notoriety + _amount));
        missionNamespace setVariable ["MWF_res_notoriety", _notoriety, true];
    };
};

missionNamespace setVariable ["MWF_Supply", _supplies, true];
missionNamespace setVariable ["MWF_Currency", _supplies + _intel, true];

remoteExec ["MWF_fnc_updateResourceUI", 0];

if (!isNil "MWF_fnc_requestDelayedSave") then {
    [] call MWF_fnc_requestDelayedSave;
};
