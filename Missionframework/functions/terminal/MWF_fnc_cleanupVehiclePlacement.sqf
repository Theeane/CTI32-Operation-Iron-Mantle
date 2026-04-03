/*
    Cleanup for KP-style vehicle build session.
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

build_confirmed = nil;
build_invalid = nil;
build_rotation = nil;
build_elevation = nil;

{
    missionNamespace setVariable [_x, nil];
} forEach [
    "MWF_VehicleBuild_Active",
    "MWF_VehicleBuild_Ghost",
    "MWF_VehicleBuild_Profile",
    "MWF_VehicleBuild_SourceTerminal",
    "MWF_VehicleBuild_LastPosASL",
    "MWF_VehicleBuild_LastDir",
    "MWF_VehicleBuild_LastReason",
    "MWF_VehicleBuild_ActionIds"
];

true
