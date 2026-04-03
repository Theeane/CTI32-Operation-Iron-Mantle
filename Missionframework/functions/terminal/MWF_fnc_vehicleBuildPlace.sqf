if (!hasInterface) exitWith { false };
if (build_confirmed != 1) exitWith { false };
if (build_invalid != 0) exitWith {
    systemChat (missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."]);
    false
};
build_confirmed = 2;
true
