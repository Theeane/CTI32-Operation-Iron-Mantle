/* Legacy wrapper kept only so stray vehicle calls still route into the new placement state. */
if (hasInterface) exitWith {
    if !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) exitWith { false };
    [] call MWF_fnc_vehicleBuildPlace;
};
false
