/*
    Author: Theane (AGS Project)
    Description: Sequential starter missions: Deploy FOB -> Supply Op -> Capture Zone.
    Language: English
*/

if (!isServer) exitWith {};

params [["_stage", 1]];

switch (_stage) do {
    // --- STAGE 1: DEPLOY FIRST FOB ---
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
        
        // Logic to wait for FOB deployment would be triggered from the Build Mode script
        missionNamespace setVariable ["AGS_current_stage", 1, true];
    };

    // --- STAGE 2: INITIAL SUPPLY RUN ---
    case 2: {
        ["task_deploy_fob", "SUCCEEDED"] call BIS_fnc_taskSetState;
        
        [
            west, 
            "task_supply_run", 
            [
                "We are low on resources. A supply crate has been located in a nearby village. Recover it to fund our first offensive.",
                "Conduct Supply Run",
                ""
            ], 
            objNull, // Position will be set by the generator
            "CREATED", 
            5, 
            true, 
            "container", 
            true
        ] call BIS_fnc_taskCreate;
        
        // Here we would call a function to spawn a random supply crate mission
        // [] spawn AGS_fnc_spawnSupplyCrate;
        missionNamespace setVariable ["AGS_current_stage", 2, true];
    };

    // --- STAGE 3: SECURE SECTOR ---
    case 3: {
        ["task_supply_run", "SUCCEEDED"] call BIS_fnc_taskSetState;

        private _basePos = getMarkerPos "AGS_base_marker";
        private _allZones = missionNamespace getVariable ["AGS_all_mission_zones", []];
        private _targetZone = [_allZones, _basePos] call BIS_fnc_nearestPosition;

        [
            west, 
            "task_initial_capture", 
            [
                format ["With the FOB and supplies secured, capture %1 to establish a permanent Supply Line.", text _targetZone],
                "Secure First Sector",
                _targetZone
            ], 
            getMarkerPos _targetZone, 
            "CREATED", 
            5, 
            true, 
            "target", 
            true
        ] call BIS_fnc_taskCreate;
        
        missionNamespace setVariable ["AGS_current_stage", 3, true];
    };
};
