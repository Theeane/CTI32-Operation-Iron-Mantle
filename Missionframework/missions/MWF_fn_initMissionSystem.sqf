/*
    Author: Theane / ChatGPT
    Function: fn_initMissionSystem
    Project: Military War Framework

    Description:
    Initializes the folder-driven rotating side mission framework.
    The system waits for zone, world, and threat foundations, discovers templates from folders,
    generates session-only placements, and rotates fixed mission board slots every 5 minutes.

    OPEN_WAR bypass:
    If the campaign phase is OPEN_WAR, tutorial gating is considered globally complete.
    No tutorial progression should be auto-created during startup.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_MissionSystemStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_MissionSystemStarted", true, true];
missionNamespace setVariable ["MWF_MissionSystemReady", false, true];

[] spawn {
    private _startupDeadline = diag_tickTime + 120;

    waitUntil {
        uiSleep 1;
        (
            missionNamespace getVariable ["MWF_ZoneSystemReady", false] &&
            missionNamespace getVariable ["MWF_WorldSystemReady", false] &&
            missionNamespace getVariable ["MWF_ThreatSystemReady", false]
        ) || {diag_tickTime >= _startupDeadline}
    };

    if (!(missionNamespace getVariable ["MWF_ZoneSystemReady", false])) then {
        diag_log "[MWF Missions] Startup timeout reached before zone system reported ready. Continuing with current zone registry.";
    };
    if (!(missionNamespace getVariable ["MWF_WorldSystemReady", false])) then {
        diag_log "[MWF Missions] Startup timeout reached before world system reported ready. Continuing with current world outputs.";
    };
    if (!(missionNamespace getVariable ["MWF_ThreatSystemReady", false])) then {
        diag_log "[MWF Missions] Startup timeout reached before threat system reported ready. Continuing with current threat outputs.";
    };

    if ((missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"]) isEqualTo "OPEN_WAR") then {
        missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
        missionNamespace setVariable ["MWF_current_stage", 3, true];
        diag_log "[MWF Missions] OPEN_WAR detected on startup. Tutorial gating bypassed globally.";
    };

    private _templates = [];
    if (!isNil "MWF_fnc_discoverMissionTemplates") then {
        _templates = [] call MWF_fnc_discoverMissionTemplates;
    };

    if (_templates isEqualTo []) then {
        diag_log "[MWF Missions] No mission templates discovered. Mission board will remain empty until templates exist.";
        missionNamespace setVariable ["MWF_MissionSystemReady", true, true];
    } else {
        if (!isNil "MWF_fnc_buildMissionSessionPlacements") then {
            [_templates] call MWF_fnc_buildMissionSessionPlacements;
        };

        if (!isNil "MWF_fnc_buildGrandOperationPlacements") then {
            [] call MWF_fnc_buildGrandOperationPlacements;
        };

        if (!isNil "MWF_fnc_refreshMissionBoard") then {
            [] call MWF_fnc_refreshMissionBoard;
        };
        missionNamespace setVariable ["MWF_PendingActiveSideMissions", [], true];
        missionNamespace setVariable ["MWF_PendingActiveSideMissionsRestored", true, true];

        missionNamespace setVariable ["MWF_MissionSystemReady", true, true];

        private _pendingGrandOp = +(missionNamespace getVariable ["MWF_PendingGrandOperationState", []]);
        if (_pendingGrandOp isEqualType [] && {count _pendingGrandOp >= 6} && {!isNil "MWF_fnc_mainOperationRuntime"}) then {
            _pendingGrandOp params [
                ["_key", "", [""]],
                ["_title", "", [""]],
                ["_fnName", "", [""]],
                ["_position", [0,0,0], [[]]],
                ["_phaseIndex", 0, [0]],
                ["_startedAt", serverTime, [0]],
                ["_placement", [], [[]]]
            ];

            if (_key isNotEqualTo "" && {_fnName isNotEqualTo ""}) then {
                missionNamespace setVariable ["MWF_GrandOperationActive", true, true];
                missionNamespace setVariable ["MWF_CurrentGrandOperation", _key, true];
                missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", _title, true];
                missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", +_placement, true];
                private _restored = ["RESTORE", [_key, _fnName, _title, _position, _phaseIndex, _startedAt]] call MWF_fnc_mainOperationRuntime;
                if (_restored) then {
                    diag_log format ["[MWF Missions] Restored main operation %1 at phase index %2.", _key, _phaseIndex];
                } else {
                    missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
                    missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
                    missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
                    missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];
                    diag_log format ["[MWF Missions] Failed to restore main operation %1.", _key];
                };
            };
            missionNamespace setVariable ["MWF_PendingGrandOperationState", [], true];
        };

        diag_log format ["[MWF Missions] Mission system ready. Templates discovered: %1.", count _templates];
    };

    while {true} do {
        private _systemReady = missionNamespace getVariable ["MWF_MissionSystemReady", false];
        private _expiresAt = missionNamespace getVariable ["MWF_MissionBoardExpiresAt", 0];

        if (_systemReady && {serverTime >= _expiresAt}) then {
            [] call MWF_fnc_refreshMissionBoard;
            diag_log "[MWF Missions] Mission board rotated.";
        };

        uiSleep 5;
    };
};
