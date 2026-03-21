/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_sideMissionRuntime
    Project: Military War Framework

    Description:
    Category-aware runtime bridge for structured side missions.
    This version replaces the single-object placeholder with authored modern
    land mission sites: props, guards, area marker, and category-specific
    completion behavior.
*/

if (!isServer) exitWith { false };

params [
    ["_mode", "START", [""]],
    ["_arg1", [], [[], ""]],
    ["_arg2", objNull, [objNull]],
    ["_arg3", "", [""]]
];

private _runtimeMap = missionNamespace getVariable ["MWF_SideMissionRuntime", createHashMap];
if (isNil "_runtimeMap" || { !(_runtimeMap isEqualType createHashMap) }) then {
    _runtimeMap = createHashMap;
};

private _getDefinitionValue = {
    params ["_definition", "_key", "_default"];
    if !(_definition isEqualType []) exitWith { _default };
    private _index = _definition findIf {
        (_x isEqualType []) && {(count _x) >= 2} && {((_x # 0) isEqualType "") && {(_x # 0) isEqualTo _key}}
    };
    if (_index < 0) exitWith { _default };
    (_definition # _index) # 1
};

private _resolveClass = {
    params ["_candidates", ["_fallback", "Land_PortableGenerator_01_F", [""]]];
    {
        if (isClass (configFile >> "CfgVehicles" >> _x)) exitWith { _x };
    } forEach _candidates;
    _fallback
};

private _objectiveClassForCategory = {
    params [["_category", "disrupt", [""]], ["_variant", "", [""]]];
    private _categoryLower = toLower _category;
    private _variantLower = toLower _variant;

    switch (_categoryLower) do {
        case "intel": {
            switch (_variantLower) do {
                case "checkpoint_logs": { [["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "briefcase": { [["Land_Laptop_unfolded_F", "Land_DataTerminal_01_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "courier_terminal": { [["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "signals": { [["Land_Laptop_unfolded_F", "Land_DataTerminal_01_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "counterinsurgency": { [["Land_Laptop_unfolded_F", "Land_DataTerminal_01_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "uav": { [["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "comms_bunker": { [["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "airdefense": { [["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                case "encryption": { [["Land_DataTerminal_01_F", "Land_Laptop_unfolded_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
                default { [["Land_Laptop_unfolded_F", "Land_DataTerminal_01_F"], "Land_Laptop_unfolded_F"] call _resolveClass };
            };
        };
        case "supply": {
            switch (_variantLower) do {
                case "fuel": { [["CargoNet_01_barrels_F", "CargoNet_01_box_F"], "CargoNet_01_box_F"] call _resolveClass };
                case "ammo": { [["Box_NATO_AmmoVeh_F", "CargoNet_01_box_F"], "CargoNet_01_box_F"] call _resolveClass };
                case "siege": { [["Box_NATO_AmmoVeh_F", "CargoNet_01_box_F"], "CargoNet_01_box_F"] call _resolveClass };
                default { [["CargoNet_01_box_F", "Box_NATO_AmmoVeh_F"], "CargoNet_01_box_F"] call _resolveClass };
            };
        };
        default {
            switch (_variantLower) do {
                case "fuel_pumps": { [["Land_FuelStation_01_pump_F", "Land_PortableGenerator_01_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
                case "relay_mast": { [["Land_TTowerSmall_1_F", "Land_PortableGenerator_01_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
                case "command_relay": { [["Land_TTowerSmall_1_F", "Land_DataTerminal_01_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
                case "radar_service": { [["Land_TTowerBig_1_F", "Land_TTowerSmall_1_F", "Land_PortableGenerator_01_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
                case "hq_spine": { [["Land_DataTerminal_01_F", "Land_PortableGenerator_01_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
                case "warhead_rig": { [["Land_Device_assembled_F", "Land_PortableGenerator_01_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
                default { [["Land_PortableGenerator_01_F", "Land_Device_assembled_F"], "Land_PortableGenerator_01_F"] call _resolveClass };
            };
        };
    }
};

private _decorOffsetsForMission = {
    params [["_category", "disrupt", [""]], ["_variant", "", [""]]];
    private _categoryLower = toLower _category;
    private _variantLower = toLower _variant;

    switch (_categoryLower) do {
        case "intel": {
            switch (_variantLower) do {
                case "briefcase": {
                    [
                        [[1.5, 0.3, 0], "Land_MapBoard_F"],
                        [[-1.4, -0.6, 0], "Land_PortableDesk_01_black_F"],
                        [[0.2, 1.8, 0], "Land_File_research_F"]
                    ]
                };
                case "checkpoint_logs": {
                    [
                        [[1.7, 0.2, 0], "Land_MapBoard_F"],
                        [[-1.3, -0.9, 0], "Land_PortableDesk_01_black_F"],
                        [[0.6, 1.7, 0], "Land_File_research_F"]
                    ]
                };
                case "courier_terminal": {
                    [
                        [[1.7, 0.0, 0], "Land_PortableDesk_01_black_F"],
                        [[-1.3, -0.8, 0], "Land_File_research_F"],
                        [[0.2, 1.8, 0], "Land_MapBoard_F"]
                    ]
                };
                case "signals": {
                    [
                        [[1.6, 0.2, 0], "Land_PortableGenerator_01_F"],
                        [[-1.5, -0.8, 0], "Land_PortableDesk_01_black_F"],
                        [[0.5, 1.9, 0], "Land_File_research_F"]
                    ]
                };
                case "counterinsurgency": {
                    [
                        [[1.6, 0.2, 0], "Land_MapBoard_F"],
                        [[-1.5, -0.8, 0], "Land_File_research_F"],
                        [[0.5, 1.9, 0], "Land_PortableDesk_01_black_F"]
                    ]
                };
                case "uav": {
                    [
                        [[1.6, 0.2, 0], "Land_PortableGenerator_01_F"],
                        [[-1.5, -0.8, 0], "Land_MapBoard_F"],
                        [[0.5, 1.9, 0], "Land_File_research_F"]
                    ]
                };
                case "comms_bunker": {
                    [
                        [[1.6, 0.2, 0], "Land_PortableGenerator_01_F"],
                        [[-1.5, -0.8, 0], "Land_PortableDesk_01_black_F"],
                        [[0.5, 1.9, 0], "Land_MapBoard_F"]
                    ]
                };
                case "airdefense": {
                    [
                        [[1.6, 0.2, 0], "Land_MapBoard_F"],
                        [[-1.5, -0.8, 0], "Land_PortableGenerator_01_F"],
                        [[0.5, 1.9, 0], "Land_File_research_F"]
                    ]
                };
                case "encryption": {
                    [
                        [[1.6, 0.2, 0], "Land_PortableDesk_01_black_F"],
                        [[-1.5, -0.8, 0], "Land_PortableGenerator_01_F"],
                        [[0.5, 1.9, 0], "Land_File_research_F"]
                    ]
                };
                default {
                    [
                        [[1.8, 0.2, 0], "Land_MapBoard_F"],
                        [[-1.6, -0.8, 0], "Land_PortableDesk_01_black_F"],
                        [[-0.6, 1.6, 0], "Land_File_research_F"]
                    ]
                };
            };
        };
        case "supply": {
            switch (_variantLower) do {
                case "medical": {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_box_F"],
                        [[-1.8, -0.7, 0], "CargoNet_01_box_F"],
                        [[0.3, 2.0, 0], "Land_Pallet_MilBoxes_F"]
                    ]
                };
                case "fuel": {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_barrels_F"],
                        [[-1.8, -0.7, 0], "Land_CanisterFuel_F"],
                        [[0.3, 2.0, 0], "CargoNet_01_box_F"]
                    ]
                };
                case "relief": {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_box_F"],
                        [[-1.8, -0.7, 0], "Land_Pallet_MilBoxes_F"],
                        [[0.3, 2.0, 0], "CargoNet_01_box_F"]
                    ]
                };
                case "ammo": {
                    [
                        [[1.9, 0.4, 0], "Box_NATO_AmmoVeh_F"],
                        [[-1.8, -0.7, 0], "CargoNet_01_box_F"],
                        [[0.3, 2.0, 0], "Land_Pallet_MilBoxes_F"]
                    ]
                };
                case "hub": {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_box_F"],
                        [[-1.8, -0.7, 0], "Box_NATO_AmmoVeh_F"],
                        [[0.3, 2.0, 0], "Land_Pallet_MilBoxes_F"]
                    ]
                };
                case "convoy": {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_box_F"],
                        [[-1.8, -0.7, 0], "CargoNet_01_barrels_F"],
                        [[0.3, 2.0, 0], "Land_CanisterFuel_F"]
                    ]
                };
                case "armor_node": {
                    [
                        [[1.9, 0.4, 0], "Box_NATO_AmmoVeh_F"],
                        [[-1.8, -0.7, 0], "CargoNet_01_box_F"],
                        [[0.3, 2.0, 0], "Land_PortableGenerator_01_F"]
                    ]
                };
                case "siege": {
                    [
                        [[1.9, 0.4, 0], "Box_NATO_AmmoVeh_F"],
                        [[-1.8, -0.7, 0], "Box_NATO_AmmoVeh_F"],
                        [[0.3, 2.0, 0], "Land_Pallet_MilBoxes_F"]
                    ]
                };
                case "sustainment": {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_box_F"],
                        [[-1.8, -0.7, 0], "Land_Pallet_MilBoxes_F"],
                        [[0.3, 2.0, 0], "CargoNet_01_barrels_F"]
                    ]
                };
                default {
                    [
                        [[1.9, 0.4, 0], "CargoNet_01_box_F"],
                        [[-1.8, -0.7, 0], "Box_NATO_AmmoVeh_F"],
                        [[0.3, 2.0, 0], "Land_Pallet_MilBoxes_F"]
                    ]
                };
            };
        };
        default {
            switch (_variantLower) do {
                case "fuel_pumps": {
                    [
                        [[2.2, 0.0, 0], "Land_CanisterFuel_F"],
                        [[-1.8, 1.1, 0], "Land_PortableGenerator_01_F"],
                        [[0.9, -2.0, 0], "Land_CanisterFuel_F"]
                    ]
                };
                case "relay_mast": {
                    [
                        [[2.1, 0.0, 0], "Land_Device_assembled_F"],
                        [[-1.7, 1.0, 0], "Land_PortableGenerator_01_F"],
                        [[0.8, -1.8, 0], "Land_ToolTrolley_02_F"]
                    ]
                };
                case "artillery_power": {
                    [
                        [[2.1, 0.0, 0], "Land_PortableGenerator_01_F"],
                        [[-1.7, 1.0, 0], "Land_CanisterFuel_F"],
                        [[0.8, -1.8, 0], "Land_ToolTrolley_02_F"]
                    ]
                };
                case "motor_pool": {
                    [
                        [[2.1, 0.0, 0], "Land_CanisterFuel_F"],
                        [[-1.7, 1.0, 0], "Land_PortableGenerator_01_F"],
                        [[0.8, -1.8, 0], "Land_Pallet_MilBoxes_F"]
                    ]
                };
                case "command_relay": {
                    [
                        [[2.1, 0.0, 0], "Land_Device_assembled_F"],
                        [[-1.7, 1.0, 0], "Land_PortableGenerator_01_F"],
                        [[0.8, -1.8, 0], "Land_MapBoard_F"]
                    ]
                };
                case "radar_service": {
                    [
                        [[2.1, 0.0, 0], "Land_PortableGenerator_01_F"],
                        [[-1.7, 1.0, 0], "Land_Device_assembled_F"],
                        [[0.8, -1.8, 0], "Land_ToolTrolley_02_F"]
                    ]
                };
                case "warhead_rig": {
                    [
                        [[2.1, 0.0, 0], "Land_Device_assembled_F"],
                        [[-1.7, 1.0, 0], "Land_Pallet_MilBoxes_F"],
                        [[0.8, -1.8, 0], "Land_CanisterFuel_F"]
                    ]
                };
                case "hq_spine": {
                    [
                        [[2.1, 0.0, 0], "Land_Device_assembled_F"],
                        [[-1.7, 1.0, 0], "Land_PortableGenerator_01_F"],
                        [[0.8, -1.8, 0], "Land_MapBoard_F"]
                    ]
                };
                default {
                    [
                        [[2.2, 0.0, 0], "Land_CanisterFuel_F"],
                        [[-1.8, 1.1, 0], "Land_PortableGenerator_01_F"],
                        [[0.9, -2.0, 0], "Land_ToolTrolley_02_F"]
                    ]
                };
            };
        };
    }
};

private _pickCivilianPool = {
    private _pool = missionNamespace getVariable ["MWF_CIV_Units", missionNamespace getVariable ["MWF_Civ_List", []]];
    if !(_pool isEqualType []) then { _pool = []; };
    if (_pool isEqualTo []) then { _pool = ["C_man_1"]; };
    _pool
};

private _spawnCivilianElement = {
    params ["_center", "_unitCount", "_radius"];
    private _units = [];
    private _groups = [];
    private _pool = call _pickCivilianPool;

    if (_pool isEqualTo []) exitWith { [_units, _groups] };

    private _group = createGroup [civilian, true];
    _groups pushBack _group;

    for "_i" from 1 to (_unitCount max 1) do {
        private _spawnPos = [_center, 10, _radius, 3, 0, 0.25, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        private _unitClass = selectRandom _pool;
        private _unit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
        _unit setBehaviour "SAFE";
        _unit setSpeedMode "LIMITED";
        _unit disableAI "TARGET";
        _unit disableAI "AUTOTARGET";
        _unit enableDynamicSimulation true;
        _units pushBack _unit;
    };

    {
        _x setBehaviour "SAFE";
        _x setSpeedMode "LIMITED";
        [_x, _center, (_radius max 15) min 40] call BIS_fnc_taskPatrol;
    } forEach _groups;

    [_units, _groups]
};

private _actionTextForCategory = {
    params [["_category", "disrupt", [""]], ["_missionDefinition", [], [[]]]];
    private _override = [_missionDefinition, "objectiveAction", ""] call _getDefinitionValue;
    if !(_override isEqualTo "") exitWith { _override };
    switch (toLower _category) do {
        case "intel": { "Download Intel" };
        case "supply": { "Secure Supplies" };
        default { "Plant Charges" };
    };
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
        _pool = missionNamespace getVariable ["MWF_Army_Infantry", []];
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

private _findObjectivePos = {
    params ["_center", ["_landOnly", true, [false]]];
    private _chosen = +_center;
    _chosen set [2, 0];
    for "_attempt" from 0 to 24 do {
        private _probe = [_center, 5, 55, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        if !(_probe isEqualTo _center) then {
            if (!_landOnly || {!surfaceIsWater _probe}) exitWith {
                _chosen = +_probe;
            };
        };
    };
    _chosen
};

private _spawnAmbientObject = {
    params ["_className", "_pos", ["_dir", -1, [0]], ["_allowDamage", false, [false]]];
    if !(isClass (configFile >> "CfgVehicles" >> _className)) exitWith { objNull };
    private _obj = createVehicle [_className, _pos, [], 0, "NONE"];
    _obj setPosATL _pos;
    if (_dir >= 0) then { _obj setDir _dir; };
    _obj allowDamage _allowDamage;
    _obj enableDynamicSimulation true;
    _obj
};

private _spawnGuardElement = {
    params ["_center", "_unitCount", "_radius", "_patrolRadius", ["_addOfficer", false, [false]]];
    private _units = [];
    private _groups = [];
    private _guardPool = call _pickGuardPool;

    private _group = createGroup [east, true];
    _groups pushBack _group;
    for "_i" from 1 to (_unitCount max 1) do {
        private _spawnPos = [_center, 8, _radius, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        private _unitClass = selectRandom _guardPool;
        private _unit = _group createUnit [_unitClass, _spawnPos, [], 0, "NONE"];
        if (!isNil "MWF_fnc_initInteractions") then {
            [_unit] call MWF_fnc_initInteractions;
        };
        _unit enableDynamicSimulation true;
        _units pushBack _unit;
    };

    if (_addOfficer) then {
        private _officerGroup = createGroup [east, true];
        _groups pushBack _officerGroup;
        private _officerPos = [_center, 4, 14, 3, 0, 0.35, 0, [], [_center, _center]] call BIS_fnc_findSafePos;
        private _officer = _officerGroup createUnit [call _pickOfficerClass, _officerPos, [], 0, "NONE"];
        if (!isNil "MWF_fnc_initInteractions") then {
            [_officer] call MWF_fnc_initInteractions;
        };
        _officer setRank "LIEUTENANT";
        _officer enableDynamicSimulation true;
        _units pushBack _officer;
    };

    {
        [_x, _center, _patrolRadius] call BIS_fnc_taskPatrol;
    } forEach _groups;

    [_units, _groups]
};

private _countHostiles = {
    params ["_units", "_center", ["_radius", 35, [0]]];
    ({ alive _x && {(_x distance2D _center) <= _radius} } count _units)
};

private _explodeObject = {
    params ["_objective"];
    if (isNull _objective) exitWith {};
    private _pos = getPosATL _objective;
    "Bo_GBU12_LGB" createVehicle _pos;
    _objective setDamage 1;
};

switch (toUpper _mode) do {
    case "START": {
        _arg1 params [
            ["_missionKey", "", [""]],
            ["_category", "disrupt", [""]],
            ["_difficulty", "easy", [""]],
            ["_missionId", 1, [0]],
            ["_position", [0,0,0], [[]]],
            ["_zoneName", "Unknown Area", [""]],
            ["_taskId", "", [""]],
            ["_compositionPath", "", [""]],
            ["_missionDefinition", [], [[]]]
        ];

        if (_missionKey isEqualTo "" || {_position isEqualTo []}) exitWith { false };
        private _existing = _runtimeMap getOrDefault [_missionKey, createHashMap];
        if (_existing isEqualType createHashMap && {!(_existing isEqualTo createHashMap)}) exitWith { true };

        private _variant = [_missionDefinition, "sceneVariant", ""] call _getDefinitionValue;
        private _actionText = [_category, _missionDefinition] call _actionTextForCategory;
        private _completionNote = [_missionDefinition, "completionNote", "Objective completed."] call _getDefinitionValue;
        private _clearRadius = [_missionDefinition, "clearRadius", switch (toLower _difficulty) do { case "hard": {45}; case "medium": {38}; default {32}; }] call _getDefinitionValue;
        private _guardCount = [_missionDefinition, "guardCount", switch (toLower _difficulty) do { case "hard": {8}; case "medium": {6}; default {4}; }] call _getDefinitionValue;
        private _patrolRadius = [_missionDefinition, "patrolRadius", switch (toLower _difficulty) do { case "hard": {70}; case "medium": {55}; default {40}; }] call _getDefinitionValue;
        private _addOfficer = [_missionDefinition, "addOfficer", (toLower _difficulty) in ["medium", "hard"]] call _getDefinitionValue;

        private _objectivePos = [_position, true] call _findObjectivePos;
        private _primaryClass = [_category, _variant] call _objectiveClassForCategory;
        private _primaryAllowDamage = (toLower _category) isEqualTo "disrupt";
        private _objective = [_primaryClass, _objectivePos, random 360, _primaryAllowDamage] call _spawnAmbientObject;
        if (isNull _objective) exitWith { false };
        _objective setVariable ["MWF_SideMissionKey", _missionKey, true];
        _objective setVariable ["MWF_SideMissionCategory", _category, true];
        _objective setVariable ["MWF_SideMissionObjective", true, true];
        _objective setVariable ["MWF_SideMissionUsed", false, true];

        private _props = [_objective];
        private _decorOffsets = [_category, _variant] call _decorOffsetsForMission;

        {
            _x params ["_ofs", "_class"];
            if (isClass (configFile >> "CfgVehicles" >> _class)) then {
                private _objPos = _objectivePos vectorAdd _ofs;
                private _obj = [_class, _objPos, random 360, false] call _spawnAmbientObject;
                if (!isNull _obj) then { _props pushBack _obj; };
            };
        } forEach _decorOffsets;

        private _guardData = [_objectivePos, _guardCount, (_clearRadius + 15), _patrolRadius, _addOfficer] call _spawnGuardElement;
        _guardData params ["_guardUnits", "_guardGroups"];

        private _civilianUnits = [];
        private _civilianGroups = [];
        if ([_missionDefinition, "usesCivilians", false] call _getDefinitionValue) then {
            private _civilianCount = switch (toLower _difficulty) do { case "hard": {3}; case "medium": {2}; default {2}; };
            private _civilianData = [_objectivePos, _civilianCount, (_clearRadius + 12)] call _spawnCivilianElement;
            _civilianData params ["_civilianUnits", "_civilianGroups"];
        };

        private _markerName = format ["MWF_SM_%1", _missionKey];
        deleteMarker _markerName;
        private _marker = createMarker [_markerName, _objectivePos];
        _marker setMarkerShape "ICON";
        _marker setMarkerType "mil_objective";
        _marker setMarkerColor "ColorWEST";
        _marker setMarkerText format ["%1", _zoneName];

        private _areaMarkerName = format ["MWF_SM_AREA_%1", _missionKey];
        deleteMarker _areaMarkerName;
        private _areaMarker = createMarker [_areaMarkerName, _objectivePos];
        _areaMarker setMarkerShape "ELLIPSE";
        _areaMarker setMarkerBrush "Border";
        _areaMarker setMarkerColor "ColorWEST";
        _areaMarker setMarkerSize [_clearRadius, _clearRadius];

        _objective addAction [
            format ["<t color='#7CC8FF'>%1</t>", _actionText],
            {
                params ["_target", "_caller", "_actionId", "_args"];
                _args params [["_missionKey", "", [""]]];
                ["INTERACT", _missionKey, _caller] remoteExecCall ["MWF_fnc_sideMissionRuntime", 2];
            },
            [_missionKey],
            1.5,
            true,
            true,
            "",
            "alive _target && !(_target getVariable ['MWF_SideMissionUsed', false])"
        ];

        if ((toLower _category) isEqualTo "disrupt") then {
            _objective addEventHandler ["Killed", {
                params ["_unit", "_killer"];
                private _missionKey = _unit getVariable ["MWF_SideMissionKey", ""];
                if !(_missionKey isEqualTo "") then {
                    ["AUTO_COMPLETE", _missionKey, _killer, "Target destroyed."] call MWF_fnc_sideMissionRuntime;
                };
            }];
        };

        private _record = createHashMapFromArray [
            ["objective", _objective],
            ["marker", _markerName],
            ["areaMarker", _areaMarkerName],
            ["taskId", _taskId],
            ["position", _objectivePos],
            ["zoneName", _zoneName],
            ["category", _category],
            ["difficulty", _difficulty],
            ["missionId", _missionId],
            ["compositionPath", _compositionPath],
            ["missionDefinition", _missionDefinition],
            ["props", _props],
            ["guards", _guardUnits],
            ["guardGroups", _guardGroups],
            ["civilians", _civilianUnits],
            ["civilianGroups", _civilianGroups],
            ["clearRadius", _clearRadius],
            ["completionNote", _completionNote],
            ["variant", _variant]
        ];
        _runtimeMap set [_missionKey, _record];
        missionNamespace setVariable ["MWF_SideMissionRuntime", _runtimeMap, true];

        diag_log format ["[MWF Missions] Runtime site created for %1 | Category: %2 | Difficulty: %3 | Guards: %4 | Composition path: %5", _missionKey, _category, _difficulty, count _guardUnits, _compositionPath];
        true
    };

    case "INTERACT": {
        private _missionKey = _arg1;
        private _caller = _arg2;
        if (_missionKey isEqualTo "") exitWith { false };

        private _record = _runtimeMap getOrDefault [_missionKey, createHashMap];
        if !(_record isEqualType createHashMap) exitWith { false };
        if (_record isEqualTo createHashMap) exitWith { false };

        private _objective = _record getOrDefault ["objective", objNull];
        if (isNull _objective) exitWith { false };
        if (_objective getVariable ["MWF_SideMissionUsed", false]) exitWith { false };
        if (!isNull _caller && {(_caller distance _objective) > 8}) exitWith { false };

        private _isUndercover = false;
        if (!isNull _caller && {!isNil "MWF_fnc_checkUndercover"}) then {
            private _result = [_caller] call MWF_fnc_checkUndercover;
            if (_result isEqualType false) then { _isUndercover = _result; };
        };

        private _guards = _record getOrDefault ["guards", []];
        private _clearRadius = _record getOrDefault ["clearRadius", 35];
        private _hostilesRemaining = [_guards, getPosATL _objective, _clearRadius] call _countHostiles;
        if (_hostilesRemaining > 0 && {!_isUndercover}) exitWith {
            if (!isNull _caller) then {
                [["MISSION SITE", format ["Area not secure. %1 hostile(s) remain near the objective.", _hostilesRemaining]], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
            };
            false
        };

        _objective setVariable ["MWF_SideMissionUsed", true, true];

        private _category = toLower (_record getOrDefault ["category", "disrupt"]);
        private _note = _record getOrDefault ["completionNote", "Objective completed."];
        if (_category isEqualTo "disrupt") then {
            [_objective] call _explodeObject;
        };

        [_missionKey, _isUndercover, _note] call MWF_fnc_completeSideMission;
        true
    };

    case "AUTO_COMPLETE": {
        private _missionKey = _arg1;
        if (_missionKey isEqualTo "") exitWith { false };

        private _record = _runtimeMap getOrDefault [_missionKey, createHashMap];
        if !(_record isEqualType createHashMap) exitWith { false };
        if (_record isEqualTo createHashMap) exitWith { false };

        private _objective = _record getOrDefault ["objective", objNull];
        if (!isNull _objective) then {
            if (_objective getVariable ["MWF_SideMissionUsed", false]) exitWith { false };
            _objective setVariable ["MWF_SideMissionUsed", true, true];
        };

        private _note = _record getOrDefault ["completionNote", "Target destroyed."];
        if (_arg3 isEqualType "" && {!(_arg3 isEqualTo "")}) then {
            _note = _arg3;
        };

        [_missionKey, false, _note] call MWF_fnc_completeSideMission;
        true
    };

    case "CLEANUP": {
        private _missionKey = _arg1;
        if (_missionKey isEqualTo "") exitWith { false };
        private _record = _runtimeMap getOrDefault [_missionKey, createHashMap];
        if (_record isEqualType createHashMap && {!(_record isEqualTo createHashMap)}) then {
            {
                if (!isNull _x) then { deleteVehicle _x; };
            } forEach (_record getOrDefault ["props", []]);
            {
                if (!isNull _x) then { deleteVehicle _x; };
            } forEach (_record getOrDefault ["guards", []]);
            {
                if (!isNull _x) then { deleteGroup _x; };
            } forEach (_record getOrDefault ["guardGroups", []]);
            {
                if (!isNull _x) then { deleteVehicle _x; };
            } forEach (_record getOrDefault ["civilians", []]);
            {
                if (!isNull _x) then { deleteGroup _x; };
            } forEach (_record getOrDefault ["civilianGroups", []]);

            private _markerName = _record getOrDefault ["marker", ""];
            private _areaMarkerName = _record getOrDefault ["areaMarker", ""];
            if (_markerName isNotEqualTo "") then { deleteMarker _markerName; };
            if (_areaMarkerName isNotEqualTo "") then { deleteMarker _areaMarkerName; };
        };
        _runtimeMap deleteAt _missionKey;
        missionNamespace setVariable ["MWF_SideMissionRuntime", _runtimeMap, true];
        true
    };

    default { false };
};
