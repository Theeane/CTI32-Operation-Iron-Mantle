/*
    Author: OpenAI
    Function: MWF_fnc_clientApplyEconomyState
    Project: Military War Framework

    Description:
    Client-side authoritative economy mirror update for HUD refresh.
    Used when the server changes economy state and the public namespace
    replication is too slow for immediate visual feedback.
*/

if (!hasInterface) exitWith { false };

params [
    ["_supplies", -1, [0]],
    ["_intel", -1, [0]],
    ["_notoriety", -1, [0]]
];

if (_supplies >= 0) then {
    missionNamespace setVariable ["MWF_Economy_Supplies", _supplies];
    missionNamespace setVariable ["MWF_Supplies", _supplies];
    missionNamespace setVariable ["MWF_Supply", _supplies];
};

if (_intel >= 0) then {
    missionNamespace setVariable ["MWF_res_intel", _intel];
    missionNamespace setVariable ["MWF_Intel", _intel];
};

if (_notoriety >= 0) then {
    missionNamespace setVariable ["MWF_res_notoriety", _notoriety];
};

private _resolvedSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _resolvedIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
missionNamespace setVariable ["MWF_Currency", _resolvedSupplies + _resolvedIntel];
missionNamespace setVariable ["MWF_UI_RefreshRequested", true];

if (!isNil "MWF_fnc_updateResourceUI") then {
    [] spawn MWF_fnc_updateResourceUI;
};

true
