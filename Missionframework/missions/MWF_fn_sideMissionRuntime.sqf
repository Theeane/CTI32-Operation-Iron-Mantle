/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_sideMissionRuntime
    Project: Military War Framework

    Description:
    Generic runtime bridge for structured side missions.
    Until fully-authored per-mission world logic exists, this helper provides a
    concrete objective anchor, map marker, and authoritative completion path.
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

private _objectiveClassForCategory = {
    params [["_category", "disrupt", [""]]];
    switch (toLower _category) do {
        case "intel": { "Land_Laptop_unfolded_F" };
        case "supply": { "CargoNet_01_box_F" };
        default { "Land_PortableGenerator_01_F" };
    };
};

private _actionTextForCategory = {
    params [["_category", "disrupt", [""]]];
    switch (toLower _category) do {
        case "intel": { "Search for Intel" };
        case "supply": { "Secure Supplies" };
        default { "Sabotage Site" };
    };
};

switch (toUpper _mode) do {
    case "START": {
        _arg1 params [
            ["_missionKey", "", [""]],
            ["_category", "disrupt", [""]],
            ["_position", [0,0,0], [[]]],
            ["_zoneName", "Unknown Area", [""]],
            ["_taskId", "", [""]],
            ["_compositionPath", "", [""]]
        ];

        if (_missionKey isEqualTo "" || {_position isEqualTo []}) exitWith { false };
        private _existing = _runtimeMap getOrDefault [_missionKey, createHashMap];
        if (_existing isEqualType createHashMap && {!(_existing isEqualTo createHashMap)}) exitWith { true };

        private _className = [_category] call _objectiveClassForCategory;
        private _spawnPos = +_position;
        _spawnPos set [2, 0];
        private _objective = createVehicle [_className, _spawnPos, [], 0, "NONE"];
        _objective setPosATL _spawnPos;
        _objective setVariable ["MWF_SideMissionKey", _missionKey, true];
        _objective setVariable ["MWF_SideMissionCategory", _category, true];
        _objective setVariable ["MWF_SideMissionObjective", true, true];
        _objective enableDynamicSimulation true;

        private _markerName = format ["MWF_SM_%1", _missionKey];
        deleteMarker _markerName;
        private _marker = createMarker [_markerName, _spawnPos];
        _marker setMarkerShape "ICON";
        _marker setMarkerType "mil_objective";
        _marker setMarkerColor "ColorWEST";
        _marker setMarkerText format ["%1", _zoneName];

        private _actionText = [_category] call _actionTextForCategory;
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

        private _record = createHashMapFromArray [
            ["objective", _objective],
            ["marker", _markerName],
            ["taskId", _taskId],
            ["position", _position],
            ["zoneName", _zoneName],
            ["category", _category],
            ["compositionPath", _compositionPath]
        ];
        _runtimeMap set [_missionKey, _record];
        missionNamespace setVariable ["MWF_SideMissionRuntime", _runtimeMap, true];

        diag_log format ["[MWF Missions] Runtime objective created for %1 at %2. Composition path: %3", _missionKey, _spawnPos, _compositionPath];
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

        _objective setVariable ["MWF_SideMissionUsed", true, true];

        private _undercover = false;
        if (!isNull _caller && {!isNil "MWF_fnc_checkUndercover"}) then {
            private _result = [_caller] call MWF_fnc_checkUndercover;
            if (_result isEqualType false) then { _undercover = _result; };
        };

        private _note = switch (toLower (_record getOrDefault ["category", "disrupt"])) do {
            case "intel": { "Field intelligence recovered." };
            case "supply": { "Supply cache secured." };
            default { "Enemy relay sabotaged." };
        };

        [_missionKey, _undercover, _note] call MWF_fnc_completeSideMission;
        true
    };

    case "CLEANUP": {
        private _missionKey = _arg1;
        if (_missionKey isEqualTo "") exitWith { false };
        private _record = _runtimeMap getOrDefault [_missionKey, createHashMap];
        if (_record isEqualType createHashMap && {!(_record isEqualTo createHashMap)}) then {
            private _objective = _record getOrDefault ["objective", objNull];
            private _markerName = _record getOrDefault ["marker", ""];
            if (!isNull _objective) then { deleteVehicle _objective; };
            if (_markerName isNotEqualTo "") then { deleteMarker _markerName; };
        };
        _runtimeMap deleteAt _missionKey;
        missionNamespace setVariable ["MWF_SideMissionRuntime", _runtimeMap, true];
        true
    };

    default { false };
};
