/*
    Author: Theane / Gemini
    Operation: Point Blank
    Reward: Jet-Unlock
    Structure: Start (Infiltrate) -> Mid 1 (Sabotage) -> Mid 2 (Data) -> Mid 3 (Assault) -> End (Neutralize)
    Stealth: Bonus (400S/200I) if undetected until Mid 2 is completed.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

switch (_state) do {
    case "START": {
        // --- PHASE: START (Insertion) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];

        [
            west, 
            "Task_PointBlank_Parent", 
            ["The enemy's long-range missile silos and command center are the final barriers to our air superiority. Neutralize their strategic capabilities to clear the skies for our Jets.", "Grand Op: Point Blank", ""], 
            objNull, "ASSIGNED", 5, true, "plane", false
        ] call BIS_fnc_taskCreate;

        [
            west, 
            ["Task_PointBlank_S1", "Task_PointBlank_Parent"], 
            ["Infiltrate the outer perimeter of the missile complex. Avoid detection to maintain the element of surprise.", "Infiltrate Perimeter", ""], 
            _position, "ASSIGNED", 5, true, "walk", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Point Blank: Phase START.";
    };

    case "MID_1": {
        // --- PHASE: MID 1 (Sabotage) ---
        ["Task_PointBlank_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_PointBlank_S2", "Task_PointBlank_Parent"], 
            ["Disable the cooling systems of the main missile silos. This will force the blast doors open and cripple their launch capability.", "Sabotage Cooling Systems", ""], 
            _position, "ASSIGNED", 5, true, "destroy", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_2": {
        // --- PHASE: MID 2 (Data Theft & Stealth Check) ---
        ["Task_PointBlank_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // STEALTH REWARD CHECK
        if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
            [400, "SUPPLIES"] call MWF_fnc_addResource;
            [200, "INTEL"] call MWF_fnc_addResource;
            [["STEALTH MASTERED", "400 Supplies and 200 Intel secured from the internal vault."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        } else {
            [["ENEMIES ALERTED", "Strategic bonus data was encrypted before recovery."], "warning"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        [
            west, 
            ["Task_PointBlank_S3", "Task_PointBlank_Parent"], 
            ["Access the central mainframe and download the regional flight override codes. Expect increased resistance.", "Recover Flight Codes", ""], 
            _position, "ASSIGNED", 5, true, "download", false
        ] call BIS_fnc_taskCreate;
    };

    case "MID_3": {
        // --- PHASE: MID 3 (The Assault) ---
        ["Task_PointBlank_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_PointBlank_S4", "Task_PointBlank_Parent"], 
            ["The facility is on high alert. Neutralize the QRF forces arriving at the main gate to prevent them from locking down the silos.", "Repel Counter-Attack", ""], 
            _position, "ASSIGNED", 5, true, "defend", false
        ] call BIS_fnc_taskCreate;
    };

    case "END": {
        // --- PHASE: END (Final Strike) ---
        ["Task_PointBlank_S4", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_PointBlank_S5", "Task_PointBlank_Parent"], 
            ["All pieces are in place. Destroy the Command & Control relay to permanently blind the enemy's air defense.", "Neutralize Command Relay", ""], 
            _position, "ASSIGNED", 5, true, "target", false
        ] call BIS_fnc_taskCreate;
    };

    case "COMPLETE": {
        ["Task_PointBlank_S5", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_PointBlank_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        missionNamespace setVariable ["MWF_Unlock_Jets", true, true];
        
        [["STRATEGIC VICTORY", "Jet assets are now operational at the main airbase."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
        private _impactProfile = ["main", "point_blank"] call MWF_fnc_getMissionImpactProfile;
        [_impactProfile, createHashMapFromArray [["loud", true]]] call MWF_fnc_applyMissionImpact;

        ["POINT_BLANK"] call MWF_fnc_finalizeMainOperation;
        diag_log "[MWF Grand Op] Point Blank: Operation Complete. Jets Unlocked.";
    };
};
