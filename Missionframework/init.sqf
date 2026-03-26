/*
    Author: Theeane / Gemini Guide / ChatGPT
    File: init.sqf
    Project: Military War Framework (MWF)

    Description:
    Local bootstrap guard. Keeps engine saving disabled and prevents clients from waiting
    forever if the dedicated/server boot chain releases late.
*/

enableSaving [false, false];
diag_log "[MWF] Engine saving disabled. Save & Exit must not create Arma save data for this mission.";

private _localBootDeadline = diag_tickTime + 120;
waitUntil {
    uiSleep 0.25;
    (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
    {(missionNamespace getVariable ["MWF_ServerBootStage", ""]) isEqualTo "CRITICAL_RELEASED"} ||
    {diag_tickTime >= _localBootDeadline}
};

if (!(missionNamespace getVariable ["MWF_ServerInitialized", false])) then {
    diag_log "[MWF] WARNING: init.sqf timed out waiting for server-ready flag. Continuing locally.";
};

missionNamespace setVariable ["MWF_LocalInitReady", true];
diag_log "[MWF] INFO: Local initialization started.";
diag_log "[MWF] SUCCESS: Local initialization complete.";
