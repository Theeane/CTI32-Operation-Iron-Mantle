if (!hasInterface) exitWith { false };

private _ghost = missionNamespace getVariable ["MWF_VehicleBuild_Ghost", objNull];
if (!isNull _ghost) then { deleteVehicle _ghost; };

{
    if (_x >= 0) then { player removeAction _x; };
} forEach (missionNamespace getVariable ["MWF_VehicleBuild_ActionIds", []]);

missionNamespace setVariable ["MWF_VehicleBuild_ActionIds", []];
missionNamespace setVariable ["MWF_VehicleBuild_Active", false];
missionNamespace setVariable ["MWF_VehicleBuild_Ghost", objNull];
missionNamespace setVariable ["MWF_VehicleBuild_Entry", nil];
missionNamespace setVariable ["MWF_VehicleBuild_Class", nil];
missionNamespace setVariable ["MWF_VehicleBuild_Cost", nil];
missionNamespace setVariable ["MWF_VehicleBuild_MinTier", nil];
missionNamespace setVariable ["MWF_VehicleBuild_DisplayName", nil];
missionNamespace setVariable ["MWF_VehicleBuild_RequiredUnlock", nil];
missionNamespace setVariable ["MWF_VehicleBuild_IsTier5", nil];
missionNamespace setVariable ["MWF_VehicleBuild_SourceTerminal", nil];
missionNamespace setVariable ["MWF_VehicleBuild_Type", nil];
missionNamespace setVariable ["MWF_VehicleBuild_SurfaceRule", nil];
player forceWalk false;

build_confirmed = 0;
build_invalid = 0;
build_rotation = 0;
build_elevation = 0;

if ((missionNamespace getVariable ["MWF_SensitiveInteraction_Type", ""]) isEqualTo "VEHICLE_PLACEMENT") then {
    missionNamespace setVariable ["MWF_SensitiveInteraction_Type", nil];
};
true
