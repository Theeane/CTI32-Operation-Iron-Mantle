/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Function: KPIN_fnc_baseManager
    Description: Central logistical hub. Manages FOB limits, dynamic naming, 
                 and registry for redeployment and persistence.
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

// Default MOB Name (Main Base)
private _mobName = missionNamespace getVariable ["KPIN_MOB_Name", "Main Operating Base"];

switch (toUpper _mode) do {

    // --- CHECK LOGISTICAL LIMIT ---
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
        
        // Store in local registry for active session
        KPIN_FOB_Registry pushBack [_marker, _object, _displayName];
        publicVariable "KPIN_FOB_Registry";
        
        // Update persistent position list for fn_saveGame
        private _fobPosList = missionNamespace getVariable ["KPIN_FOB_Positions", []];
        _fobPosList pushBack [getPosASL _object, _displayName, typeOf _object];
        missionNamespace setVariable ["KPIN_FOB_Positions", _fobPosList, true];
        
        // Update marker text
        _marker setMarkerText _displayName;
        
        // Trigger save buffer to ensure the new FOB is recorded
        call KPIN_fnc_requestDelayedSave;

        diag_log format ["[KPIN] Logistics: %1 registered at %2.", _displayName, getPosATL _object];
    };

    // --- REMOVE FOB (REPACK OR DESTROYED) ---
    case "REMOVE": {
        private _markerToRemove = _data;
        private _objToRemove = objNull;

        // Find object associated with marker to update persistence
        {
            if ((_x # 0) == _markerToRemove) exitWith { _objToRemove = (_x # 1); };
        } forEach KPIN_FOB_Registry;
        
        // Cleanup active registry
        KPIN_FOB_Registry = KPIN_FOB_Registry select { (_x # 0) != _markerToRemove };
        publicVariable "KPIN_FOB_Registry";
        
        // Cleanup persistent position list
        if (!isNull _objToRemove) then {
            private _fobPosList = missionNamespace getVariable ["KPIN_FOB_Positions", []];
            private _pos = getPosASL _objToRemove;
            _fobPosList = _fobPosList select { (_x # 0) distance _pos > 5 };
            missionNamespace setVariable ["KPIN_FOB_Positions", _fobPosList, true];
        };

        call KPIN_fnc_requestDelayedSave;
        diag_log format ["[KPIN] Logistics: FOB %1 removed from registry.", _markerToRemove];
    };

    // --- GET LIST FOR REDEPLOY MENU (MOB + ALL FOBs) ---
    case "GET_REDEPLOY_LIST": {
        // Start with MOB
        private _list = [[getPosATL (missionNamespace getVariable ["KPIN_MainBase", objNull]), _mobName]];
        
        // Add all active FOBs
        {
            _x params ["_mkr", "_obj", "_name"];
            if (!isNull _obj) then {
                _list pushBack [getPosATL _obj, _name];
            };
        } forEach KPIN_FOB_Registry;

        _list 
    };
};
