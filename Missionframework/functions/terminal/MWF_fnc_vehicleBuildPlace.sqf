if (!hasInterface) exitWith { false };
if !(missionNamespace getVariable ["MWF_VehiclePlacement_Active", false]) exitWith { false };
if !(missionNamespace getVariable ["MWF_VehiclePlacement_IsValid", false]) exitWith {
    private _reason = missionNamespace getVariable ["MWF_VehiclePlacement_LastReason", "Placement invalid."];
    [["VEHICLE PLACEMENT", _reason], "warning"] call MWF_fnc_showNotification;
    false
};
missionNamespace setVariable ["MWF_VehiclePlacement_PlaceRequested", true];
true
