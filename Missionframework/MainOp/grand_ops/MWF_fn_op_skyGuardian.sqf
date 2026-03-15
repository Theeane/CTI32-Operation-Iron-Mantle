/*
    Author: Theane / Gemini
    Operation: Sky Guardian
    Reward: Heli-Unlock
    Structure: Start (Sabotage) -> Mid 1 (HVT) -> End (Capture Airbase)
    Stealth: Bonus (400S/200I) if undetected until Mid 1 is completed.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

switch (_state) do {
    case "START": {
        // --- PHASE: START (Blind the Giant) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];

        // Create Main Task
        [
            west, 
            "Task_SkyGuardian_Parent", 
            ["The enemy's integrated air defense network is preventing our air assets from deploying. We must dismantle their radar array and secure the regional airfield.", "Grand Op: Sky Guardian", ""], 
            objNull, "ASSIGNED", 5, true, "air", false
        ] call BIS_fnc_taskCreate;

        // Create Sub-Task 1
        [
            west, 
            ["Task_SkyGuardian_S1", "Task_SkyGuardian_Parent"], 
            ["Locate and destroy the 3 mobile radar units positioned in the sector. Maintain stealth to maximize intelligence recovery.", "Sabotage Radar Array", ""], 
            _position, "CREATED", 5, true, "destroy", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Sky Guardian: Operation Initialized.";
    };

    case "MID_1": {
        // --- PHASE: MID 1 (The Keyholder) ---
        
        // Complete Sub-Task 1
        ["Task_SkyGuardian_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // Check Stealth Bonus (The "Infiltration" reward)
        if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
            [400, "SUPPLIES"] call MWF_fnc_addResource;
            [200, "INTEL"] call MWF_fnc_addResource;
            
            [
                ["STEALTH BONUS GRANTED", "400 Supplies and 200 Intel recovered from the secure network."],
                "info"
            ] remoteExec ["MWF_fnc_showNotification", 0];
        } else {
            [
                ["STEALTH COMPROMISED", "Enemy encryption updated. Strategic bonus lost."],
                "warning"
            ] remoteExec ["MWF_fnc_showNotification", 0];
        };

        // Create Sub-Task 2
        [
            west, 
            ["Task_SkyGuardian_S2", "Task_SkyGuardian_Parent"], 
            ["The radar destruction has forced the local commander into the open. Eliminate the AA-Officer to retrieve the airfield access codes.", "Eliminate AA Commander", ""], 
            _position, "ASSIGNED", 5, true, "target", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Sky Guardian: Mid 1 reached. Stealth checked.";
    };

    case "END": {
        // --- PHASE: END (The Assault) ---
        
        // Complete Sub-Task 2
        ["Task_SkyGuardian_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // Create Final Sub-Task
        [
            west, 
            ["Task_SkyGuardian_S3", "Task_SkyGuardian_Parent"], 
            ["With the codes in hand and the radar dead, the airfield is vulnerable. Clear all remaining hostiles and secure the runway.", "Seize the Airfield", ""], 
            _position, "ASSIGNED", 5, true, "flag", false
        ] call BIS_fnc_taskCreate;

        // Logic for completion (to be called when zone is clear)
        // This is usually triggered by the zone manager
    };

    case "COMPLETE": {
        // --- MISSION SUCCESS ---
        ["Task_SkyGuardian_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_SkyGuardian_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // Unlock Reward
        missionNamespace setVariable ["MWF_Unlock_Heli", true, true];
        
        [
            ["OPERATION SUCCESSFUL", "Helicopter assets are now available in the Vehicle Menu."],
            "success"
        ] remoteExec ["MWF_fnc_showNotification", 0];

        [] call MWF_fnc_saveGame;
        diag_log "[MWF Grand Op] Sky Guardian: All tasks complete. Helis Unlocked.";
    };
};
