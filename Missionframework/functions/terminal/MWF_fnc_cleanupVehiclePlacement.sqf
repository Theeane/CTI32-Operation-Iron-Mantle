if (!hasInterface) exitWith { false };
private _ghost = missionNamespace getVariable ["MWF_VehiclePlacement_Ghost", objNull];
if (!isNull _ghost) then { deleteVehicle _ghost; };
{
    if (_x >= 0) then { player removeAction _x; };
} forEach (missionNamespace getVariable ["MWF_VehiclePlacement_ActionIds", []]);
player forceWalk false;
{
    missionNamespace setVariable [_x, nil];
} forEach [
    "MWF_VehiclePlacement_Active",
    "MWF_VehiclePlacement_Ghost",
    "MWF_VehiclePlacement_Class",
    "MWF_VehiclePlacement_Cost",
    "MWF_VehiclePlacement_MinTier",
    "MWF_VehiclePlacement_Name",
    "MWF_VehiclePlacement_Profile",
    "MWF_VehiclePlacement_RequiredUnlock",
    "MWF_VehiclePlacement_IsTier5",
    "MWF_VehiclePlacement_SourceTerminal",
    "MWF_VehiclePlacement_Rotation",
    "MWF_VehiclePlacement_HeightOffset",
    "MWF_VehiclePlacement_IsValid",
    "MWF_VehiclePlacement_LastReason",
    "MWF_VehiclePlacement_LastPosASL",
    "MWF_VehiclePlacement_LastDir",
    "MWF_VehiclePlacement_PlaceRequested",
    "MWF_VehiclePlacement_CancelRequested",
    "MWF_VehiclePlacement_ActionIds"
];
if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "VEHICLE_PLACEMENT") then {
    missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
};
true
