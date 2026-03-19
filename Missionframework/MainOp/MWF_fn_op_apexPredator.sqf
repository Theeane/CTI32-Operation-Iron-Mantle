/*
    Author: Theane / Gemini
    Operation: Apex Predator
    Reward: Tier 5 Base Upgrade Access
    Structure: Start (Infiltrate) -> Mid 1 (Decrypt) -> Mid 2 (Capture) -> Mid 3 (Eliminate) -> End (Exfiltrate)
    Stealth: Bonus (400S/200I) if undetected until the VERY END.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

switch (_state) do {
    case "START": {
        // --- PHASE: START (Entering the Lion's Den) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];

        [
            west, 
            "Task_Apex_Parent", 
            ["To reach the absolute peak of our military capability, we must seize the enemy's classified research and development facility.", "Grand Op: Apex Predator", ""], 
            objNull, "ASSIGNED", 5, true, "fame", false
        ] call BIS_fnc_taskCreate;

        [
            west, 
            ["Task_Apex_S1", "Task_Apex_Parent"], 
            ["Infiltrate the high-security research perimeter. The guards here are elite; stay out of sight.", "Infiltrate Research Facility", ""], 
            _position, "ASSIGNED", 5, true, "spy", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Apex Predator: Phase START.";
    };

    case "MID_1": {
        // --- PHASE: MID 1 (The Encryption Barrier) ---
        ["Task_Apex_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_Apex_S2", "Task_Apex_Parent"], 
            ["Access the external terminal and bypass the security firewall to grant our team access to the main labs.", "Bypass Security Firewall", ""], 
            _position, "ASSIGNED", 5, true, "terminal", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_2": {
        // --- PHASE: MID 2 (The Prototype) ---
        ["Task_Apex_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_Apex_S3", "Task_Apex_Parent"], 
            ["Seize the experimental technology prototypes. These assets are vital for our final base upgrades.", "Secure R&D Prototypes", ""], 
            _position, "ASSIGNED", 5, true, "box", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_3": {
        // --- PHASE: MID 3 (The Cleaners) ---
        ["Task_Apex_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_Apex_S4", "Task_Apex_Parent"], 
            ["The facility's director has ordered a scorched-earth protocol. Eliminate the security detail before they destroy the research data.", "Neutralize Security Detail", ""], 
            _position, "ASSIGNED", 5, true, "target", false
        ] call BIS_fnc_taskCreate;
    };

    case "END": {
        // --- PHASE: END (The Final Ghost) ---
        ["Task_Apex_S4", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_Apex_S5", "Task_Apex_Parent"], 
            ["Data secured. Prototypes extracted. Reach the final extraction point to finalize the tech transfer.", "Reach Extraction Point", ""], 
            _position, "ASSIGNED", 5, true, "exit", false
        ] call BIS_fnc_taskCreate;
    };

    case "COMPLETE": {
        // --- MISSION SUCCESS & TIER 5 UNLOCK ---
        ["Task_Apex_S5", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_Apex_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // STEALTH REWARD CHECK
        if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
            [400, "SUPPLIES"] call MWF_fnc_addResource;
            [200, "INTEL"] call MWF_fnc_addResource;
            [["PREDATOR STATUS", "400 Supplies and 200 Intel bonus. You were never there."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        // FINAL REWARD LOGIC
        missionNamespace setVariable ["MWF_Unlock_Tier5", true, true];
        
        [
            ["MAXIMUM TIER UNLOCKED", "Tier 5 Base Upgrades are now available. The peak of technology is ours."],
            "success"
        ] remoteExec ["MWF_fnc_showNotification", 0];
        
        private _impactProfile = ["main", "apex_predator"] call MWF_fnc_getMissionImpactProfile;
        [_impactProfile, createHashMapFromArray [["loud", true]]] call MWF_fnc_applyMissionImpact;

        ["APEX_PREDATOR"] call MWF_fnc_finalizeMainOperation;
        diag_log "[MWF Grand Op] Apex Predator: Operation Complete. Tier 5 Unlocked.";
    };
};
