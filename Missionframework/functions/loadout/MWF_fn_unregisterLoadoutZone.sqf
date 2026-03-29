/*
    Author: Theeane / Gemini
    Function: MWF_fnc_unregisterLoadoutZone
    Project: Military War Framework

    Description:
    Server-side cleanup function. Removes a loadout zone trigger and 
    clears all associated references from the global registry and anchors.
*/

if (!isServer) exitWith { false };

params [
    ["_target", objNull, [objNull]] // The trigger or the anchor object (e.g., FOB Truck)
];

if (isNull _target) exitWith { false };

// 1. Identify the trigger
// If the target is the anchor object, we find its linked trigger.
private _zone = if (_target getVariable ["MWF_isLoadoutZone", false]) then {
    _target
} else {
    _target getVariable ["MWF_LoadoutTrigger", objNull]
};

if (isNull _zone) exitWith {
    diag_log "[MWF] Unregister Zone: No valid loadout zone found for target.";
    false 
};

// 2. Clean up Anchor references
private _anchor = _zone getVariable ["MWF_LoadoutZoneAnchor", objNull];
if (!isNull _anchor) then {
    // Terminate the mobile tracking script if it exists
    private _tracker = _anchor getVariable ["MWF_LoadoutZoneTracker", scriptNull];
    if !(_tracker isEqualTo scriptNull) then {
        terminate _tracker;
    };
    
    // Clear variables on the anchor
    _anchor setVariable ["MWF_LoadoutZoneTracker", scriptNull];
    _anchor setVariable ["MWF_LoadoutTrigger", objNull, true];
};

// 3. Update the Global Registry
// We filter out the current zone and any other null references
private _zones = missionNamespace getVariable ["MWF_LoadoutZones", []];
_zones = _zones select { !isNull _x && { _x != _zone } };
missionNamespace setVariable ["MWF_LoadoutZones", _zones, true];

// 4. Physical Cleanup
private _label = _zone getVariable ["MWF_LoadoutZoneLabel", "Unknown"];
deleteVehicle _zone;

diag_log format ["[MWF] Loadout Zone Unregistered: %1 has been removed.", _label];
true