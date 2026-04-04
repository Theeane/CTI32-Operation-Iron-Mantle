/*
    Author: OpenAI
    Function: MWF_fnc_clientApplyEconomyState
    Project: Military War Framework

    Description:
    Applies the latest server economy values locally, then refreshes the HUD.
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

[] call MWF_fnc_updateResourceUI;
true
