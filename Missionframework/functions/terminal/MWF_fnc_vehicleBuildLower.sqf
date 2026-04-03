if (!hasInterface) exitWith { false };
if !((missionNamespace getVariable ["MWF_VehiclePlacement_State", 0]) isEqualTo 1) exitWith { false };
missionNamespace setVariable ["MWF_VehiclePlacement_HeightOffset", (missionNamespace getVariable ["MWF_VehiclePlacement_HeightOffset", 0]) - 0.2];
true
