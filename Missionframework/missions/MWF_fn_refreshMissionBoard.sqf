/*
    Author: Theane / ChatGPT
    Function: fn_refreshMissionBoard
    Project: Military War Framework

    Description:
    Refreshes the side mission board with a fixed set of slots.
    Each slot remains stable for 5 minutes before being replaced by a new random mission.

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
private _slots = [];

{
    private _slotIndex = _forEachIndex;
    private _category = _x;
    private _pool = _registry select { (_x # 1) isEqualTo _category };

    if (_pool isNotEqualTo []) then {
        private _template = selectRandom _pool;
        _template params ["_missionKey", "_templateCategory", "_difficulty", "_missionId", "_missionPath"];

        private _placementIndex = _placements findIf { (_x # 0) isEqualTo _missionKey };
        if (_placementIndex >= 0) then {
            private _placement = _placements # _placementIndex;
            _placement params ["_placementMissionKey", "_position", "_zoneId", "_zoneName"];

            _slots pushBack [
                _slotIndex,
                _templateCategory,
                _difficulty,
                _missionId,
                _placementMissionKey,
                _missionPath,
                _position,
                _zoneId,
                _zoneName,
                "available"
            ];
        };
    };
} forEach _slotCategories;

missionNamespace setVariable ["MWF_MissionBoardSlots", _slots, true];
missionNamespace setVariable ["MWF_MissionBoardCreatedAt", serverTime, true];
missionNamespace setVariable ["MWF_MissionBoardExpiresAt", serverTime + 300, true];

_slots
