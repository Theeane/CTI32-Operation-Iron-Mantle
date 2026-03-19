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
        private _ops = [
            ["SKY_GUARDIAN", "Sky Guardian", "Restore aerial detection control."],
            ["POINT_BLANK", "Point Blank", "Break the missile complex and unlock Jets."],
            ["SEVERED_NERVE", "Severed Nerve", "Disrupt the enemy's operational nerve center."],
            ["STASIS_STRIKE", "Stasis Strike", "Freeze enemy momentum with precision."],
            ["STEEL_RAIN", "Steel Rain", "Cripple enemy artillery and heavy support."],
            ["APEX_PREDATOR", "Apex Predator", "Final escalation toward Tier 5 dominance."]
        ];

        private _placements = + (missionNamespace getVariable ["MWF_GrandOperationSessionPlacements", []]);
        private _currentKey = missionNamespace getVariable ["MWF_CurrentGrandOperation", ""];
        private _active = missionNamespace getVariable ["MWF_GrandOperationActive", false];

        {
            _x params ["_key", "_title", "_desc"];
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
                        ["active", _active && {_currentKey isEqualTo _key}]
                    ]
                ];
            };
        } forEach _ops;
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
