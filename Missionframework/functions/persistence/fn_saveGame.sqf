/*
    Author: Theane / ChatGPT
    Function: fn_saveGame
    Project: Military War Framework

    Description:
    Saves current campaign state using a single MWF persistence schema.
*/

if (!isServer) exitWith {};
params [["_reason", "Auto Save", [""]]];

private _allZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
private _savedZoneIds = [];

{
    private _zoneRef = _x;
    private _isMarkerZone = _zoneRef isEqualType "";
    private _isCaptured = false;
    private _zoneId = "";

    if (_isMarkerZone) then {
        private _markerName = _zoneRef;
        _isCaptured = missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_isCaptured", _markerName], false];
        _zoneId = _markerName;
    } else {
        if (!isNull _zoneRef) then {
            _isCaptured = _zoneRef getVariable ["MWF_isCaptured", false];
            _zoneId = _zoneRef getVariable ["MWF_zoneID", _zoneRef getVariable ["MWF_zoneName", ""]];
        };
    };

    if (_isCaptured && { _zoneId != "" }) then {
        _savedZoneIds pushBackUnique _zoneId;
    };
} forEach _allZones;

private _totalZones = count _allZones;
private _capturedCount = count _savedZoneIds;
private _completionPercent = if (_totalZones > 0) then { (_capturedCount / _totalZones) * 100 } else { 0 };

private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 200]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _civRep = missionNamespace getVariable ["MWF_CivRep", 0];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];

missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
missionNamespace setVariable ["MWF_res_intel", _intel, true];
missionNamespace setVariable ["MWF_Supplies", _supplies, true];
missionNamespace setVariable ["MWF_Intel", _intel, true];

profileNamespace setVariable ["MWF_Save_Zones", _savedZoneIds];
profileNamespace setVariable ["MWF_Save_Completion", _completionPercent];
profileNamespace setVariable ["MWF_Save_Supplies", _supplies];
profileNamespace setVariable ["MWF_Save_Intel", _intel];
profileNamespace setVariable ["MWF_Save_CivRep", _civRep];
profileNamespace setVariable ["MWF_Save_Notoriety", _notoriety];
profileNamespace setVariable ["MWF_Save_RepPenalties", missionNamespace getVariable ["MWF_RepPenaltyCount", 0]];
profileNamespace setVariable ["MWF_Save_DestroyedHQs", missionNamespace getVariable ["MWF_DestroyedHQs", []]];
profileNamespace setVariable ["MWF_Save_DestroyedRoadblocks", missionNamespace getVariable ["MWF_DestroyedRoadblocks", []]];
profileNamespace setVariable ["MWF_Save_Tier", missionNamespace getVariable ["MWF_CurrentTier", 1]];
profileNamespace setVariable ["MWF_Save_FixedInfra", missionNamespace getVariable ["MWF_FixedInfrastructure", []]];
profileNamespace setVariable ["MWF_Save_FOBs", missionNamespace getVariable ["MWF_FOB_Positions", []]];
profileNamespace setVariable ["MWF_Save_BuildingMode", missionNamespace getVariable ["MWF_LockedBuildingMode", -1]];
profileNamespace setVariable ["MWF_Save_Missions", missionNamespace getVariable ["MWF_completedMissions", []]];

saveProfileNamespace;
diag_log format ["[MWF] Game saved (%1). Completion: %2%3.", _reason, floor _completionPercent, "%"];
