/*
    Author: Theane / ChatGPT
    Function: fn_refreshMissionBoard
    Project: Military War Framework

    Description:
    Refreshes the side mission board with a fixed 3x3 layout.
    The board guarantees one Easy, one Medium, and one Hard mission for each category:
    disrupt, supply, intel.

    Return:
    Array of mission board slot records:
    [slotIndex, category, difficulty, missionId, missionKey, missionPath, positionATL, zoneId, zoneName, state]
*/

if (!isServer) exitWith {[]};

private _registry = + (missionNamespace getVariable ["MWF_MissionTemplateRegistry", []]);
private _placements = + (missionNamespace getVariable ["MWF_MissionSessionPlacements", []]);

if (_registry isEqualTo [] || _placements isEqualTo []) exitWith {
    missionNamespace setVariable ["MWF_MissionBoardSlots", [], true];
    missionNamespace setVariable ["MWF_MissionBoardCreatedAt", serverTime, true];
    missionNamespace setVariable ["MWF_MissionBoardExpiresAt", serverTime, true];
    []
};

private _slotCategories = ["disrupt", "supply", "intel"];
private _difficulties = ["easy", "medium", "hard"];
private _slots = [];
private _usedMissionKeys = [];

{
    private _category = _x;

    {
        private _difficulty = _x;
        private _pool = _registry select {
            (_x # 1) isEqualTo _category &&
            (_x # 2) isEqualTo _difficulty &&
            !((_x # 0) in _usedMissionKeys)
        };

        if (_pool isNotEqualTo []) then {
            private _template = selectRandom _pool;
            _template params ["_missionKey", "_templateCategory", "_templateDifficulty", "_missionId", "_missionPath"];

            private _placementIndex = _placements findIf { (_x # 0) isEqualTo _missionKey };
            if (_placementIndex >= 0) then {
                private _placement = _placements # _placementIndex;
                _placement params ["_placementMissionKey", "_position", "_zoneId", "_zoneName"];

                private _slotIndex = count _slots;
                _slots pushBack [
                    _slotIndex,
                    _templateCategory,
                    _templateDifficulty,
                    _missionId,
                    _placementMissionKey,
                    _missionPath,
                    _position,
                    _zoneId,
                    _zoneName,
                    "available"
                ];

                _usedMissionKeys pushBack _missionKey;
            } else {
                diag_log format ["[MWF Missions] No session placement found for mission key %1 during board refresh.", _missionKey];
            };
        } else {
            diag_log format ["[MWF Missions] No template available for %1/%2 during board refresh.", _category, _difficulty];
        };
    } forEach _difficulties;
} forEach _slotCategories;

missionNamespace setVariable ["MWF_MissionBoardSlots", _slots, true];
missionNamespace setVariable ["MWF_MissionBoardCreatedAt", serverTime, true];
missionNamespace setVariable ["MWF_MissionBoardExpiresAt", serverTime + 300, true];

_slots
