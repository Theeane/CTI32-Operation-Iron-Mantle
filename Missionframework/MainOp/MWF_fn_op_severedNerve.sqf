/*
    Author: Theane / Gemini
    Operation: Severed Nerve
    Reward: OPFOR Tier Reduction (-1 Level)
    Structure: Start (Contact) -> Mid 1 (Eavesdrop) -> Mid 2 (Assassinate) -> Mid 3 (Sabotage) -> End (Exfiltrate)
    Stealth: Bonus (400S/200I) if undetected until the VERY END.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

switch (_state) do {
    case "START": {
        // --- PHASE: START (Behind Enemy Lines) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];

        [
            west, 
            "Task_SeveredNerve_Parent", 
            ["By destabilizing the enemy's logistical hub and eliminating key command personnel, we can force a regional de-escalation of OPFOR forces.", "Grand Op: Severed Nerve", ""], 
            objNull, "ASSIGNED", 5, true, "group", false
        ] call BIS_fnc_taskCreate;

        [
            west, 
            ["Task_SeveredNerve_S1", "Task_SeveredNerve_Parent"], 
            ["Link up with the local informant at the designated coordinates to receive the latest enemy movement patterns.", "Meet Informant", ""], 
            _position, "ASSIGNED", 5, true, "meet", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Severed Nerve: Phase START.";
    };

    case "MID_1": {
        // --- PHASE: MID 1 (Intelligence Gathering) ---
        ["Task_SeveredNerve_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_SeveredNerve_S2", "Task_SeveredNerve_Parent"], 
            ["Bug the enemy communication relay. Do not destroy it; we need them to transmit their panic once we strike.", "Wiretap Relay", ""], 
            _position, "ASSIGNED", 5, true, "radio", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_2": {
        // --- PHASE: MID 2 (The Scalpel) ---
        ["Task_SeveredNerve_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_SeveredNerve_S3", "Task_SeveredNerve_Parent"], 
            ["Locate and eliminate the High-Ranking Logistics Officer. His death will paralyze the local command structure.", "Eliminate Logistics Officer", ""], 
            _position, "ASSIGNED", 5, true, "kill", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_3": {
        // --- PHASE: MID 3 (Supply Disruption) ---
        ["Task_SeveredNerve_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_SeveredNerve_S4", "Task_SeveredNerve_Parent"], 
            ["The enemy is scrambled. Use this chaos to destroy their primary fuel reserves at the depot.", "Sabotage Fuel Reserves", ""], 
            _position, "ASSIGNED", 5, true, "destroy", false
        ] call BIS_fnc_taskCreate;
    };

    case "END": {
        // --- PHASE: END (The Ghost Exit) ---
        ["Task_SeveredNerve_S4", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_SeveredNerve_S5", "Task_SeveredNerve_Parent"], 
            ["Operation objectives met. Reach the extraction point. If you remain undetected until exit, a massive intelligence bonus will be granted.", "Reach Extraction", ""], 
            _position, "ASSIGNED", 5, true, "exit", false
        ] call BIS_fnc_taskCreate;
    };

    case "COMPLETE": {
        // --- MISSION SUCCESS & REWARDS ---
        ["Task_SeveredNerve_S5", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_SeveredNerve_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // STEALTH REWARD CHECK (Final payout)
        if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
            [400, "SUPPLIES"] call MWF_fnc_addResource;
            [200, "INTEL"] call MWF_fnc_addResource;
            [["GHOST OPERATIVES", "The enemy has no idea what hit them. 400 Supplies and 200 Intel bonus awarded."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        // GLOBAL TIER REDUCTION LOGIC
        private _currentTier = missionNamespace getVariable ["MWF_WorldTier", 1];
        if (_currentTier > 1) then {
            missionNamespace setVariable ["MWF_WorldTier", (_currentTier - 1), true];
        };
        
        [["OPFOR DE-ESCALATION", "Enemy presence has been reduced by one Tier across the region."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
        
        [] call MWF_fnc_saveGame;
        diag_log "[MWF Grand Op] Severed Nerve: Operation Complete. OPFOR Tier Reduced.";
    };
};
