/*
    Author: OpenAI
    Function: MWF_fnc_cleanupVehiclePlacement
    Project: Military War Framework

    Description:
    Hard cleanup for the new KP-style vehicle build session.
*/

if (!hasInterface) exitWith { false };

private _actionIds = missionNamespace getVariable ["MWF_VehicleBuild_ActionIds", []];
{
    if (_x isEqualType 0 && {_x >= 0}) then {
        player removeAction _x;
    };
} forEach _actionIds;
missionNamespace setVariable ["MWF_VehicleBuild_ActionIds", []];

private _ghost = missionNamespace getVariable ["MWF_VehicleBuild_Ghost", objNull];
if (!isNull _ghost) then {
    deleteVehicle _ghost;
};

player forceWalk false;

{
    missionNamespace setVariable [_x, nil];
} forEach [
    "MWF_VehicleBuild_Active",
    "MWF_VehicleBuild_Confirmed",
    "MWF_VehicleBuild_Cancelled",
    "MWF_VehicleBuild_Invalid",
    "MWF_VehicleBuild_Class",
    "MWF_VehicleBuild_Cost",
    "MWF_VehicleBuild_MinTier",
    "MWF_VehicleBuild_DisplayName",
    "MWF_VehicleBuild_RequiredUnlock",
    "MWF_VehicleBuild_IsTier5",
    "MWF_VehicleBuild_Profile",
    "MWF_VehicleBuild_SourceTerminal",
    "MWF_VehicleBuild_Ghost",
    "MWF_VehicleBuild_ActionIds",
    "MWF_VehicleBuild_Rotation",
    "MWF_VehicleBuild_Elevation",
    "MWF_VehicleBuild_LastPosASL",
    "MWF_VehicleBuild_LastDir",
    "MWF_VehicleBuild_LastReason"
];

missionNamespace setVariable ["MWF_VehiclePlacement_Active", false];
missionNamespace setVariable ["MWF_VehiclePlacement_Ghost", objNull];

true
