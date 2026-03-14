/*
    Author: Theane / ChatGPT
    Function: fn_initSystems
    Project: Military War Framework

    Description:
    Initializes core runtime state that must exist before background systems start.
*/

if (!isServer) exitWith {};

missionNamespace setVariable ["MWF_CoreVersion", "1.0", true];
missionNamespace setVariable ["MWF_isWiping", false, true];
missionNamespace setVariable ["MWF_systems_ready", false, true];

missionNamespace setVariable ["MWF_all_mission_zones", missionNamespace getVariable ["MWF_all_mission_zones", []], true];
missionNamespace setVariable ["MWF_ActiveZones", missionNamespace getVariable ["MWF_ActiveZones", []], true];
missionNamespace setVariable ["MWF_DestroyedHQs", missionNamespace getVariable ["MWF_DestroyedHQs", []], true];
missionNamespace setVariable ["MWF_DestroyedRoadblocks", missionNamespace getVariable ["MWF_DestroyedRoadblocks", []], true];
missionNamespace setVariable ["MWF_FOB_Positions", missionNamespace getVariable ["MWF_FOB_Positions", []], true];
missionNamespace setVariable ["MWF_FixedInfrastructure", missionNamespace getVariable ["MWF_FixedInfrastructure", []], true];
missionNamespace setVariable ["MWF_completedMissions", missionNamespace getVariable ["MWF_completedMissions", []], true];
missionNamespace setVariable ["MWF_RepPenaltyCount", missionNamespace getVariable ["MWF_RepPenaltyCount", 0], true];
missionNamespace setVariable ["MWF_CurrentTier", missionNamespace getVariable ["MWF_CurrentTier", 1], true];

setTimeMultiplier (["MWF_Param_TimeMultiplier", 1] call BIS_fnc_getParamValue);

private _wipeRequested = ["MWF_Param_WipeSave", 0] call BIS_fnc_getParamValue;
private _wipeConfirmed = ["MWF_Param_ConfirmWipe", 0] call BIS_fnc_getParamValue;

if (_wipeRequested == 1 && _wipeConfirmed == 1) then {
    missionNamespace setVariable ["MWF_isWiping", true, true];

    if (!isNil "MWF_fnc_wipeSave") then {
        [] call MWF_fnc_wipeSave;
    };

    diag_log "[MWF] Save wipe requested by lobby parameters.";
};

missionNamespace setVariable ["MWF_systems_ready", true, true];
diag_log "[MWF] Core systems initialized.";
