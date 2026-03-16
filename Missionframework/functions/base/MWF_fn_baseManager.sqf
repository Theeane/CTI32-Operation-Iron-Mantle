/*
    Author: Theane / ChatGPT
    Function: fn_baseManager
    Project: Military War Framework

    Description:
    Lightweight base registry helper for FOB deployment rules and active base lookups.
    Registration and repack/deploy pipelines are handled by dedicated base functions.
*/

params [
    ["_mode", "", [""]],
    ["_data", nil]
];

if (!isServer) exitWith {};

if (isNil "MWF_FOB_Registry") then {
    missionNamespace setVariable ["MWF_FOB_Registry", [], true];
};

private _registry = missionNamespace getVariable ["MWF_FOB_Registry", []];
private _mobName = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];

switch (toUpper _mode) do {
    case "CAN_DEPLOY": {
        _data params [["_pos", [], [[]]]];

        private _maxFOBs = missionNamespace getVariable ["MWF_Param_MaxFOBs", 3];
        private _currentCount = count _registry;
        private _minDist = 500;
        private _mobMinDist = 1000;

        if (_currentCount >= _maxFOBs) exitWith {
            [format ["Logistical Limit Reached: %1/%2 FOBs active.", _currentCount, _maxFOBs]] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };

        private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
        private _mobPos = if (!isNull _mainBase) then {
            getPosATL _mainBase
        } else {
            getMarkerPos "respawn_west"
        };

        if ((_pos distance _mobPos) < _mobMinDist) exitWith {
            ["Deployment Failed: Must be 1000m from MOB to deploy FOB."] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };

        private _allBases = [];
        if (!isNull _mainBase) then {
            _allBases pushBack (getPosATL _mainBase);
        };

        {
            private _obj = _x param [1, objNull];
            if (!isNull _obj) then {
                _allBases pushBack (getPosATL _obj);
            };
        } forEach _registry;

        private _tooClose = _allBases findIf { _x distance _pos < _minDist } > -1;
        if (_tooClose) exitWith {
            [format ["Deployment Failed: Too close to another base! (Min %1m)", _minDist]] remoteExec ["systemChat", remoteExecutedOwner];
            false
        };

        true
    };

    case "ADD": {
        _data params [["_object", objNull, [objNull]], ["_displayName", "", [""]], ["_originType", "TRUCK", [""]], ["_requestSave", true, [true]]];
        [_object, _displayName, _originType, _requestSave] call MWF_fnc_registerFOB
    };

    case "REMOVE": {
        _data params [["_object", objNull, [objNull]], ["_marker", "", [""]], ["_requestSave", true, [true]]];
        [_object, _marker, _requestSave] call MWF_fnc_unregisterFOB
    };

    case "GET_REDEPLOY_LIST": {
        private _list = [];
        private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
        if (!isNull _mainBase) then {
            _list pushBack [getPosATL _mainBase, _mobName, "SAFE"];
        } else {
            _list pushBack [getMarkerPos "respawn_west", _mobName, "SAFE"];
        };

        {
            _x params ["_marker", "_obj", ["_name", "FOB", [""]]];
            if (!isNull _obj) then {
                private _status = _obj getVariable ["MWF_AttackStatus", "SAFE"];
                _list pushBack [getPosATL _obj, _name, _status];
            };
        } forEach _registry;

        {
            if (_x getVariable ["MWF_isMobileRespawn", false]) then {
                if (_x getVariable ["MWF_respawnAvailable", false]) then {
                    _list pushBack [getPosATL _x, "Mobile Respawn Unit", "SAFE"];
                };
            };
        } forEach vehicles;

        _list
    };

    case "GET_ACTIVE": { _registry };
};
