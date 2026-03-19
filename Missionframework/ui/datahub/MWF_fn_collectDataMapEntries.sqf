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

private _categoryLabel = {
    params [["_category", "", [""]]];
    switch (toLower _category) do {
        case "disrupt": {"Disrupt"};
        case "supply": {"Supply"};
        case "intel": {"Intel"};
        default {
            if (_category isEqualTo "") then {
                "Mission"
            } else {
                toUpper (_category select [0, 1]) + (_category select [1])
            }
        };
    }
};

private _extractStringValue = {
    params ["_source", "_key", "_default"];
    private _needle = format ['["%1", "', _key];
    private _idx = _source find _needle;
    if (_idx < 0) exitWith { _default };

    private _start = _idx + count _needle;
    private _tail = _source select [_start];
    private _end = _tail find '"]';
    if (_end < 0) exitWith { _default };
    _tail select [0, _end]
};

private _extractNumberValue = {
    params ["_source", "_key", "_default"];
    private _needle = format ['["%1", ', _key];
    private _idx = _source find _needle;
    if (_idx < 0) exitWith { _default };

    private _start = _idx + count _needle;
    private _tail = _source select [_start];
    private _end = _tail find ']';
    if (_end < 0) exitWith { _default };

    private _raw = [_tail select [0, _end], " ", ""] call BIS_fnc_replaceString;
    parseNumber _raw
};

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
                ["_missionId", "", [0,""]],
                ["_missionKey", "", [""]],
                ["_missionPath", "", [""]],
                ["_position", [0,0,0], [[]]],
                ["_zoneId", "", [""]],
                ["_zoneName", "Unknown Area", [""]],
                ["_state", "available", [""]],
                ["_domain", "land", [""]]
            ];

            if (_position isEqualType [] && {(count _position) >= 2} && {!((_position # 0) == 0 && {(_position # 1) == 0})}) then {
                private _title = format ["%1 %2", toUpper _domain, [_category] call _categoryLabel];
                private _description = format ["Accept a %1 %2 mission operating near %3.", _difficulty, [_category] call _categoryLabel, _zoneName];
                private _rewardSupplies = 0;
                private _rewardIntel = 0;
                private _rewardThreat = 0;
                private _rewardTier = 0;

                if (_missionPath isNotEqualTo "" && {fileExists _missionPath}) then {
                    private _source = loadFile _missionPath;
                    if (_source isNotEqualTo "") then {
                        _title = [_source, "title", _title] call _extractStringValue;
                        _description = [_source, "description", _description] call _extractStringValue;
                        _rewardSupplies = [_source, "rewardSupplies", 0] call _extractNumberValue;
                        _rewardIntel = [_source, "rewardIntel", 0] call _extractNumberValue;
                        _rewardThreat = [_source, "rewardThreat", 0] call _extractNumberValue;
                        _rewardTier = [_source, "rewardTier", 0] call _extractNumberValue;
                    };
                };

                private _rewardParts = [];
                if (_rewardSupplies > 0) then { _rewardParts pushBack format ["%1 Supplies", _rewardSupplies]; };
                if (_rewardIntel > 0) then { _rewardParts pushBack format ["%1 Intel", _rewardIntel]; };
                if (_rewardThreat > 0) then { _rewardParts pushBack format ["%1 Threat", _rewardThreat]; };
                if (_rewardTier > 0) then { _rewardParts pushBack format ["%1 Tier", _rewardTier]; };
                private _rewardText = if (_rewardParts isEqualTo []) then {
                    "Rewards vary by mission state."
                } else {
                    _rewardParts joinString " / "
                };

                private _displayLabel = format ["%1 | %2 | %3", toUpper _domain, toUpper _category, toUpper _difficulty];
                _entries pushBack [
                    "SIDE_MISSION",
                    _displayLabel,
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
                        ["displayLabel", _displayLabel],
                        ["title", _title],
                        ["description", _description],
                        ["rewardText", _rewardText],
                        ["statusText", if (_state isEqualTo "active") then {"Active"} else {"Available"}],
                        ["tooltipText", if (_state isEqualTo "active") then {format ["%1 is already active.", _title]} else {format ["Accept %1 near %2.", _title, _zoneName]}],
                        ["acceptLabel", "Accept Mission"],
                        ["isAvailable", !(_state isEqualTo "active")]
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
                        ["registryIndex", _forEachIndex],
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
                        ["active", _state getOrDefault ["isActive", false]],
                        ["acceptLabel", "Accept Operation"]
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
                    ["source", _source],
                    ["title", _label],
                    ["description", "Select this respawn point and then confirm redeploy."],
                    ["statusText", "Selectable"],
                    ["tooltipText", format ["Select %1 as your redeploy destination.", _label]],
                    ["acceptLabel", "Select Redeploy"],
                    ["isAvailable", true]
                ]
            ];
        } forEach ([] call MWF_fnc_collectRespawnPoints);
    };
};

_entries
