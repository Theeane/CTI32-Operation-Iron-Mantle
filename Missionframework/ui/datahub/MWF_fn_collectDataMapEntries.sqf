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
    case "BUILD_MENU": {
        private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
        private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
        private _mobLabel = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
        private _commandTerminal = missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull];
        private _playerPos = if (!isNull player) then { getPosATL player } else { _mobPos };

        private _contextTerminal = objNull;
        private _contextLabel = _mobLabel;
        private _contextPos = _mobPos;
        private _anchorType = "MOB";

        if (!isNull _commandTerminal && {alive _commandTerminal} && {_playerPos distance2D _commandTerminal <= 25}) then {
            _contextTerminal = _commandTerminal;
            _contextLabel = _mobLabel;
            _contextPos = getPosATL _commandTerminal;
        };

        _entries pushBack [
            "BUILD_ANCHOR",
            "Base Architect",
            _contextPos,
            createHashMapFromArray [
                ["contextTerminal", _contextTerminal],
                ["contextLabel", _contextLabel],
                ["anchorType", _anchorType],
                ["range", 500],
                ["description", "Open the Zeus construction view for this base anchor."],
                ["assetPolicy", "Allowed: structures, props, vehicles. Blocked: infantry and compositions that place units."],
                ["costText", "Each placed asset is server-validated and billed in Supplies from MWF_Supplies."],
                ["tooltipText", format ["Open Zeus build mode at %1.", _contextLabel]]
            ]
        ];
    };

    case "UPGRADES": {
        private _mainBase = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
        private _mobPos = if (!isNull _mainBase) then { getPosATL _mainBase } else { getMarkerPos "respawn_west" };
        private _mobLabel = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
        private _commandTerminal = missionNamespace getVariable ["MWF_CommandTerminal_Object", objNull];
        private _fobRegistry = missionNamespace getVariable ["MWF_FOB_Registry", []];
        private _playerPos = if (!isNull player) then { getPosATL player } else { _mobPos };

        private _contextTerminal = objNull;
        private _contextType = "MOB";
        private _contextLabel = _mobLabel;
        private _contextKey = "MOB";
        private _contextPos = _mobPos;

        if (!isNull _commandTerminal && {alive _commandTerminal} && {_playerPos distance2D _commandTerminal <= 25}) then {
            _contextTerminal = _commandTerminal;
        } else {
            private _nearestFob = objNull;
            private _nearestDist = 1e10;
            {
                private _terminal = _x param [1, objNull];
                if (!isNull _terminal) then {
                    private _dist = _playerPos distance2D _terminal;
                    if (_dist <= 25 && {_dist < _nearestDist}) then {
                        _nearestFob = _terminal;
                        _nearestDist = _dist;
                    };
                };
            } forEach _fobRegistry;

            if (!isNull _nearestFob) then {
                _contextTerminal = _nearestFob;
            } else {
                if (!isNull _mainBase && {_playerPos distance2D _mobPos <= 150}) then {
                    _contextTerminal = _mainBase;
                };
            };
        };

        if (!isNull _contextTerminal && {_contextTerminal getVariable ["MWF_FOB_DisplayName", ""] isNotEqualTo ""}) then {
            _contextType = "FOB";
            _contextLabel = _contextTerminal getVariable ["MWF_FOB_DisplayName", "FOB"];
            _contextKey = format ["FOB:%1", _contextLabel];
            _contextPos = getPosATL _contextTerminal;
        } else {
            if (!isNull _contextTerminal) then {
                _contextPos = getPosATL _contextTerminal;
            };
        };

        private _heliClass = missionNamespace getVariable ["MWF_Heli_Tower_Class", ""];
        private _jetClass = missionNamespace getVariable ["MWF_Jet_Control_Class", ""];
        private _garageClass = missionNamespace getVariable ["MWF_Virtual_Garage", ""];
        private _heliBuilt = (_heliClass isNotEqualTo "") && {({ typeOf _x isEqualTo _heliClass } count (nearestObjects [_mobPos, [_heliClass], 120])) > 0};
        private _jetBuilt = (_jetClass isNotEqualTo "") && {({ typeOf _x isEqualTo _jetClass } count (nearestObjects [_mobPos, [_jetClass], 120])) > 0};
        private _heliUnlockedReal = missionNamespace getVariable ["MWF_Unlock_Heli", false];
        private _jetUnlockedReal = missionNamespace getVariable ["MWF_Unlock_Jets", false];
        private _tier5UnlockedReal = missionNamespace getVariable ["MWF_Unlock_Tier5", false];
        private _heliUnlocked = ["HELI"] call MWF_fnc_hasProgressionAccess;
        private _jetUnlocked = ["JETS"] call MWF_fnc_hasProgressionAccess;
        private _tier5Unlocked = ["TIER5"] call MWF_fnc_hasProgressionAccess;
        private _currentTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
        private _isMobContext = _contextType isEqualTo "MOB";
        private _heliBuildCost = if (_heliClass isEqualTo "") then { 0 } else { [_heliClass] call MWF_fnc_getBuildAssetCost };
        private _jetBuildCost = if (_jetClass isEqualTo "") then { 0 } else { [_jetClass] call MWF_fnc_getBuildAssetCost };
        private _garageBuildCost = if (_garageClass isEqualTo "") then { 0 } else { missionNamespace getVariable ["MWF_Economy_Cost_MOB_Garage", 300] };

        private _garageBuilt = false;
        if (_garageClass isNotEqualTo "") then {
            _garageBuilt = (({ private _garageObj = _x param [0, objNull]; !isNull _garageObj && {(_garageObj getVariable ["MWF_isVirtualGarage", false])} && {(_garageObj getVariable ["MWF_Garage_BaseKey", ""]) isEqualTo _contextKey} } count (missionNamespace getVariable ["MWF_GarageRegistry", []])) > 0);
        };

        private _garageBlocked = false;
        private _garageBlockedReason = "";
        if (_garageClass isEqualTo "") then {
            _garageBlocked = true;
            _garageBlockedReason = "Virtual garage classname is not configured in the active BLUFOR preset.";
        } else {
            if (_contextType isEqualTo "FOB") then {
                if (isNull _contextTerminal) then {
                    _garageBlocked = true;
                    _garageBlockedReason = "FOB terminal unavailable.";
                } else {
                    if (_contextTerminal getVariable ["MWF_FOB_IsDamaged", false]) then {
                        _garageBlocked = true;
                        _garageBlockedReason = format ["%1 is offline and must be rebuilt before its garage can be used or rebuilt.", _contextLabel];
                    } else {
                        if (_contextTerminal getVariable ["MWF_isUnderAttack", false]) then {
                            _garageBlocked = true;
                            _garageBlockedReason = format ["%1 is under attack. Garage build/use is disabled until the assault ends.", _contextLabel];
                        };
                    };
                };
            };
        };

        private _mobOnlyTooltip = if (_isMobContext) then { "" } else { "This is a permanent MOB-only upgrade. Access the Command Network at the MOB to build or manage it." };
        private _baseContextText = format ["Current base: %1", _contextLabel];

        private _upgradeEntries = [
            [
                "Virtual Garage",
                [(_contextPos # 0), (_contextPos # 1) + 28, 0],
                createHashMapFromArray [
                    ["upgradeId", "GARAGE"],
                    ["description", "Base-local garage structure for storing, retrieving, customizing, and scrapping vehicles at the current MOB/FOB."],
                    ["baseContextText", _baseContextText],
                    ["contextTerminal", _contextTerminal],
                    ["buildClass", _garageClass],
                    ["buildCost", _garageBuildCost],
                    ["isUnlocked", !_garageBlocked],
                    ["isBuilt", _garageBuilt],
                    ["statusText", if (_garageBlocked) then {if (_garageBlockedReason find "under attack" > -1) then {"FOB Under Attack"} else {if (_garageBlockedReason find "offline" > -1) then {"FOB Offline"} else {"Unavailable"}}} else {if (_garageBuilt) then {"Ready"} else {"Ready To Build"}}],
                    ["tooltipText", if (_garageBlocked) then {_garageBlockedReason} else {if (_garageBuilt) then {format ["Virtual Garage is online at %1. Use the garage object on foot within 5 meters.", _contextLabel]} else {format ["Place the Virtual Garage at %1 with ghost placement. Cost: %2 Supplies.", _contextLabel, _garageBuildCost]}}],
                    ["actionMode", if (_garageBlocked) then {"LOCKED"} else {if (_garageBuilt) then {"GARAGE_INFO"} else {"GARAGE_BUILD"}}]
                ]
            ],
            [
                "Helicopter Uplink",
                [(_contextPos # 0) - 22, (_contextPos # 1) + 8, 0],
                createHashMapFromArray [
                    ["upgradeId", "HELI"],
                    ["requiredOperation", "Sky Guardian"],
                    ["description", "Unlocks helicopter logistics through a MOB-only upgrade structure."],
                    ["baseContextText", _baseContextText],
                    ["contextTerminal", _contextTerminal],
                    ["buildClass", _heliClass],
                    ["buildCost", _heliBuildCost],
                    ["isUnlocked", _heliUnlocked],
                    ["isBuilt", _heliBuilt],
                    ["statusText", if (!_heliUnlocked) then {"Locked"} else {if (_isMobContext) then {if (_heliBuilt) then {"Ready"} else {"Unlocked - Build Required"}} else {"MOB Only"}}],
                    ["tooltipText", if (!_heliUnlocked) then {"Requires main operation: Sky Guardian."} else {if (_isMobContext) then {if (_heliBuilt) then {if (_heliUnlockedReal) then {"Helicopters are now available in the vehicle menu."} else {"DEBUG override active. Helicopters are available for testing now, and Sky Guardian will still grant the normal unlock message when completed."}} else {if (_heliUnlockedReal) then {format ["Place the Helicopter Uplink with ghost placement at the MOB. Cost: %1 Supplies.", _heliBuildCost]} else {format ["DEBUG override active. Place the Helicopter Uplink with ghost placement at the MOB. Cost: %1 Supplies.", _heliBuildCost]}}} else {_mobOnlyTooltip}}],
                    ["actionMode", if (!_heliUnlocked) then {"LOCKED"} else {if (_isMobContext) then {if (_heliBuilt) then {"VEHICLE_MENU"} else {"BASE_BUILDING"}} else {"LOCKED"}}]
                ]
            ],
            [
                "Aircraft Control",
                [(_contextPos # 0) + 22, (_contextPos # 1) + 8, 0],
                createHashMapFromArray [
                    ["upgradeId", "JET"],
                    ["requiredOperation", "Point Blank"],
                    ["description", "Unlocks fixed-wing strike logistics through a MOB-only upgrade structure."],
                    ["baseContextText", _baseContextText],
                    ["contextTerminal", _contextTerminal],
                    ["buildClass", _jetClass],
                    ["buildCost", _jetBuildCost],
                    ["isUnlocked", _jetUnlocked],
                    ["isBuilt", _jetBuilt],
                    ["statusText", if (!_jetUnlocked) then {"Locked"} else {if (_isMobContext) then {if (_jetBuilt) then {"Ready"} else {"Unlocked - Build Required"}} else {"MOB Only"}}],
                    ["tooltipText", if (!_jetUnlocked) then {"Requires main operation: Point Blank."} else {if (_isMobContext) then {if (_jetBuilt) then {if (_jetUnlockedReal) then {"Aircraft are now available in the vehicle menu."} else {"DEBUG override active. Aircraft are available for testing now, and Point Blank will still grant the normal unlock message when completed."}} else {if (_jetUnlockedReal) then {format ["Place the Aircraft Control building with ghost placement at the MOB. Cost: %1 Supplies.", _jetBuildCost]} else {format ["DEBUG override active. Place the Aircraft Control building with ghost placement at the MOB. Cost: %1 Supplies.", _jetBuildCost]}}} else {_mobOnlyTooltip}}],
                    ["actionMode", if (!_jetUnlocked) then {"LOCKED"} else {if (_isMobContext) then {if (_jetBuilt) then {"VEHICLE_MENU"} else {"BASE_BUILDING"}} else {"LOCKED"}}]
                ]
            ],
            [
                "Base Tier 5",
                [(_contextPos # 0), (_contextPos # 1) - 20, 0],
                createHashMapFromArray [
                    ["upgradeId", "TIER5"],
                    ["requiredOperation", "Apex Predator"],
                    ["description", "Extends the player base progression path to Tier 5. Vehicle presets may place special Tier 5 assets at the bottom of their categories."],
                    ["baseContextText", _baseContextText],
                    ["contextTerminal", _contextTerminal],
                    ["isUnlocked", _tier5Unlocked],
                    ["isBuilt", _tier5Unlocked && {_currentTier >= 5}],
                    ["statusText", if (!_tier5Unlocked) then {"Locked"} else {if (_currentTier >= 5) then {"Complete"} else {"Ready"}}],
                    ["tooltipText", if (!_tier5Unlocked) then {"Requires main operation: Apex Predator."} else {if (_currentTier >= 5) then {if (_tier5UnlockedReal) then {"Tier 5 base progression is active. Tier 5 preset entries now appear at the bottom of the vehicle menu categories."} else {"DEBUG override active. Tier 5 systems are available for testing now, and Apex Predator will still grant the normal unlock message when completed."}} else {if (_tier5UnlockedReal) then {"Use [ UPGRADE BASE TIER ] at the Command Network to advance from Tier 4 to Tier 5."} else {"DEBUG override active. You may upgrade into Tier 5 for testing now, and Apex Predator will still grant the normal unlock message when completed."}}}],
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
            _entry params ["_key", "_title", "_desc", "_fnName", "_impactId", "_effectType", "_effectText", "_fallbackText", "_cooldownSeconds", ["_intelCost", 0, [0]]];
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
                        ["intelCost", _intelCost],
                        ["effectiveIntelCost", _state getOrDefault ["effectiveIntelCost", _intelCost]],
                        ["freeChargeAvailable", _state getOrDefault ["freeChargeAvailable", false]],
                        ["freeChargeCount", _state getOrDefault ["freeChargeCount", 0]],
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
