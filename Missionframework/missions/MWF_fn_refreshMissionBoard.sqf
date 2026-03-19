/*
    Author: Theane / ChatGPT
    Function: fn_refreshMissionBoard
    Project: Military War Framework

    Description:
    Refreshes the side mission board with a domain-aware mission layout.
    Default target layout:
    - land: 9 missions (3 categories x 3 difficulties)
    - naval: 9 missions if supported
    - air: 9 missions if supported

    Minimal mode fallback:
    If the board cannot maintain at least 100m separation, reduce to one Supply,
    one Intel, and one Disrupt mission across any supported domain/difficulty.

    Return:
    Array of mission board slot records:
    [slotIndex, category, difficulty, missionId, missionKey, missionPath, positionATL, areaId, areaName, state, domain, missionDefinition]
*/

if (!isServer) exitWith {[]};

private _registry = + (missionNamespace getVariable ["MWF_MissionTemplateRegistry", []]);
private _placements = + (missionNamespace getVariable ["MWF_MissionSessionPlacements", []]);
private _supportedDomains = [];
if (missionNamespace getVariable ["MWF_MissionDomainSupported_Land", false]) then { _supportedDomains pushBack "land"; };
if (missionNamespace getVariable ["MWF_MissionDomainSupported_Naval", false]) then { _supportedDomains pushBack "naval"; };
if (missionNamespace getVariable ["MWF_MissionDomainSupported_Air", false]) then { _supportedDomains pushBack "air"; };

if (_registry isEqualTo [] || _placements isEqualTo [] || _supportedDomains isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_MissionBoardSlots", [], true];
    missionNamespace setVariable ["MWF_MissionBoardCreatedAt", serverTime, true];
    missionNamespace setVariable ["MWF_MissionBoardExpiresAt", serverTime, true];
    missionNamespace setVariable ["MWF_MissionBoardMinimalMode", false, true];
    []
};

private _readMissionDefinition = {
    params ["_missionPath"];

    if !fileExists _missionPath exitWith { [] };

    private _raw = loadFile _missionPath;
    if (_raw isEqualTo "") exitWith { [] };

    private _marker = "private _missionDefinition = ";
    private _markerPos = _raw find _marker;
    if (_markerPos < 0) exitWith { [] };

    private _afterMarker = _markerPos + (count _marker);
    private _tail = _raw select [_afterMarker];
    private _localOpen = _tail find "[";
    if (_localOpen < 0) exitWith { [] };

    private _start = _afterMarker + _localOpen;
    private _depth = 0;
    private _inString = false;
    private _end = -1;

    for "_i" from _start to ((count _raw) - 1) do {
        private _ch = _raw select [_i, 1];

        if (_ch isEqualTo (toString [34])) then {
            _inString = !_inString;
        } else {
            if (!_inString) then {
                if (_ch isEqualTo "[") then {
                    _depth = _depth + 1;
                } else {
                    if (_ch isEqualTo "]") then {
                        _depth = _depth - 1;
                        if (_depth <= 0) exitWith {
                            _end = _i;
                        };
                    };
                };
            };
        };
    };

    if (_end < _start) exitWith { [] };

    private _arrayText = _raw select [_start, (_end - _start) + 1];
    private _definition = call compile _arrayText;
    if !(_definition isEqualType []) exitWith { [] };

    _definition
};

private _distanceSteps = [1000, 750, 500, 250, 100];
private _categories = ["supply", "intel", "disrupt"];
private _difficulties = ["easy", "medium", "hard"];
private _desiredSpecs = [];

{
    private _domain = _x;
    {
        private _category = _x;
        {
            private _difficulty = _x;
            _desiredSpecs pushBack [_domain, _category, _difficulty];
        } forEach _difficulties;
    } forEach _categories;
} forEach _supportedDomains;

private _buildSlots = {
    params ["_specs", "_minDistance", "_allowAnyDifficulty"];

    private _slots = [];
    private _usedMissionKeys = [];
    private _failed = false;

    {
        _x params ["_domain", "_category", ["_difficulty", "", [""]]];

        private _pool = _registry select {
            private _entry = _x;
            private _entryDomain = _entry param [5, "land", [""]];
            (_entryDomain isEqualTo _domain) &&
            ((_entry # 1) isEqualTo _category) &&
            (_allowAnyDifficulty || {(_entry # 2) isEqualTo _difficulty}) &&
            !((_entry # 0) in _usedMissionKeys)
        };

        if (_pool isEqualTo []) exitWith {
            _failed = true;
        };

        private _shuffledPool = +_pool;
        _shuffledPool = _shuffledPool call BIS_fnc_arrayShuffle;
        private _chosenTemplate = [];
        private _chosenPlacement = [];

        {
            private _template = _x;
            private _missionKey = _template # 0;
            private _placementIndex = _placements findIf { (_x # 0) isEqualTo _missionKey };

            if (_placementIndex >= 0) then {
                private _placement = _placements # _placementIndex;
                private _position = _placement # 1;
                private _ok = true;

                {
                    private _existingPos = _x # 6;
                    if ((_position distance2D _existingPos) < _minDistance) exitWith {
                        _ok = false;
                    };
                } forEach _slots;

                if (_ok) exitWith {
                    _chosenTemplate = _template;
                    _chosenPlacement = _placement;
                };
            };
        } forEach _shuffledPool;

        if (_chosenTemplate isEqualTo [] || {_chosenPlacement isEqualTo []}) exitWith {
            _failed = true;
        };

        _chosenTemplate params ["_missionKey", "_templateCategory", "_templateDifficulty", "_missionId", "_missionPath", ["_templateDomain", "land", [""]]];
        _chosenPlacement params ["_placementMissionKey", "_position", "_areaId", "_areaName", ["_placementDomain", _templateDomain, [""]]];

        private _missionDefinition = [_missionPath] call _readMissionDefinition;

        _slots pushBack [
            count _slots,
            _templateCategory,
            _templateDifficulty,
            _missionId,
            _placementMissionKey,
            _missionPath,
            _position,
            _areaId,
            _areaName,
            "available",
            _templateDomain,
            _missionDefinition
        ];

        _usedMissionKeys pushBack _missionKey;
    } forEach _specs;

    if (_failed) exitWith {[]};
    _slots
};

private _slots = [];
private _minimalMode = false;

{
    _slots = [_desiredSpecs, _x, false] call _buildSlots;
    if (_slots isNotEqualTo []) exitWith {};
} forEach _distanceSteps;

if (_slots isEqualTo []) then {
    _minimalMode = true;
    private _minimalSpecs = [];

    {
        private _category = _x;
        private _foundDomain = "";

        {
            private _domain = _x;
            private _hasCategory = (_registry findIf {
                private _entry = _x;
                private _entryDomain = _entry param [5, "land", [""]];
                (_entryDomain isEqualTo _domain) && {(_entry # 1) isEqualTo _category}
            }) >= 0;

            if (_hasCategory) exitWith {
                _foundDomain = _domain;
            };
        } forEach _supportedDomains;

        if !(_foundDomain isEqualTo "") then {
            _minimalSpecs pushBack [_foundDomain, _category, ""];
        };
    } forEach _categories;

    {
        _slots = [_minimalSpecs, _x, true] call _buildSlots;
        if (_slots isNotEqualTo []) exitWith {};
    } forEach _distanceSteps;

    if (_slots isEqualTo []) then {
        _slots = [_minimalSpecs, 0, true] call _buildSlots;
    };
};

{
    _x set [0, _forEachIndex];
} forEach _slots;

missionNamespace setVariable ["MWF_MissionBoardSlots", _slots, true];
missionNamespace setVariable ["MWF_MissionBoardCreatedAt", serverTime, true];
missionNamespace setVariable ["MWF_MissionBoardExpiresAt", serverTime + 300, true];
missionNamespace setVariable ["MWF_MissionBoardMinimalMode", _minimalMode, true];

_slots
