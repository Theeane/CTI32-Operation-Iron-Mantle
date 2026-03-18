/*
    Author: Theane / Gemini
    Operation: Steel Rain
    Reward: Armor-Unlock (Tanks/APCs)
    Structure: Start (Capture Depot) -> Mid (Secure Supplies) -> End (Defend Assets)
    Stealth: Bonus (400S/200I) if undetected until the VERY END.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

switch (_state) do {
    case "START": {
        // --- PHASE: START (Hammer and Anvil) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];

        [
            west, 
            "Task_SteelRain_Parent", 
            ["To deploy our heavy armor, we need the enemy's specialized maintenance infrastructure and fuel reserves. We must seize their armored depot.", "Grand Op: Steel Rain", ""], 
            objNull, "ASSIGNED", 5, true, "armor", false
        ] call BIS_fnc_taskCreate;

        [
            west, 
            ["Task_SteelRain_S1", "Task_SteelRain_Parent"], 
            ["Infiltrate or storm the central armored depot. Neutralize the perimeter guards and secure the main gate.", "Seize Armored Depot", ""], 
            _position, "ASSIGNED", 5, true, "attack", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Steel Rain: Phase START.";
    };

    case "MID": {
        // --- PHASE: MID (Logistical Control) ---
        ["Task_SteelRain_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_SteelRain_S2", "Task_SteelRain_Parent"], 
            ["Secure the heavy vehicle workshops and fuel pumping stations. We need these intact to support our own armor deployment.", "Secure Maintenance Workshops", ""], 
            _position, "ASSIGNED", 5, true, "mainten", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Steel Rain: Phase MID reached.";
    };

    case "END": {
        // --- PHASE: END (Hold the Line) ---
        ["Task_SteelRain_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west, 
            ["Task_SteelRain_S3", "Task_SteelRain_Parent"], 
            ["Enemy armored QRF is inbound to retake the depot. Establish defensive positions and hold the facility until our logistics teams arrive.", "Defend Depot Perimeter", ""], 
            _position, "ASSIGNED", 5, true, "defend", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Steel Rain: Final Phase triggered.";
    };

    case "COMPLETE": {
        // --- MISSION SUCCESS & ARMOR UNLOCK ---
        ["Task_SteelRain_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_SteelRain_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // STEALTH REWARD CHECK
        if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
            [400, "SUPPLIES"] call MWF_fnc_addResource;
            [200, "INTEL"] call MWF_fnc_addResource;
            [["GHOST IN THE DEPOT", "400 Supplies and 200 Intel recovered. The enemy was blindsided by the capture."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        // REWARD LOGIC
        missionNamespace setVariable ["MWF_Unlock_Armor", true, true];
        
        [
            ["ARMORED ASSETS ONLINE", "Heavy armor and APCs are now available for purchase."],
            "success"
        ] remoteExec ["MWF_fnc_showNotification", 0];
        
        private _impactProfile = ["main", "steel_rain"] call MWF_fnc_getMissionImpactProfile;
        [_impactProfile, createHashMapFromArray [["loud", true]]] call MWF_fnc_applyMissionImpact;

        missionNamespace setVariable ["MWF_GrandOperationActive", false, true];
        missionNamespace setVariable ["MWF_CurrentGrandOperation", "", true];
        missionNamespace setVariable ["MWF_CurrentGrandOperationTitle", "", true];
        missionNamespace setVariable ["MWF_CurrentGrandOperationPlacement", [], true];

        [] call MWF_fnc_saveGame;
        diag_log "[MWF Grand Op] Steel Rain: Operation Complete. Tanks/APCs Unlocked.";
    };
};
