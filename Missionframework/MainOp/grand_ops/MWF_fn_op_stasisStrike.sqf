/*
    Author: Theane / Gemini
    Operation: Stasis Strike
    Reward: Tier Freeze (60 Minutes)
    Structure: Start (Infiltrate) -> Mid 1 (Virus) -> Mid 2 (Jamming) -> End (Exfiltrate)
    Stealth: Bonus (400S/200I) if undetected until the VERY END.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

switch (_state) do {
    case "START": {
        // --- PHASE: START (Digital Entry) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];

        [
            west, 
            "Task_StasisStrike_Parent", 
            ["The enemy is preparing a massive surge in reinforcements. We must paralyze their command network to prevent them from escalating the conflict.", "Grand Op: Stasis Strike", ""], 
            objNull, "ASSIGNED", 5, true, "network", false
        ] call BIS_fnc_taskCreate;

        [
            west, 
            ["Task_StasisStrike_S1", "Task_StasisStrike_Parent"], 
            ["Infiltrate the perimeter of the regional transmission hub. Reach the server room undetected to maximize our window of opportunity.", "Infiltrate Hub", ""], 
            _position, "ASSIGNED", 5, true, "walk", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Stasis Strike: Phase START.";
    };

    case "MID_1": {
        // --- PHASE: MID 1 (The Payload) ---
        ["Task_StasisStrike_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_StasisStrike_S2", "Task_StasisStrike_Parent"], 
            ["Upload the 'Stasis' logic bomb into the central array. This will create a feedback loop in their deployment protocols.", "Upload Logic Bomb", ""], 
            _position, "ASSIGNED", 5, true, "download", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_2": {
        // --- PHASE: MID 2 (Electronic Warfare) ---
        ["Task_StasisStrike_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_StasisStrike_S3", "Task_StasisStrike_Parent"], 
            ["Destroy the backup satellite uplinks on the roof to ensure the virus cannot be purged by high-command.", "Destroy Satellite Uplinks", ""], 
            _position, "ASSIGNED", 5, true, "destroy", false
        ] call BIS_fnc_taskCreate;
    };

    case "END": {
        // --- PHASE: END (Ghost in the Machine) ---
        ["Task_StasisStrike_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_StasisStrike_S4", "Task_StasisStrike_Parent"], 
            ["Network isolation achieved. Exfiltrate the area before the enemy realizes the scale of the disruption.", "Exfiltrate Area", ""], 
            _position, "ASSIGNED", 5, true, "exit", false
        ] call BIS_fnc_taskCreate;
    };

    case "COMPLETE": {
        // --- MISSION SUCCESS & FREEZE LOGIC ---
        ["Task_StasisStrike_S4", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_StasisStrike_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // STEALTH REWARD CHECK
        if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
            [400, "SUPPLIES"] call MWF_fnc_addResource;
            [200, "INTEL"] call MWF_fnc_addResource;
            [["NETWORK SILENCE", "400 Supplies and 200 Intel bonus awarded for flawless infiltration."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        // TIER FREEZE LOGIC
        missionNamespace setVariable ["MWF_TierFreeze_Active", true, true];
        missionNamespace setVariable ["MWF_TierFreeze_EndTime", (serverTime + 3600), true]; // 60 Minutes
        
        [
            ["OPFOR PROGRESSION FROZEN", "Enemy command is in disarray. Tier progression halted for 60 minutes."],
            "success"
        ] remoteExec ["MWF_fnc_showNotification", 0];
        
        [] call MWF_fnc_saveGame;
        diag_log "[MWF Grand Op] Stasis Strike: Operation Complete. Tier Frozen for 1 hour.";
    };
};
