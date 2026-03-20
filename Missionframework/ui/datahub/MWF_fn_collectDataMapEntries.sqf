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

private _getDefinitionValue = {
    params ["_definition", "_key", "_default"];
    if !(_definition isEqualType []) exitWith { _default };

    private _index = _definition findIf {
        (_x isEqualType []) && {(count _x) >= 2} && {((_x # 0) isEqualType "") && {(_x # 0) isEqualTo _key}}
    };

    if (_index < 0) exitWith { _default };
    (_definition # _index) # 1
};

switch (_modeUpper) do {
    case "UPGRADES": {
        private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
        private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
        private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
        private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
        private _heliBuilt = (_heliClass isNotEqualTo "") && {({ typeOf _x isEqualTo _heliClass } count (nearestObjects [_mobPos, [_heliClass], 120])) > 0};
        private _jetBuilt = (_jetClass isNotEqualTo "") && {({ typeOf _x isEqualTo _jetClass } count (nearestObjects [_mobPos, [_jetClass], 120])) > 0};
        private _heliUnlocked = missionNamespace getVariable ["MWF_Unlock_Heli", false];
        private _jetUnlocked = missionNamespace getVariable ["MWF_Unlock_Jets", false];
        private _tier5Unlocked = missionNamespace getVariable ["MWF_Unlock_Tier5", false];
        private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];

        private _upgradeEntries = [
            [
                "Helicopter Uplink",
                [(_mobPos # 0) - 22, (_mobPos # 1) + 8, 0],
                createHashMapFromArray [
                    ["upgradeId", "HELI"],
                    ["requiredOperation", "Sky Guardian"],
                    ["description", "Unlocks helicopter logistics through a MOB-only upgrade structure."],
                    ["isUnlocked", _heliUnlocked],
                    ["isBuilt", _heliBuilt],
                    ["statusText", if (!_heliUnlocked) then {"Locked"} else {if (_heliBuilt) then {"Ready"} else {"Unlocked - Build Required"}}],
                    ["tooltipText", if (!_heliUnlocked) then {"Requires main operation: Sky Guardian."} else {if (_heliBuilt) then {"Helicopters are now available in the vehicle menu."} else {"Use Base Building at the MOB to place the helicopter uplink."}}},
                    ["actionMode", if (!_heliUnlocked) then {"LOCKED"} else {if (_heliBuilt) then {"VEHICLE_MENU"} else {"BASE_BUILDING"}}]
                ]
            ],
            [
                "Aircraft Control",
                [(_mobPos # 0) + 22, (_mobPos # 1) + 8, 0],
                createHashMapFromArray [
                    ["upgradeId", "JET"],
                    ["requiredOperation", "Point Blank"],
                    ["description", "Unlocks fixed-wing strike logistics through a MOB-only upgrade structure."],
                    ["isUnlocked", _jetUnlocked],
                    ["isBuilt", _jetBuilt],
                    ["statusText", if (!_jetUnlocked) then {"Locked"} else {if (_jetBuilt) then {"Ready"} else {"Unlocked - Build Required"}}],
                    ["tooltipText", if (!_jetUnlocked) then {"Requires main operation: Point Blank."} else {if (_jetBuilt) then {"Aircraft are now available in the vehicle menu."} else {"Use Base Building at the MOB to place the aircraft control building."}}},
                    ["actionMode", if (!_jetUnlocked) then {"LOCKED"} else {if (_jetBuilt) then {"VEHICLE_MENU"} else {"BASE_BUILDING"}}]
                ]
            ],
            [
                "Base Tier 5",
                [(_mobPos # 0), (_mobPos # 1) + 28, 0],
                createHashMapFromArray [
                    ["upgradeId", "TIER5"],
                    ["requiredOperation", "Apex Predator"],
                    ["description", "Extends the player base progression path to Tier 5. Vehicle presets may place special Tier 5 assets at the bottom of their categories."],
                    ["isUnlocked", _tier5Unlocked],
                    ["isBuilt", _tier5Unlocked && {_currentTier >= 5}],
                    ["statusText", if (!_tier5Unlocked) then {"Locked"} else {if (_currentTier >= 5) then {"Complete"} else {"Ready"}}],
                    ["tooltipText", if (!_tier5Unlocked) then {"Requires main operation: Apex Predator."} else {if (_currentTier >= 5) then {"Tier 5 base progression is active. Tier 5 preset entries now appear at the bottom of the vehicle menu categories."} else {"Use [ UPGRADE BASE TIER ] at the Command Network to advance from Tier 4 to Tier 5."}}],
                    ["actionMode", if (_tier5Unlocked) then {"TIER5_INFO"} else {"LOCKED"}]
                ]
            ]
        ];

        {
            _entries pushBack ["UPGRADE", _x # 0, _x # 1, _x # 2];
        } forEach _upgradeEntries;
    };

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
        private _activeMissions = + (missionNamespace getVariable ["MWF_ActiveSideMissions", []]);

        {
            _x params [
                ["_slotIndex", 0, [0]],
                ["_category", "", [""]],
                ["_difficulty", "", [""]],
                ["_missionId", 0, [0]],
                ["_missionKey", "", [""]],
                ["_missionPath", "", [""]],
                ["_position", [0,0,0], [[]]],
                ["_zoneId", "", [""]],
                ["_zoneName", "Unknown Area", [""]],
                ["_state", "available", [""]],
                ["_domain", "land", [""]],
                ["_slotMissionDefinition", [], [[]]]
            ];

            if (_position isEqualType [] && {(count _position) >= 2} && {!((_position # 0) == 0 && {(_position # 1) == 0})}) then {
                private _activeMissionIndex = _activeMissions findIf { (_x # 0) isEqualTo _missionKey };
                private _missionDefinition = if (_activeMissionIndex >= 0) then {
                    (_activeMissions # _activeMissionIndex) param [11, _slotMissionDefinition, [[]]]
                } else {
                    _slotMissionDefinition
                };

                private _rewardProfile = [_category, _difficulty] call MWF_fnc_getSideMissionRewardProfile;
                private _impactProfile = ["side", _category, _difficulty] call MWF_fnc_getMissionImpactProfile;

                private _title = [_missionDefinition, "title", format ["%1 | %2 | %3", toUpper _domain, toUpper _category, toUpper _difficulty]] call _getDefinitionValue;
                private _description = [_missionDefinition, "description", ""] call _getDefinitionValue;
                private _rewardSupplies = [_missionDefinition, "rewardSupplies", _rewardProfile param [0, 0]] call _getDefinitionValue;
                private _rewardIntel = [_missionDefinition, "rewardIntel", _rewardProfile param [1, 0]] call _getDefinitionValue;
                private _rewardThreat = [_missionDefinition, "rewardThreat", _impactProfile getOrDefault ["threatDelta", 0]] call _getDefinitionValue;
                private _rewardTier = [_missionDefinition, "rewardTier", _impactProfile getOrDefault ["tierDelta", 0]] call _getDefinitionValue;
                private _rewardThreatUndercover = [_missionDefinition, "rewardThreatUndercover", _rewardThreat] call _getDefinitionValue;
                private _fallbackSupplies = [_missionDefinition, "fallbackSupplies", 0] call _getDefinitionValue;
                private _fallbackIntel = [_missionDefinition, "fallbackIntel", 0] call _getDefinitionValue;
                private _allowUndercover = [_missionDefinition, "allowUndercover", false] call _getDefinitionValue;
                private _notes = [_missionDefinition, "notes", ""] call _getDefinitionValue;

                _entries pushBack [
                    "SIDE_MISSION",
                    _title,
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
                        ["displayLabel", _title],
                        ["description", _description],
                        ["missionDefinition", _missionDefinition],
                        ["rewardSupplies", _rewardSupplies],
                        ["rewardIntel", _rewardIntel],
                        ["rewardThreat", _rewardThreat],
                        ["rewardTier", _rewardTier],
                        ["rewardThreatUndercover", _rewardThreatUndercover],
                        ["fallbackSupplies", _fallbackSupplies],
                        ["fallbackIntel", _fallbackIntel],
                        ["allowUndercover", _allowUndercover],
                        ["notes", _notes]
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
