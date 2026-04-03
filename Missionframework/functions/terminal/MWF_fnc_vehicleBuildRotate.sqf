if (!hasInterface) exitWith { false };
if !((missionNamespace getVariable ["MWF_VehiclePlacement_State", 0]) isEqualTo 1) exitWith { false };
missionNamespace setVariable ["MWF_VehiclePlacement_Rotation", (missionNamespace getVariable ["MWF_VehiclePlacement_Rotation", 0]) + 90];
true
