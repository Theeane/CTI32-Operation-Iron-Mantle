/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_cleanupVehiclePlacement
    Project: Military War Framework

    Description:
    Central cleanup for the vehicle ghost placement state.
*/

if (!hasInterface) exitWith { false };

private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
if (!isNull _ghost) then {
    deleteVehicle _ghost;
};

private _confirmAction = missionNamespace getVariable ["MWF_VehiclePlacement_ConfirmAction", -1];
if (_confirmAction >= 0) then {
    player removeAction _confirmAction;
};

private _cancelAction = missionNamespace getVariable ["MWF_VehiclePlacement_CancelAction", -1];
if (_cancelAction >= 0) then {
    player removeAction _cancelAction;
};

missionNamespace setVariable ["MWF_VehiclePlacement_Active", false];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", objNull];
missionNamespace setVariable ["MWF_VehiclePlacement_Class", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_Cost", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_MinTier", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_Name", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_Profile", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
missionNamespace setVariable ["MWF_VehiclePlacement_LastReason", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_LastPosASL", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_LastDir", nil];
missionNamespace setVariable ["MWF_VehiclePlacement_ConfirmAction", -1];
missionNamespace setVariable ["MWF_VehiclePlacement_CancelAction", -1];
if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "VEHICLE_PLACEMENT") then {
    missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
};

true
