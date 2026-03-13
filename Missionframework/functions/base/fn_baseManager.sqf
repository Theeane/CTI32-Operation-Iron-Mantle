/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Central logistical hub. Manages FOB limits (3-table), 
    dynamic naming for MOB/FOBs, and registry for redeployment.
    Language: English
*/

params [
    ["_mode", "", [""]],
    ["_data", anyValue]
];

if (!isServer) exitWith {};

// 1. INITIALIZE GLOBAL NAMES & REGISTRY
if (isNil "KPIN_FOB_Registry") then {
    KPIN_FOB_Registry = []; // Format: [[marker, object, displayName]]
    publicVariable "KPIN_FOB_Registry";
};

// Default MOB Name (Can be overridden in init.sqf or stringtable)
private _mobName = missionNamespace getVariable ["KPIN_MOB_Name", "Main Operating Base"];

switch (toUpper _mode) do {

    // --- CHECK LOGISTICAL LIMIT (3-6-9-12-15) ---
    case "CAN_DEPLOY": {
        private _maxFOBs = missionNamespace getVariable ["KPIN_Param_MaxFOBs", 3];
        private _currentCount = count KPIN_FOB_Registry;
        
        if (_currentCount < _maxFOBs) then {
            true 
        } else {
            [format["Logistical Limit Reached: %1/%2 FOBs active.", _currentCount, _maxFOBs]] remoteExec ["systemChat", remoteExecutedOwner];
            false 
        };
    };

    // --- REGISTER NEW FOB WITH DYNAMIC NAME ---
    case "ADD": {
        _data params ["_marker", "_object"];
        
        // Determine the next available FOB ID for naming
        private _fobID = (count KPIN_FOB_Registry) + 1;
        private _nameVar = format["KPIN_FOB_%1_Name", _fobID];
        private _displayName = missionNamespace getVariable [_nameVar, format["FOB %1", _fobID]];
        
        // Store it
        KPIN_FOB_Registry pushBack [_marker, _object, _displayName];
        publicVariable "KPIN_FOB_Registry";
        
        // Update marker text to match the new dynamic name
        _marker setMarkerText _displayName;
        
        // Sync with active zones
        KPIN_ActiveZones pushBack [_marker, 0];
        publicVariable "KPIN_ActiveZones";

        diag_log format ["[KPIN] Logistics: %1 registered.", _displayName];
    };

    // --- REMOVE FOB (REPACK OR DESTROYED) ---
    case "REMOVE": {
        private _markerToRemove = _data;
        
        KPIN_FOB_Registry = KPIN_FOB_Registry select { (_x # 0) != _markerToRemove };
        publicVariable "KPIN_FOB_Registry";
        
        KPIN_ActiveZones = KPIN_ActiveZones select { (_x # 0) != _markerToRemove };
        publicVariable "KPIN_ActiveZones";

        diag_log format ["[KPIN] Logistics: FOB %1 removed from registry.", _markerToRemove];
    };

    // --- GET LIST FOR REDEPLOY MENU (MOB + ALL FOBs) ---
    case "GET_REDEPLOY_LIST": {
        // We start with the MOB as the first option
        private _list = [[getPosATL KPIN_MainBase, _mobName]];
        
        // Add all active FOBs
        {
            _x params ["_mkr", "_obj", "_name"];
            _list pushBack [getPosATL _obj, _name];
        } forEach KPIN_FOB_Registry;

        _list // Return the combined list
    };
};
