if (!hasInterface) exitWith { false };

private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
if (!isNull _ghost) then { deleteVehicle _ghost; };

{
    private _id = missionNamespace getVariable [_x, -1];
    if (_id >= 0) then { player removeAction _id; };
} forEach [
    "MWF_VehiclePlacement_CancelAction",
    "MWF_VehiclePlacement_RotateAction",
    "MWF_VehiclePlacement_RaiseAction",
    "MWF_VehiclePlacement_LowerAction",
    "MWF_VehiclePlacement_ConfirmAction"
];

player forceWalk false;

build_confirmed = 0;
build_invalid = 0;
build_rotation = 0;
build_elevation = 0;

{
    missionNamespace setVariable [_x, nil];
} forEach [
    "MWF_VehiclePlacement_Ghost",
    "MWF_VehiclePlacement_Class",
    "MWF_VehiclePlacement_Cost",
    "MWF_VehiclePlacement_MinTier",
    "MWF_VehiclePlacement_Name",
    "MWF_VehiclePlacement_SourceTerminal",
    "MWF_VehiclePlacement_RequiredUnlock",
    "MWF_VehiclePlacement_IsTier5",
    "MWF_VehiclePlacement_SurfaceRule",
    "MWF_VehiclePlacement_LastPosASL",
    "MWF_VehiclePlacement_LastDir",
    "MWF_VehiclePlacement_LastReason",
    "MWF_VehiclePlacement_RotateAction",
    "MWF_VehiclePlacement_RaiseAction",
    "MWF_VehiclePlacement_LowerAction",
    "MWF_VehiclePlacement_ConfirmAction",
    "MWF_VehiclePlacement_CancelAction"
];

missionNamespace setVariable ["MWF_VehiclePlacement_Active", false];
missionNamespace setVariable ["MWF_VehiclePlacement_IsValid", false];
if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "VEHICLE_PLACEMENT") then {
    missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
};

true
