/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Central controller for FOB limits, registry, and state. 
    Handles max FOB logic based on lobby parameters (3-table: 3, 6, 9, 12, 15).
    Language: English
*/

params [
    ["_mode", "", [""]],
    ["_data", anyValue]
];

if (!isServer) exitWith {};

// Initialize the global FOB registry if it doesn't exist
if (isNil "KPIN_FOB_Registry") then {
    KPIN_FOB_Registry = []; // Stores [markerName, object]
    publicVariable "KPIN_FOB_Registry";
};

switch (toUpper _mode) do {

    // --- CHECK IF NEW DEPLOYMENT IS ALLOWED ---
    case "CAN_DEPLOY": {
        private _maxFOBs = missionNamespace getVariable ["KPIN_Param_MaxFOBs", 3]; // Default to 3
        private _currentCount = count KPIN_FOB_Registry;
        
        if (_currentCount < _maxFOBs) then {
            true // Space available
        } else {
            [format["Deployment Denied: Max FOB limit reached (%1/%2).", _currentCount, _maxFOBs]] remoteExec ["systemChat", remoteExecutedOwner];
            false // Limit reached
        };
    };

    // --- REGISTER A NEW FOB ---
    case "ADD": {
        _data params ["_marker", "_object"];
        KPIN_FOB_Registry pushBack [_marker, _object];
        publicVariable "KPIN_FOB_Registry";
        
        // Also sync with the zone system for economy/AI
        KPIN_ActiveZones pushBack [_marker, 0];
        publicVariable "KPIN_ActiveZones";
        
        diag_log format ["[KPIN] FOB Registered: %1 at %2", _marker, mapGridPosition _object];
    };

    // --- REMOVE A FOB (REPACK OR DESTROYED) ---
    case "REMOVE": {
        private _markerToRemove = _data; // Expects marker name string
        
        // Clean from registry
        KPIN_FOB_Registry = KPIN_FOB_Registry select { (_x # 0) != _markerToRemove };
        publicVariable "KPIN_FOB_Registry";
        
        // Clean from active zones
        KPIN_ActiveZones = KPIN_ActiveZones select { (_x # 0) != _markerToRemove };
        publicVariable "KPIN_ActiveZones";

        diag_log format ["[KPIN] FOB Removed: %1. Slot cleared.", _markerToRemove];
    };

    // --- GET CURRENT LIST (FOR REDEPLOY MENU) ---
    case "GET_ACTIVE": {
        KPIN_FOB_Registry // Returns the array of active FOBs
    };
};
