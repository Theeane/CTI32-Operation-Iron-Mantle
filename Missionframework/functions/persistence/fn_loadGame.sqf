/*
    Author: Theane / ChatGPT
    Function: fn_loadGame
    Project: Military War Framework

    Description:
    Restores the saved campaign state and synchronizes current MWF runtime variables.
*/

if (!isServer) exitWith {};

private _supplies = profileNamespace getVariable ["MWF_Save_Supplies", missionNamespace getVariable ["MWF_Economy_Supplies", 200]];
private _intel = profileNamespace getVariable ["MWF_Save_Intel", missionNamespace getVariable ["MWF_res_intel", 0]];
private _civRep = profileNamespace getVariable ["MWF_Save_CivRep", missionNamespace getVariable ["MWF_CivRep", 0]];
private _notoriety = profileNamespace getVariable ["MWF_Save_Notoriety", missionNamespace getVariable ["MWF_res_notoriety", 0]];

missionNamespace setVariable ["MWF_Economy_Supplies", _supplies, true];
missionNamespace setVariable ["MWF_res_intel", _intel, true];
missionNamespace setVariable ["MWF_CivRep", _civRep, true];
missionNamespace setVariable ["MWF_res_notoriety", _notoriety, true];
missionNamespace setVariable ["MWF_Supplies", _supplies, true];
missionNamespace setVariable ["MWF_Intel", _intel, true];
missionNamespace setVariable ["MWF_RepPenaltyCount", profileNamespace getVariable ["MWF_Save_RepPenalties", 0], true];

missionNamespace setVariable ["MWF_DestroyedHQs", profileNamespace getVariable ["MWF_Save_DestroyedHQs", []], true];
missionNamespace setVariable ["MWF_DestroyedRoadblocks", profileNamespace getVariable ["MWF_Save_DestroyedRoadblocks", []], true];
missionNamespace setVariable ["MWF_FOB_Positions", profileNamespace getVariable ["MWF_Save_FOBs", []], true];
missionNamespace setVariable ["MWF_FixedInfrastructure", profileNamespace getVariable ["MWF_Save_FixedInfra", []], true];
missionNamespace setVariable ["MWF_completedMissions", profileNamespace getVariable ["MWF_Save_Missions", []], true];
missionNamespace setVariable ["MWF_CurrentTier", profileNamespace getVariable ["MWF_Save_Tier", 1], true];

private _savedBuildingMode = profileNamespace getVariable ["MWF_Save_BuildingMode", -1];
if (_savedBuildingMode == -1) then {
    missionNamespace setVariable ["MWF_LockedBuildingMode", ["MWF_Param_BuildingDamageMode", 0] call BIS_fnc_getParamValue, true];
} else {
    missionNamespace setVariable ["MWF_LockedBuildingMode", _savedBuildingMode, true];
};

private _savedZones = profileNamespace getVariable ["MWF_Save_Zones", []];
{
    private _zone = _x;
    private _zoneId = _zone getVariable ["MWF_zoneID", ""];
    private _zoneName = _zone getVariable ["MWF_zoneName", ""];

    if ((_zoneId in _savedZones) || (_zoneName in _savedZones)) then {
        _zone setVariable ["MWF_isCaptured", true, true];
        private _marker = _zone getVariable ["MWF_zoneMarker", ""];
        if (_marker != "") then {
            _marker setMarkerColor "ColorBLUFOR";
        };
    };
} forEach (missionNamespace getVariable ["MWF_all_mission_zones", []]);

diag_log format ["[MWF] Campaign state restored. Saved zones: %1.", count _savedZones];
