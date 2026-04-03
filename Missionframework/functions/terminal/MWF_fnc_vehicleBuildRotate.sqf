if (!hasInterface) exitWith { false };
if !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) exitWith { false };
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", (missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0]) + 90];
true
