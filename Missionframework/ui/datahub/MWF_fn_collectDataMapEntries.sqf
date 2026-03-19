/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_collectDataMapEntries
    Project: Military War Framework

    Description:
    Builds a render-ready dataset for the unified command/data map.
    Modes:
    - ZONES
    - SIDE_MISSIONS
    - MAIN_OPERATIONS
    - REDEPLOY

    Return:
    Array of entry records.
*/

params [
    ["_mode", "ZONES", [""]]
];

private _modeUpper = toUpper _mode;
private _entries = [];

switch (_modeUpper) do {
    case "UPGRADES";
    case "ZONES": {
        {
            if (!isNull _x) then {
                private _zoneId = _x getVariable ["MWF_zoneID", _x call BIS_fnc_netId];
                private _zoneName = _x getVariable ["MWF_zoneName", "Unknown Zone"];
                private _zoneType = toLower (_x getVariable ["MWF_zoneType", "town"]);
                private _zonePos = getPosATL _x;
                private _zoneRange = (_x getVariable ["MWF_zoneRange", 300]) max 150;
                private _ownerState = toLower (_x getVariable ["MWF_zoneOwnerState", if (_x getVariable ["MWF_isCaptured", false]) then {"player"} else {"enemy"}]);
                private _underAttack = _x getVariable ["MWF_underAttack", false];
                private _contested = _x getVariable ["MWF_contested", false];

                _entries pushBack [
                    "ZONE",
                    _zoneName,
                    _zonePos,
                    createHashMapFromArray [
                        ["zoneId", _zoneId],
                        ["zoneType", _zoneType],
                        ["range", _zoneRange],
                        ["ownerState", _ownerState],
                        ["underAttack", _underAttack],
                        ["contested", _contested]
                    ]
                ];
            };
        } forEach (missionNamespace getVariable ["MWF_all_mission_zones", []]);
    };

    case "SIDE_MISSIONS": {
        {
            _x params [
                ["_slotIndex", 0, [0]],
                ["_category", "", [""]],
                ["_difficulty", "", [""]],
                ["_missionId", "", [""]],
                ["_missionKey", "", [""]],
                ["_missionPath", "", [""]],
                ["_position", [0,0,0], [[]]],
                ["_zoneId", "", [""]],
                ["_zoneName", "Unknown Area", [""]],
                ["_state", "available", [""]],
                ["_domain", "land", [""]]
            ];

            if (_position isEqualType [] && {(count _position) >= 2} && {!((_position # 0) == 0 && {(_position # 1) == 0})}) then {
                _entries pushBack [
                    "SIDE_MISSION",
                    format ["%1 | %2 | %3", toUpper _domain, toUpper _category, toUpper _difficulty],
                    _position,
                    createHashMapFromArray [
                        ["slotIndex", _slotIndex],
                        ["domain", _domain],
                        ["category", _category],
                        ["difficulty", _difficulty],
                        ["missionId", _missionId],
                        ["missionKey", _missionKey],
                        ["missionPath", _missionPath],
                        ["zoneId", _zoneId],
                        ["zoneName", _zoneName],
                        ["state", _state],
                        ["displayLabel", format ["%1 | %2 | %3", toUpper _domain, toUpper _category, toUpper _difficulty]]
                    ]
                ];
            };
        } forEach (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
    };

    case "MAIN_OPERATIONS": {
        private _ops = [] call MWF_fnc_getMainOperationRegistry;
        private _placements = + (missionNamespace getVariable ["MWF_GrandOperationSessionPlacements", []]);

        {
            private _entry = _x;
            _entry params ["_key", "_title", "_desc", "_fnName", "_impactId", "_effectType", "_effectText", "_fallbackText", "_cooldownSeconds"];
            private _placement = if (_placements isEqualTo []) then {
                []
            } else {
                _placements # (_forEachIndex mod (count _placements))
            };

            private _pos = [0,0,0];
            private _zoneId = "";
            private _zoneName = "Unknown Area";
            if !(_placement isEqualTo []) then {
                _pos = _placement param [1, [0,0,0], [[]]];
                _zoneId = _placement param [2, "", [""]];
                _zoneName = _placement param [3, "Unknown Area", [""]];
            };

            if (_pos isEqualType [] && {(count _pos) >= 2} && {!((_pos # 0) == 0 && {(_pos # 1) == 0})}) then {
                private _state = [_key, _entry] call MWF_fnc_getMainOperationState;
                _entries pushBack [
                    "MAIN_OPERATION",
                    _title,
                    _pos,
                    createHashMapFromArray [
                        ["key", _key],
                        ["title", _title],
                        ["description", _desc],
                        ["zoneId", _zoneId],
                        ["zoneName", _zoneName],
                        ["impactId", _impactId],
                        ["effectType", _effectType],
                        ["effectText", _effectText],
                        ["fallbackText", _fallbackText],
                        ["cooldownSeconds", _cooldownSeconds],
                        ["status", _state getOrDefault ["state", "unknown"]],
                        ["statusText", _state getOrDefault ["statusText", "Unknown"]],
                        ["tooltipText", _state getOrDefault ["tooltipText", ""]],
                        ["isAvailable", _state getOrDefault ["isAvailable", false]],
                        ["isActive", _state getOrDefault ["isActive", false]],
                        ["isCoolingDown", _state getOrDefault ["isCoolingDown", false]],
                        ["cooldownRemaining", _state getOrDefault ["cooldownRemaining", 0]],
                        ["readyAt", _state getOrDefault ["readyAt", 0]],
                        ["active", _state getOrDefault ["isActive", false]]
                    ]
                ];
            };
        } forEach _ops;
    };

    case "SUPPORT": {
        private _supportEntries = ["GET_ENTRIES"] call MWF_fnc_terminal_support;
        private _basePos = if (!isNull player) then { getPosATL player } else { getMarkerPos "respawn_west" };
        private _offsets = [[0,0,0],[45,0,0],[-45,0,0],[90,0,0],[-90,0,0]];
        {
            _x params [["_index",0,[0]],["_varName","",[""]],["_name","",[""]],["_vehicleClass","",[""]],["_unitClasses",[],[[]]],["_price",0,[0]],["_minTier",1,[0]]];
            private _ofs = _offsets param [_forEachIndex, [(_forEachIndex * 40), 0, 0], [[]]];
            private _pos = _basePos vectorAdd _ofs;
            _entries pushBack ["SUPPORT", _name, _pos, createHashMapFromArray [["index", _index],["varName", _varName],["vehicleClass", _vehicleClass],["unitClasses", _unitClasses],["price", _price],["minTier", _minTier],["description", format ["%1 | Cost %2 | Tier %3", if (_vehicleClass isEqualTo "") then {"Infantry only"} else {_vehicleClass}, _price, _minTier]] ]];
        } forEach _supportEntries;
    };

    case "REDEPLOY": {
        {
            _x params ["_kind", "_label", "_pos", ["_source", objNull, [objNull]]];
            _entries pushBack [
                "RESPAWN",
                _label,
                _pos,
                createHashMapFromArray [
                    ["kind", _kind],
                    ["source", _source]
                ]
            ];
        } forEach ([] call MWF_fnc_collectRespawnPoints);
    };
};

_entries
