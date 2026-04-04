/*
    Author: Theane / ChatGPT
    Function: MWF_fn_clientApplyEconomyState
    Project: Military War Framework

    Description:
    Applies the authoritative economy snapshot on each client and forces a local
    HUD/UI refresh without waiting for publicVariable propagation timing.
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

missionNamespace setVariable ["MWF_Currency", (missionNamespace getVariable ["MWF_Economy_Supplies", 0]) + (missionNamespace getVariable ["MWF_res_intel", 0])];
missionNamespace setVariable ["MWF_UI_RefreshRequested", true];

if (missionNamespace getVariable ["MWF_UI_UpdateLoopRunning", false]) then {
    [] call MWF_fnc_updateResourceUI;
} else {
    [] spawn MWF_fnc_updateResourceUI;
};

true
