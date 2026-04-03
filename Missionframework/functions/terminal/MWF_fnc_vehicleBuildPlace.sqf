if (!hasInterface) exitWith { false };
if !((missionNamespace getVariable ["MWF_VehiclePlacement_State", 0]) isEqualTo 1) exitWith { false };
if !(missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false]) exitWith { false };
missionNamespace setVariable ["MWF_VehiclePlacement_State", 2];
true
