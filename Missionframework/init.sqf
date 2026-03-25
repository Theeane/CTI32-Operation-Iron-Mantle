/*
    Author: Theeane / Gemini Guide / ChatGPT
    File: init.sqf
    Project: Military War Framework (MWF)
    Description:
    Initializes the mission environment.
    Keeps Arma engine saving disabled so MWF uses only its own persistence flow,
    then waits for server bootstrap before local/client startup continues.
*/

enableSaving [false, false];
diag_log "[MWF] Engine saving disabled. Save & Exit must not create Arma save data for this mission.";

private _localBootDeadline = diag_tickTime + 90;
waitUntil {
    uiSleep 0.25;
    (missionNamespace getVariable ["MWF_ServerInitialized", false]) ||
    {diag_tickTime >= _localBootDeadline}
};

if (!(missionNamespace getVariable ["MWF_ServerInitialized", false])) then {
    diag_log "[MWF] WARNING: init.sqf timed out waiting for server-ready flag. Continuing locally.";
};

diag_log "[MWF] INFO: Local initialization started.";
diag_log "[MWF] SUCCESS: Local initialization complete.";
