/*
    Author: Theane / ChatGPT
    Function: fn_baseManager
    Project: Military War Framework

    Description:
    Handles base manager for the base system.
*/

params [
    ["_mode", "", [""]],
    ["_data", anyValue]
];

if (!isServer) exitWith {};

// 1. INITIALIZE GLOBAL REGISTRY
if (isNil "MWF_FOB_Registry") then {
    MWF_FOB_Registry = []; // Format: [[marker, object, displayName]]
    publicVariable "MWF_FOB_Registry";
};

private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];

switch (toUpper _mode) do {

    // --- CHECK DEPLOYMENT CONDITIONS ---
    case "CAN_DEPLOY": {
        _data params ["_pos"]; // Position of the truck attempting to deploy
        private _maxFOBs = missionNamespace getVariable ["MWF_Param_MaxFOBs", 3];
        private _currentCount = count MWF_FOB_Registry;
        private _minDist = 500; // Requirement: 500m distance from other bases
        
        // Check Limit
        if (_currentCount >= _maxFOBs) exitWith {
            [format["Logistical Limit Reached: %1/%2 FOBs active.", _currentCount, _maxFOBs]] remoteExec ["systemChat", remoteExecutedOwner];
            false 
        };

        // Check Proximity to other FOBs/MOB
        private _tooClose = false;
        private _allBases = [getPosATL (missionNamespace getVariable ["MWF_MainBase", objNull])];
        { _allBases pushBack (getPosATL (_x # 1)); } forEach MWF_FOB_Registry;

        {
            if (_x distance _pos < _minDist) exitWith { _tooClose = true; };
        } forEach _allBases;

        if (_tooClose) exitWith {
            [format["Deployment Failed: Too close to another base! (Min %1m)", _minDist]] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };

        true 
    };

    // --- REGISTER NEW FOB ---
    case "ADD": {
        _data params ["_marker", "_object"];
        
        private _fobID = (count MWF_FOB_Registry) + 1;
        private _nameVar = format["MWF_FOB_%1_Name", _fobID];
        private _displayName = missionNamespace getVariable [_nameVar, format["FOB %1", _fobID]];
        
        MWF_FOB_Registry pushBack [_marker, _object, _displayName];
        publicVariable "MWF_FOB_Registry";
        
        // Persistence (Position, Direction, Name)
        private _fobPosList = missionNamespace getVariable ["MWF_FOB_Positions", []];
        _fobPosList pushBack [getPosASL _object, getDir _object, _displayName];
        missionNamespace setVariable ["MWF_FOB_Positions", _fobPosList, true];
        
        _marker setMarkerText _displayName;
        call MWF_fnc_requestDelayedSave;

        diag_log format ["[KPIN] Logistics: %1 registered at %2.", _displayName, getPosATL _object];
    };

    // --- REMOVE FOB (REPACK OR DESTROYED) ---
    case "REMOVE": {
        private _markerToRemove = _data;
        private _objToRemove = objNull;

        {
            if ((_x # 0) == _markerToRemove) exitWith { _objToRemove = (_x # 1); };
        } forEach MWF_FOB_Registry;
        
        MWF_FOB_Registry = MWF_FOB_Registry select { (_x # 0) != _markerToRemove };
        publicVariable "MWF_FOB_Registry";
        
        if (!isNull _objToRemove) then {
            private _fobPosList = missionNamespace getVariable ["MWF_FOB_Positions", []];
            private _pos = getPosASL _objToRemove;
            _fobPosList = _fobPosList select { (_x # 0) distance _pos > 5 };
            missionNamespace setVariable ["MWF_FOB_Positions", _fobPosList, true];
        };

        call MWF_fnc_requestDelayedSave;
    };

    // --- GET LIST FOR REDEPLOY MENU (Includes MOB, FOBs, and Mobile Respawn) ---
    case "GET_REDEPLOY_LIST": {
        private _list = [[getPosATL (missionNamespace getVariable ["MWF_MainBase", objNull]), _mobName, "SAFE"]];
        
        // Add FOBs
        {
            _x params ["_mkr", "_obj", "_name"];
            if (!isNull _obj) then {
                private _status = _obj getVariable ["MWF_AttackStatus", "SAFE"];
                _list pushBack [getPosATL _obj, _name, _status];
            };
        } forEach MWF_FOB_Registry;

        // Add Mobile Respawn Vehicles (Only if stationary)
        {
            if (_x getVariable ["MWF_isMobileRespawn", false]) then {
                private _isReady = _x getVariable ["MWF_respawnAvailable", false];
                if (_isReady) then {
                    _list pushBack [getPosATL _x, "Mobile Respawn Unit", "SAFE"];
                };
            };
        } forEach vehicles;

        _list 
    };
    
    case "GET_ACTIVE": { MWF_FOB_Registry };
};
