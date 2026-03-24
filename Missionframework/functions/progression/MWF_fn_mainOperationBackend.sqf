/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_mainOperationBackend
    Project: Military War Framework

    Description:
    Server-side gameplay backend for main-operation phases.
    Spawns lightweight objective props/guards and marks the active phase task
    as SUCCEEDED once the current phase condition is met.

    This keeps the authored operation scripts as the single source of truth for
    task text and rewards while supplying the missing runtime objective layer.
*/

if (!isServer) exitWith { false };

params [
    ["_mode", "START_PHASE", [""]],
    ["_arg1", [], [[], ""]],
    ["_arg2", [], [[]]],
    ["_arg3", objNull, [objNull, 0]]
];

private _backendMap = missionNamespace getVariable ["MWF_MainOperationBackend", createHashMap];
if (isNil "_backendMap" || { !(_backendMap isEqualType createHashMap) }) then {
    _backendMap = createHashMap;
};

private _setBackendMap = {
    params ["_map"];
    missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
};

private _resolveClass = {
    params ["_candidates", ["_fallback", "Land_PortableGenerator_01_F", [""]]];
    {
        if (isClass (configFile >> "CfgVehicles" >> _x)) exitWith { _x };
    } forEach _candidates;
    _fallback
};

private _pickGuardPool = {
    private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _worldTier = (missionNamespace getVariable ["MWF_WorldTier", 1]) max 1 min 5;
    private _pool = [];
    for "_tier" from 1 to _worldTier do {
        private _tierKey = format ["Infantry_T%1", _tier];
        private _list = _preset getOrDefault [_tierKey, []];
        if (_list isEqualType []) then { _pool append _list; };
    };
    if (_pool isEqualTo []) then {
        _pool = ["O_Soldier_F", "O_Soldier_GL_F", "O_Soldier_AR_F"];
    };
    _pool
};

private _pickOfficerClass = {
    private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _candidates = [];
    {
        private _list = _preset getOrDefault [_x, []];
        if (_list isEqualType []) then { _candidates append _list; };
    } forEach ["Infantry_T5", "Infantry_T4", "Infantry_T3", "Infantry_T2", "Infantry_T1"];

    private _preferred = _candidates select {
        private _cls = toLower str _x;
        (_cls find "officer") >= 0 || {(_cls find "leader") >= 0} || {(_cls find "sl") >= 0}
    };

    if (_preferred isNotEqualTo []) exitWith { _preferred # 0 };
    if (_candidates isNotEqualTo []) exitWith { _candidates # 0 };
    "O_Officer_F"
};

private _pickCivilianClass = {
    private _pool = missionNamespace getVariable ["MWF_CIV_Units", missionNamespace getVariable ["MWF_Civ_List", ["C_man_1"]]];
    if (_pool isEqualType [] && {_pool isNotEqualTo []}) exitWith { selectRandom _pool };
    "C_man_1"
};

private _findObjectivePos = {
    params ["_center", ["_minRadius", 5, [0]], ["_maxRadius", 35, [0]], ["_landOnly", true, [false]]];
    private _chosen = +_center;
    _chosen set [2, 0];
    for "_attempt" from 0 to 24 do {
        private _probe = [_center, _minRadius, _maxRadius, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        if !(_probe isEqualTo _center) then {
            if (!_landOnly || {!surfaceIsWater _probe}) exitWith { _chosen = +_probe; };
        };
    };
    _chosen
};

private _spawnObject = {
    params ["_className", "_pos", ["_allowDamage", false, [false]], ["_dir", -1, [0]]];
    if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith { objNull };
    private _obj = createVehicle [_className, _pos, [], 0, "NONE"];
    _obj setPosATL _pos;
    if (_dir >= 0) then { _obj setDir _dir; };
    _obj allowDamage _allowDamage;
    _obj enableDynamicSimulation true;
    _obj
};

private _spawnGuards = {
    params ["_center", ["_count", 4, [0]], ["_radius", 25, [0]], ["_addOfficer", false, [false]], ["_civilian", false, [false]]];
    private _groups = [];
    private _units = [];

    if (_civilian) then {
        private _grp = createGroup [civilian, true];
        _groups pushBack _grp;
        private _spawnPos = [_center, 2, 8, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        private _unit = _grp createUnit [call _pickCivilianClass, _spawnPos, [], 0, "NONE"];
        _unit setBehaviour "CARELESS";
        _unit disableAI "AUTOCOMBAT";
        _unit disableAI "TARGET";
        _unit disableAI "AUTOTARGET";
        _unit enableDynamicSimulation true;
        _units pushBack _unit;
        [_units, _groups]
    } else {
        private _guardPool = call _pickGuardPool;
        private _group = createGroup [east, true];
        _groups pushBack _group;

        for "_i" from 1 to (_count max 1) do {
            private _spawnPos = [_center, 6, _radius, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
            private _unitClass = selectRandom _guardPool;
            private _unit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
            if (!isNil "MWF_fnc_initInteractions") then { [_unit] call MWF_fnc_initInteractions; };
            _unit enableDynamicSimulation true;
            _units pushBack _unit;
        };

        if (_addOfficer) then {
            private _officerGroup = createGroup [east, true];
            _groups pushBack _officerGroup;
            private _officerPos = [_center, 2, 10, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
            private _officer = _officerGroup createUnit [call _pickOfficerClass, _officerPos, [], 0, "NONE"];
            if (!isNil "MWF_fnc_initInteractions") then { [_officer] call MWF_fnc_initInteractions; };
            _officer setRank "LIEUTENANT";
            _officer enableDynamicSimulation true;
            _units pushBack _officer;
        };

        {
            [_x, _center, (_radius max 20)] call BIS_fnc_taskPatrol;
        } forEach _groups;

        [_units, _groups]
    }
};

private _cleanupRecord = {
    params ["_record"];
    if !(_record isEqualType createHashMap) exitWith {};

    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach (_record getOrDefault ["objects", []]);

    {
        if (!isNull _x) then { deleteVehicle _x; };
    } forEach ((_record getOrDefault ["units", []]) select { alive _x });

    {
        if (!isNull _x) then {
            { if (!isNull _x) then { deleteVehicle _x; }; } forEach units _x;
            deleteGroup _x;
        };
    } forEach (_record getOrDefault ["groups", []]);

    private _markerName = _record getOrDefault ["markerName", ""];
    if (_markerName isNotEqualTo "") then {
        deleteMarker _markerName;
    };
};

private _buildPlan = {
    params ["_key", "_phaseIndex", "_position"];
    private _plan = createHashMap;
    _plan set ["center", +_position];
    _plan set ["marker", false];

    switch (toUpper _key) do {
        case "SKY_GUARDIAN": {
            switch (_phaseIndex) do {
                case 0: {
                    _plan set ["type", "destroy_multi"];
                    _plan set ["classCandidates", ["Land_Radar_Small_F", "Land_TTowerSmall_1_F"]];
                    _plan set ["count", 3];
                    _plan set ["guards", 6];
                    _plan set ["radius", 55];
                };
                case 1: {
                    _plan set ["type", "kill_officer"];
                    _plan set ["guards", 5];
                    _plan set ["radius", 35];
                };
                case 2: {
                    _plan set ["type", "clear_hold"];
                    _plan set ["guards", 8];
                    _plan set ["addOfficer", true];
                    _plan set ["radius", 45];
                    _plan set ["holdDuration", 20];
                };
            };
        };
        case "POINT_BLANK": {
            switch (_phaseIndex) do {
                case 0: { _plan set ["type", "reach"]; _plan set ["guards", 4]; _plan set ["radius", 30]; };
                case 1: {
                    _plan set ["type", "destroy_multi"];
                    _plan set ["classCandidates", ["Land_PortableGenerator_01_F", "Land_Device_assembled_F"]];
                    _plan set ["count", 2];
                    _plan set ["guards", 6];
                    _plan set ["radius", 38];
                };
                case 2: { _plan set ["type", "interact"]; _plan set ["classCandidates", ["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"]]; _plan set ["guards", 6]; _plan set ["radius", 30]; _plan set ["interactionTime", 5]; };
                case 3: { _plan set ["type", "clear_hold"]; _plan set ["guards", 8]; _plan set ["radius", 40]; _plan set ["holdDuration", 25]; };
                case 4: { _plan set ["type", "destroy_multi"]; _plan set ["classCandidates", ["Land_TTowerSmall_1_F", "Land_Device_assembled_F"]]; _plan set ["count", 1]; _plan set ["guards", 6]; _plan set ["radius", 32]; };
            };
        };
        case "SEVERED_NERVE": {
            switch (_phaseIndex) do {
                case 0: { _plan set ["type", "meet_informant"]; _plan set ["radius", 18]; };
                case 1: { _plan set ["type", "interact"]; _plan set ["classCandidates", ["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"]]; _plan set ["guards", 5]; _plan set ["radius", 28]; _plan set ["interactionTime", 5]; };
                case 2: { _plan set ["type", "kill_officer"]; _plan set ["guards", 5]; _plan set ["radius", 32]; };
                case 3: { _plan set ["type", "destroy_multi"]; _plan set ["classCandidates", ["CargoNet_01_barrels_F", "Land_FuelStation_01_pump_F"]]; _plan set ["count", 2]; _plan set ["guards", 6]; _plan set ["radius", 35]; };
                case 4: { _plan set ["type", "extract"]; _plan set ["radius", 22]; _plan set ["extractDistance", 90]; };
            };
        };
        case "STASIS_STRIKE": {
            switch (_phaseIndex) do {
                case 0: { _plan set ["type", "reach"]; _plan set ["guards", 5]; _plan set ["radius", 28]; };
                case 1: { _plan set ["type", "interact"]; _plan set ["classCandidates", ["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"]]; _plan set ["guards", 6]; _plan set ["radius", 30]; _plan set ["interactionTime", 6]; };
                case 2: { _plan set ["type", "destroy_multi"]; _plan set ["classCandidates", ["Land_TTowerSmall_1_F", "Land_TTowerBig_1_F"]]; _plan set ["count", 2]; _plan set ["guards", 7]; _plan set ["radius", 35]; };
                case 3: { _plan set ["type", "extract"]; _plan set ["radius", 22]; _plan set ["extractDistance", 95]; };
            };
        };
        case "STEEL_RAIN": {
            switch (_phaseIndex) do {
                case 0: { _plan set ["type", "clear_area"]; _plan set ["guards", 8]; _plan set ["addOfficer", true]; _plan set ["radius", 40]; };
                case 1: { _plan set ["type", "secure_object"]; _plan set ["classCandidates", ["Land_CargoBox_V1_F", "CargoNet_01_box_F"]]; _plan set ["guards", 5]; _plan set ["radius", 32]; _plan set ["interactionTime", 5]; };
                case 2: { _plan set ["type", "clear_hold"]; _plan set ["guards", 10]; _plan set ["addOfficer", true]; _plan set ["radius", 45]; _plan set ["holdDuration", 45]; };
            };
        };
        case "APEX_PREDATOR": {
            switch (_phaseIndex) do {
                case 0: { _plan set ["type", "reach"]; _plan set ["guards", 6]; _plan set ["radius", 28]; };
                case 1: { _plan set ["type", "interact"]; _plan set ["classCandidates", ["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"]]; _plan set ["guards", 7]; _plan set ["radius", 30]; _plan set ["interactionTime", 6]; };
                case 2: { _plan set ["type", "secure_object"]; _plan set ["classCandidates", ["CargoNet_01_box_F", "Land_CargoBox_V1_F"]]; _plan set ["guards", 8]; _plan set ["addOfficer", true]; _plan set ["radius", 35]; _plan set ["interactionTime", 5]; };
                case 3: { _plan set ["type", "clear_area"]; _plan set ["guards", 10]; _plan set ["addOfficer", true]; _plan set ["radius", 40]; };
                case 4: { _plan set ["type", "extract"]; _plan set ["radius", 22]; _plan set ["extractDistance", 100]; };
            };
        };
    };

    _plan
};

switch (toUpper _mode) do {
    case "STOP": {
        private _key = _arg1;
        if !(_key isEqualType "") exitWith { false };
        private _record = _backendMap getOrDefault [_key, createHashMap];
        if (_record isEqualType createHashMap) then {
            [_record] call _cleanupRecord;
        };
        _backendMap deleteAt _key;
        [_backendMap] call _setBackendMap;
        true
    };

    case "START_PHASE": {
        _arg1 params [
            ["_key", "", [""]],
            ["_phaseIndex", 0, [0]],
            ["_taskId", "", [""]],
            ["_position", [0,0,0], [[]]]
        ];
        if (_key isEqualTo "" || {_taskId isEqualTo ""}) exitWith { false };

        ["STOP", _key] call MWF_fnc_mainOperationBackend;

        private _plan = [_key, _phaseIndex, _position] call _buildPlan;
        private _type = _plan getOrDefault ["type", ""];
        if (_type isEqualTo "") exitWith { false };

        private _token = diag_tickTime + random 1000;
        private _center = _plan getOrDefault ["center", _position];
        private _radius = _plan getOrDefault ["radius", 30];
        private _guardCount = _plan getOrDefault ["guards", 0];
        private _addOfficer = _plan getOrDefault ["addOfficer", false];
        private _interactionTime = _plan getOrDefault ["interactionTime", 5];
        private _holdDuration = _plan getOrDefault ["holdDuration", 20];
        private _extractDistance = _plan getOrDefault ["extractDistance", 90];
        private _count = _plan getOrDefault ["count", 1];

        private _objectivePos = if (_type in ["extract"]) then {
            [_center, _extractDistance * 0.7, _extractDistance, true] call _findObjectivePos
        } else {
            [_center, 6, (_radius max 20), true] call _findObjectivePos
        };

        private _objects = [];
        private _units = [];
        private _groups = [];
        private _primaryTarget = objNull;

        private _guardAnchor = if (_type isEqualTo "extract") then { _objectivePos } else { _center };
        if (_guardCount > 0) then {
            private _spawned = [_guardAnchor, _guardCount, (_radius + 10), _addOfficer, false] call _spawnGuards;
            _units append (_spawned # 0);
            _groups append (_spawned # 1);
        };

        switch (_type) do {
            case "destroy_multi": {
                private _className = [(_plan getOrDefault ["classCandidates", ["Land_PortableGenerator_01_F"]]), "Land_PortableGenerator_01_F"] call _resolveClass;
                for "_i" from 1 to (_count max 1) do {
                    private _objPos = [_center, 6, _radius, true] call _findObjectivePos;
                    private _obj = [_className, _objPos, true, random 360] call _spawnObject;
                    if (!isNull _obj) then {
                        _objects pushBack _obj;
                    };
                };
            };
            case "interact": {
                private _className = [(_plan getOrDefault ["classCandidates", ["Land_DataTerminal_01_F"]]), "Land_DataTerminal_01_F"] call _resolveClass;
                private _obj = [_className, _objectivePos, false, random 360] call _spawnObject;
                if (!isNull _obj) then {
                    _objects pushBack _obj;
                    _primaryTarget = _obj;
                };
            };
            case "secure_object": {
                private _className = [(_plan getOrDefault ["classCandidates", ["Land_DataTerminal_01_F"]]), "Land_DataTerminal_01_F"] call _resolveClass;
                private _obj = [_className, _objectivePos, false, random 360] call _spawnObject;
                if (!isNull _obj) then {
                    _objects pushBack _obj;
                    _primaryTarget = _obj;
                };
            };
            case "kill_officer": {
                private _spawnedOfficer = [_center, 0, 10, true, false] call _spawnGuards;
                _units append (_spawnedOfficer # 0);
                _groups append (_spawnedOfficer # 1);
                _primaryTarget = (_spawnedOfficer # 0) param [count (_spawnedOfficer # 0) - 1, objNull];
            };
            case "meet_informant": {
                private _spawnedInformant = [_objectivePos, 1, 8, false, true] call _spawnGuards;
                _units append (_spawnedInformant # 0);
                _groups append (_spawnedInformant # 1);
                _primaryTarget = (_spawnedInformant # 0) param [0, objNull];
            };
            default {};
        };

        private _startValid = switch (_type) do {
            case "destroy_multi": { (count _objects) >= (_count max 1) };
            case "interact";
            case "secure_object";
            case "kill_officer";
            case "meet_informant": { !isNull _primaryTarget };
            default { true };
        };
        if (!_startValid) exitWith {
            {
                if (!isNull _x) then { deleteVehicle _x; };
            } forEach _objects;
            {
                if (!isNull _x) then { deleteVehicle _x; };
            } forEach (_units select { alive _x });
            {
                if (!isNull _x) then {
                    { if (!isNull _x) then { deleteVehicle _x; }; } forEach units _x;
                    deleteGroup _x;
                };
            } forEach _groups;
            diag_log format ["[MWF MainOp] START_PHASE failed validation for %1 phase %2 (%3).", _key, _phaseIndex, _type];
            false
        };

        private _markerName = format ["MWF_MainOp_%1_%2", _key, round (serverTime * 10)];
        private _marker = createMarker [_markerName, _objectivePos];
        _marker setMarkerShape "ICON";
        _marker setMarkerType "mil_objective";
        _marker setMarkerColor "ColorBLUFOR";
        _marker setMarkerText format ["%1 Objective", _key];

        private _record = createHashMapFromArray [
            ["token", _token],
            ["taskId", _taskId],
            ["phaseIndex", _phaseIndex],
            ["objectiveType", _type],
            ["objectivePos", _objectivePos],
            ["center", _center],
            ["radius", _radius],
            ["interactionTime", _interactionTime],
            ["holdDuration", _holdDuration],
            ["objects", _objects],
            ["units", _units],
            ["groups", _groups],
            ["primaryTarget", _primaryTarget],
            ["markerName", _markerName],
            ["holdStartedAt", -1],
            ["interactStartedAt", -1]
        ];

        _backendMap = missionNamespace getVariable ["MWF_MainOperationBackend", createHashMap];
        if (isNil "_backendMap" || { !(_backendMap isEqualType createHashMap) }) then { _backendMap = createHashMap; };
        _backendMap set [_key, _record];
        [_backendMap] call _setBackendMap;

        [_key, _taskId, _token] spawn {
            params ["_key", "_taskId", "_token"];
            if (!isServer) exitWith {};

            private _markDetected = {
                params ["_units", "_center"];
                if (missionNamespace getVariable ["MWF_Op_Detected", false]) exitWith {};
                private _players = allPlayers select { alive _x && {side group _x isEqualTo west} && {(_x distance2D _center) <= 180} };
                if (_players isEqualTo []) exitWith {};
                {
                    if (alive _x && {side _x isEqualTo east}) then {
                        private _enemy = _x;
                        private _spotted = _players findIf { _enemy knowsAbout _x > 1.4 };
                        if (_spotted >= 0) exitWith {
                            missionNamespace setVariable ["MWF_Op_Detected", true, true];
                        };
                    };
                } forEach _units;
            };

            private _cleanupForKey = {
                params ["_key", "_token"];
                private _map = missionNamespace getVariable ["MWF_MainOperationBackend", createHashMap];
                if (isNil "_map" || { !(_map isEqualType createHashMap) }) exitWith {};
                private _record = _map getOrDefault [_key, createHashMap];
                if !(_record isEqualType createHashMap) exitWith {};
                if ((_record getOrDefault ["token", -1]) != _token) exitWith {};

                {
                    if (!isNull _x) then { deleteVehicle _x; };
                } forEach (_record getOrDefault ["objects", []]);
                {
                    if (!isNull _x) then { deleteVehicle _x; };
                } forEach ((_record getOrDefault ["units", []]) select { alive _x });
                {
                    if (!isNull _x) then {
                        { if (!isNull _x) then { deleteVehicle _x; }; } forEach units _x;
                        deleteGroup _x;
                    };
                } forEach (_record getOrDefault ["groups", []]);

                private _markerName = _record getOrDefault ["markerName", ""];
                if (_markerName isNotEqualTo "") then { deleteMarker _markerName; };

                _map deleteAt _key;
                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
            };

            while {true} do {
                private _map = missionNamespace getVariable ["MWF_MainOperationBackend", createHashMap];
                if (isNil "_map" || { !(_map isEqualType createHashMap) }) exitWith {};
                private _record = _map getOrDefault [_key, createHashMap];
                if !(_record isEqualType createHashMap) exitWith {};
                if ((_record getOrDefault ["token", -1]) != _token) exitWith {};
                if !((missionNamespace getVariable ["MWF_CurrentGrandOperation", ""]) isEqualTo _key) exitWith {
                    [_key, _token] call _cleanupForKey;
                };

                private _center = _record getOrDefault ["center", [0,0,0]];
                private _objectivePos = _record getOrDefault ["objectivePos", _center];
                private _radius = _record getOrDefault ["radius", 30];
                private _type = _record getOrDefault ["objectiveType", "reach"];
                private _players = allPlayers select { alive _x && {side group _x isEqualTo west} };
                private _nearPlayers = _players select { (_x distance2D _objectivePos) <= (_radius max 25) };
                private _units = _record getOrDefault ["units", []];
                private _objects = _record getOrDefault ["objects", []];
                private _primaryTarget = _record getOrDefault ["primaryTarget", objNull];

                [_units, _center] call _markDetected;

                private _complete = false;
                switch (_type) do {
                    case "reach": {
                        _complete = _nearPlayers isNotEqualTo [];
                    };
                    case "extract": {
                        _complete = _nearPlayers isNotEqualTo [];
                    };
                    case "meet_informant": {
                        _complete = _nearPlayers isNotEqualTo [];
                    };
                    case "interact": {
                        private _closePlayers = _players select { !isNull _primaryTarget && {_x distance _primaryTarget <= 4} };
                        if (_closePlayers isNotEqualTo []) then {
                            private _started = _record getOrDefault ["interactStartedAt", -1];
                            if (_started < 0) then {
                                _record set ["interactStartedAt", serverTime];
                                _map set [_key, _record];
                                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
                            } else {
                                _complete = (serverTime - _started) >= (_record getOrDefault ["interactionTime", 5]);
                            };
                        } else {
                            if ((_record getOrDefault ["interactStartedAt", -1]) >= 0) then {
                                _record set ["interactStartedAt", -1];
                                _map set [_key, _record];
                                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
                            };
                        };
                    };
                    case "secure_object": {
                        private _closePlayers = _players select { !isNull _primaryTarget && {_x distance _primaryTarget <= 4} };
                        if (_closePlayers isNotEqualTo []) then {
                            private _started = _record getOrDefault ["interactStartedAt", -1];
                            if (_started < 0) then {
                                _record set ["interactStartedAt", serverTime];
                                _map set [_key, _record];
                                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
                            } else {
                                _complete = (serverTime - _started) >= (_record getOrDefault ["interactionTime", 5]);
                            };
                        } else {
                            if ((_record getOrDefault ["interactStartedAt", -1]) >= 0) then {
                                _record set ["interactStartedAt", -1];
                                _map set [_key, _record];
                                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
                            };
                        };
                    };
                    case "destroy_multi": {
                        private _destroyed = { isNull _x || {!alive _x} || {(damage _x) > 0.9} } count _objects;
                        if (_key isEqualTo "SKY_GUARDIAN") then {
                            missionNamespace setVariable ["MWF_SkyGuardian_RadarsDestroyed", _destroyed min 3, true];
                        };
                        _complete = _destroyed >= (count _objects max 1);
                    };
                    case "kill_officer": {
                        _complete = isNull _primaryTarget || {!alive _primaryTarget};
                    };
                    case "clear_area": {
                        _complete = ({ alive _x && {side _x isEqualTo east} && {(_x distance2D _center) <= (_radius + 10)} } count _units) <= 0 && {_nearPlayers isNotEqualTo []};
                    };
                    case "clear_hold": {
                        private _hostiles = ({ alive _x && {side _x isEqualTo east} && {(_x distance2D _center) <= (_radius + 10)} } count _units);
                        if (_hostiles <= 0 && {_nearPlayers isNotEqualTo []}) then {
                            private _holdStartedAt = _record getOrDefault ["holdStartedAt", -1];
                            if (_holdStartedAt < 0) then {
                                _record set ["holdStartedAt", serverTime];
                                _map set [_key, _record];
                                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
                            } else {
                                _complete = (serverTime - _holdStartedAt) >= (_record getOrDefault ["holdDuration", 20]);
                            };
                        } else {
                            if ((_record getOrDefault ["holdStartedAt", -1]) >= 0) then {
                                _record set ["holdStartedAt", -1];
                                _map set [_key, _record];
                                missionNamespace setVariable ["MWF_MainOperationBackend", _map, true];
                            };
                        };
                    };
                };

                if (_complete) exitWith {
                    [_taskId, "SUCCEEDED"] call BIS_fnc_taskSetState;
                    [_key, _token] call _cleanupForKey;
                };

                sleep 1;
            };
        };
        true
    };

    default { false };
};
