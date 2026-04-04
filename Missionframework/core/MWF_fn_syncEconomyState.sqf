/*
    Author: Theane / ChatGPT
    Function: MWF_fn_syncEconomyState
    Project: Military War Framework

    Description:
    Central authoritative economy sync helper.
    Keeps the legacy mirrored variables aligned while the framework transitions
    toward a single digital economy model.

    Parameters:
    0: Supplies value or -1 to keep current
    1: Intel value or -1 to keep current
    2: Notoriety value or -1 to keep current
    3: Whether to refresh UI globally (default: true)
    4: Whether to request delayed save (default: true)

    Returns:
    [_supplies, _intel, _notoriety]
*/

if (!isServer) exitWith {
    [
        missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]],
        missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]],
        missionNamespace getVariable ["MWF_res_notoriety", 0]
    ]
};

params [
    ["_supplies", -1, [0]],
    ["_intel", -1, [0]],
    ["_notoriety", -1, [0]],
    ["_refreshUI", true, [true]],
    ["_queueSave", true, [true]]
];

private _resolvedSupplies = if (_supplies < 0) then {
    missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]]
} else {
    _supplies max 0
};

private _resolvedIntel = if (_intel < 0) then {
    missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]]
} else {
    _intel max 0
};

private _resolvedNotoriety = if (_notoriety < 0) then {
    missionNamespace getVariable ["MWF_res_notoriety", 0]
} else {
    0 max (100 min _notoriety)
};

missionNamespace setVariable ["MWF_Economy_Supplies", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_Supplies", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_Supply", _resolvedSupplies, true];
missionNamespace setVariable ["MWF_res_intel", _resolvedIntel, true];
missionNamespace setVariable ["MWF_Intel", _resolvedIntel, true];
missionNamespace setVariable ["MWF_res_notoriety", _resolvedNotoriety, true];
missionNamespace setVariable ["MWF_Currency", _resolvedSupplies + _resolvedIntel, true];

if (_refreshUI) then {
    [_resolvedSupplies, _resolvedIntel, _resolvedNotoriety] remoteExecCall ["MWF_fnc_clientApplyEconomyState", 0, "MWF_EconomyState"];
};

if (_queueSave && {!isNil "MWF_fnc_requestDelayedSave"}) then {
    [] call MWF_fnc_requestDelayedSave;
};

[_resolvedSupplies, _resolvedIntel, _resolvedNotoriety]
