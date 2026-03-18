/*
    Author: Theane / ChatGPT
    Function: fn_generateInitialMission
    Project: Military War Framework

    Description:
    Handles tutorial-stage mission logic.

    Global phase model:
    - Stage 1: Deploy FOB
    - Stage 2: Complete initial supply run
    - Stage 3: Supply milestone complete; campaign can transition to OPEN_WAR on next MOB login
*/

if (!isServer) exitWith {};

params [["_stage", 1]];

switch (_stage) do {
    case 1: {
        [
            west,
            "task_deploy_fob",
            [
                "Use the HQ Terminal to build or deploy your first Forward Operating Base (FOB). This will serve as your respawn point and logistics hub.",
                "Deploy FOB",
                ""
            ],
            objNull,
            "CREATED",
            5,
            true,
            "setup",
            true
        ] call BIS_fnc_taskCreate;

        missionNamespace setVariable ["MWF_current_stage", 1, true];
    };

    case 2: {
        ["task_deploy_fob", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west,
            "task_supply_run",
            [
                "We are low on resources. A supply crate has been located in a nearby village. Recover it to complete the logistics tutorial.",
                "Conduct Supply Run",
                ""
            ],
            objNull,
            "CREATED",
            5,
            true,
            "container",
            true
        ] call BIS_fnc_taskCreate;

        missionNamespace setVariable ["MWF_current_stage", 2, true];

        private _campaignPhase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
        if (_campaignPhase isEqualTo "TUTORIAL") then {
            if (!isNil "MWF_fnc_setCampaignPhase") then {
                ["SUPPLY_RUN", "FOB Tutorial Complete"] call MWF_fnc_setCampaignPhase;
            } else {
                missionNamespace setVariable ["MWF_Campaign_Phase", "SUPPLY_RUN", true];
            };
        };
    };

    case 3: {
        ["task_supply_run", "SUCCEEDED"] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
        missionNamespace setVariable ["MWF_current_stage", 3, true];

        if (!isNil "MWF_fnc_requestDelayedSave") then {
            [] call MWF_fnc_requestDelayedSave;
        } else {
            if (!isNil "MWF_fnc_saveGame") then {
                ["Tutorial Supply Milestone"] call MWF_fnc_saveGame;
            };
        };

        diag_log "[MWF Tutorial] Initial supply-run milestone complete. Waiting for MOB login to transition into OPEN_WAR.";
    };
};
