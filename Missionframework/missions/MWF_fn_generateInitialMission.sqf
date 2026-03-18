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
    };

    case 3: {
        ["task_supply_run", "SUCCEEDED"] call BIS_fnc_taskSetState;
        missionNamespace setVariable ["MWF_Tutorial_SupplyRunDone", true, true];
        missionNamespace setVariable ["MWF_current_stage", 3, true];

        [100, "SUPPLIES"] call MWF_fnc_addResource;

        private _participants = allPlayers select { alive _x };
        private _undercoverCompletion = (_participants findIf { _x getVariable ["MWF_isUndercover", false] }) >= 0;

        if (_undercoverCompletion) then {
            [50] call MWF_fnc_addIntel;
        } else {
            if (!isNil "MWF_fnc_registerThreatIncident") then {
                ["tutorial_supply_run", "", 1, "Tutorial supply run completed loudly."] call MWF_fnc_registerThreatIncident;
            };
        };

        if (!isNil "MWF_fnc_requestDelayedSave") then {
            [] call MWF_fnc_requestDelayedSave;
        } else {
            if (!isNil "MWF_fnc_saveGame") then {
                ["Tutorial Supply Milestone"] call MWF_fnc_saveGame;
            };
        };

        diag_log format [
            "[MWF Tutorial] Initial supply-run milestone complete. Supplies +100 | Intel bonus: %1 | Waiting for MOB login to transition into OPEN_WAR.",
            if (_undercoverCompletion) then {50} else {0}
        ];
    };
};
