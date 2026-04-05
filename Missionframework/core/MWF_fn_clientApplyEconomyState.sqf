/*
    Author: OpenAI
    Function: MWF_fnc_clientApplyEconomyState
    Project: Military War Framework

    Description:
    Applies the latest server economy values locally, then refreshes the HUD.
    The sidebar is updated immediately from the same shared HUD snapshot used by
    the terminal so both surfaces mirror the same values.
*/

if (!hasInterface) exitWith { false };
disableSerialization;

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

private _resourceDisplay = uiNamespace getVariable ["MWF_ctrl_resBar", displayNull];
if (!isNull _resourceDisplay) then {
    private _resourceText = _resourceDisplay displayCtrl 9001;
    if (!isNull _resourceText) then {
        private _status = [] call MWF_fnc_getHudStatusData;
        _resourceText ctrlSetStructuredText ([_status] call MWF_fnc_formatSidebarStatus);
    };
};

[] call MWF_fnc_updateResourceUI;
true
