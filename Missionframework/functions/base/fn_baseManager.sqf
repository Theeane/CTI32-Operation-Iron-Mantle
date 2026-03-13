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

private _mobName = missionNamespace getVariable ["KPIN_MOB_Name", "Main Operating Base"];

switch (toUpper _mode) do {

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

    case "ADD": {
        _data params ["_marker", "_object"];
        
        private _fobID = (count KPIN_FOB_Registry) + 1;
        private _nameVar = format["KPIN_FOB_%1_Name", _fobID];
        private _displayName = missionNamespace getVariable [_nameVar, format["FOB %1", _fobID]];
        
        KPIN_FOB_Registry pushBack [_marker, _object, _displayName];
        publicVariable "KPIN_FOB_Registry";
        
        // --- UPDATED PERSISTENCE (Includes Direction) ---
        private _fobPosList = missionNamespace getVariable ["KPIN_FOB_Positions", []];
        _fobPosList pushBack [getPosASL _object, getDir _object, _displayName]; // Added Direction
        missionNamespace setVariable ["KPIN_FOB_Positions", _fobPosList, true];
        
        _marker setMarkerText _displayName;
        call KPIN_fnc_requestDelayedSave;

        diag_log format ["[KPIN] Logistics: %1 registered at %2.", _displayName, getPosATL _object];
    };

    case "REMOVE": {
        private _markerToRemove = _data;
        private _objToRemove = objNull;

        {
            if ((_x # 0) == _markerToRemove) exitWith { _objToRemove = (_x # 1); };
        } forEach KPIN_FOB_Registry;
        
        KPIN_FOB_Registry = KPIN_FOB_Registry select { (_x # 0) != _markerToRemove };
        publicVariable "KPIN_FOB_Registry";
        
        if (!isNull _objToRemove) then {
            private _fobPosList = missionNamespace getVariable ["KPIN_FOB_Positions", []];
            private _pos = getPosASL _objToRemove;
            _fobPosList = _fobPosList select { (_x # 0) distance _pos > 5 };
            missionNamespace setVariable ["KPIN_FOB_Positions", _fobPosList, true];
        };

        call KPIN_fnc_requestDelayedSave;
    };

    // --- UPDATED GET LIST (Includes Attack Status) ---
    case "GET_REDEPLOY_LIST": {
        // [Position, Name, Status]
        private _list = [[getPosATL (missionNamespace getVariable ["KPIN_MainBase", objNull]), _mobName, "SAFE"]];
        
        {
            _x params ["_mkr", "_obj", "_name"];
            if (!isNull _obj) then {
                // Check if this specific FOB is under attack
                private _status = _obj getVariable ["KPIN_AttackStatus", "SAFE"];
                _list pushBack [getPosATL _obj, _name, _status];
            };
        } forEach KPIN_FOB_Registry;

        _list 
    };
    
    case "GET_ACTIVE": { KPIN_FOB_Registry };
};
