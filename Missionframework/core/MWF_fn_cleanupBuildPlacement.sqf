/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_cleanupBuildPlacement
    Project: Military War Framework

    Description:
    Central cleanup for physical base-upgrade ghost placement.
*/

if (!hasInterface) exitWith { false };

private _ghost = missionNamespace getVariable ["MWF_BuildPlacement_Ghost", objNull];
if (!isNull _ghost) then {
    deleteVehicle _ghost;
};

private _confirmAction = missionNamespace getVariable ["MWF_BuildPlacement_ConfirmAction", -1];
if (_confirmAction >= 0) then {
    player removeAction _confirmAction;
};

private _cancelAction = missionNamespace getVariable ["MWF_BuildPlacement_CancelAction", -1];
if (_cancelAction >= 0) then {
    player removeAction _cancelAction;
};

{
    missionNamespace setVariable [_x # 0, _x # 1];
} forEach [
    ["MWF_BuildPlacement_Active", false],
    ["MWF_BuildPlacement_Ghost", objNull],
    ["MWF_BuildPlacement_Class", nil],
    ["MWF_BuildPlacement_Cost", nil],
    ["MWF_BuildPlacement_UpgradeId", nil],
    ["MWF_BuildPlacement_Rotation", nil],
    ["MWF_BuildPlacement_IsValid", false],
    ["MWF_BuildPlacement_LastReason", nil],
    ["MWF_BuildPlacement_LastPosATL", nil],
    ["MWF_BuildPlacement_ConfirmAction", -1],
    ["MWF_BuildPlacement_CancelAction", -1],
    ["MWF_BuildPlacement_Confirmed", false],
    ["MWF_BuildPlacement_Cancelled", false],
    ["MWF_BuildPlacement_Interrupted", false]
];

if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "BUILD_PLACEMENT") then {
    missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
};

true
