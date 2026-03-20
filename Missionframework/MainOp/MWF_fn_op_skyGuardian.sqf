/*
    Author: Gemini / ChatGPT / Copilot (Collaborative Build)
    Operation: Sky Guardian
    Reward: Heli-Unlock + Potential "Logistics Data" Discount
    Structure: Start (Radar Sabotage) -> Mid 1 (HVT Officer) -> End (Airfield Seizure)
    Stealth Bonus: 400S / 200I (Granted at MID_1 if undetected)
    
    REACTIVE LOGIC:
    - Radar Destruction: 0-3 radars destroyed impacts AA density in the END phase.
    - Intelligence Perk: Full stealth until MID_1 grants a 10% discount on all helicopter purchases.
*/

params [
    ["_state", "START", [""]],
    ["_position", [0,0,0], [[]]]
];

if (!isServer) exitWith {};

private _isRestore = missionNamespace getVariable ["MWF_MainOperationRestoreMode", false];

switch (_state) do {
    case "START": {
        // --- PHASE: START (Blind the Giant) ---
        missionNamespace setVariable ["MWF_Op_Detected", false, true];
        missionNamespace setVariable ["MWF_SkyGuardian_RadarsDestroyed", 0, true]; // Track variable success

        [
            west, 
            "Task_SkyGuardian_Parent", 
            ["The enemy's integrated air defense network is preventing our air assets from deploying. We must dismantle their radar array and secure the regional airfield.", "Grand Op: Sky Guardian", ""], 
            objNull, "ASSIGNED", 5, true, "air", false
        ] call BIS_fnc_taskCreate;

        [
            west, 
            ["Task_SkyGuardian_S1", "Task_SkyGuardian_Parent"], 
            ["Locate and destroy 3 mobile radar units. Each unit destroyed will weaken the airfield's defenses during the final assault.", "Sabotage Radar Array (0/3)", ""], 
            _position, "ASSIGNED", 5, true, "destroy", false
        ] call BIS_fnc_taskCreate;

        diag_log "[MWF Grand Op] Sky Guardian: Initialized with Reactive Layers.";
    };

    case "MID_1": {
        // --- PHASE: MID 1 (The Keyholder) ---
        ["Task_SkyGuardian_S1", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // CHECK STEALTH & APPLY PERMANENT DISCOUNT PERK
        if !(_isRestore) then {
            if !(missionNamespace getVariable ["MWF_Op_Detected", false]) then {
                [400, "SUPPLIES"] call MWF_fnc_addResource;
                [200, "INTEL"] call MWF_fnc_addResource;
                
                // The "AI-Brain" Perk: 10% discount on Heli assets due to stolen flight logs
                missionNamespace setVariable ["MWF_Perk_HeliDiscount", 0.9, true];

                [
                    ["STEALTH RECOVERY", "Flight data recovered. 400S/200I granted and Heli costs reduced by 10%."],
                    "info"
                ] remoteExec ["MWF_fnc_showNotification", 0];
            } else {
                [
                    ["STEALTH COMPROMISED", "Data wiped by enemy. No logistics discount granted."],
                    "warning"
                ] remoteExec ["MWF_fnc_showNotification", 0];
            };
        };

        [
            west, 
            ["Task_SkyGuardian_S2", "Task_SkyGuardian_Parent"], 
            ["Capture or eliminate the AA-Commander. His codes are required to bypass the airfield's security systems.", "Neutralize AA Commander", ""], 
            _position, "ASSIGNED", 5, true, "target", false
        ] call BIS_fnc_taskCreate;
    };

    case "END": {
        // --- PHASE: END (The Airfield Assault) ---
        ["Task_SkyGuardian_S2", "SUCCEEDED"] call BIS_fnc_taskSetState;

        // CALCULATE ENEMY REACTION (Responsive Difficulty)
        private _radarsDestroyed = missionNamespace getVariable ["MWF_SkyGuardian_RadarsDestroyed", 0];
        private _aaDensity = "LOW";
        
        if (_radarsDestroyed < 3) then { _aaDensity = "MEDIUM"; };
        if (_radarsDestroyed < 1) then { _aaDensity = "CRITICAL"; };

        [
            west, 
            ["Task_SkyGuardian_S3", "Task_SkyGuardian_Parent"], 
            [format ["Secure the airfield. Intelligence suggests %1 enemy air defense presence based on our radar sabotage performance.", _aaDensity], "Seize the Airfield", ""], 
            _position, "ASSIGNED", 5, true, "flag", false
        ] call BIS_fnc_taskCreate;

        // Logic note: Spawn scripts will now check _aaDensity to determine unit count.
        diag_log format ["[MWF Grand Op] Sky Guardian: Final phase triggered with %1 AA density.", _aaDensity];
    };

    case "COMPLETE": {
        // --- MISSION SUCCESS ---
        ["Task_SkyGuardian_S3", "SUCCEEDED"] call BIS_fnc_taskSetState;
        ["Task_SkyGuardian_Parent", "SUCCEEDED"] call BIS_fnc_taskSetState;

        private _impactProfile = ["main", "sky_guardian"] call MWF_fnc_getMissionImpactProfile;
        private _alreadyUnlocked = missionNamespace getVariable ["MWF_Unlock_Heli", false];
        private _impactContext = createHashMapFromArray [["loud", true]];

        if (_alreadyUnlocked) then {
            private _fallbackSupplies = _impactProfile getOrDefault ["fallbackSupplies", 0];
            private _fallbackIntel = _impactProfile getOrDefault ["fallbackIntel", 0];

            if (_fallbackSupplies > 0) then { [_fallbackSupplies, "SUPPLIES"] call MWF_fnc_addResource; };
            if (_fallbackIntel > 0) then { [_fallbackIntel, "INTEL"] call MWF_fnc_addResource; };

            _impactContext set ["suppressFallbackRewards", true];

            [["AIRFIELD CACHE SECURED", format ["Helicopter unlock already secured. Operation converted to %1 Supplies and %2 Intel.", _fallbackSupplies, _fallbackIntel]], "success"] remoteExec ["MWF_fnc_showNotification", 0];
        } else {
            missionNamespace setVariable ["MWF_Unlock_Heli", true, true];
            [["OPERATION SUCCESSFUL", "Airfield secured. Helicopter assets are now available for purchase."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        private _impactResult = [_impactProfile, _impactContext] call MWF_fnc_applyMissionImpact;

        ["SKY_GUARDIAN"] call MWF_fnc_finalizeMainOperation;

        private _logMessage = if (_alreadyUnlocked || {_impactResult getOrDefault ["fallbackUsed", false]}) then {
            format [
                "[MWF Grand Op] Sky Guardian: Replay completed. Fallback payout applied (%1 Supplies / %2 Intel).",
                _impactResult getOrDefault ["suppliesGranted", 0],
                _impactResult getOrDefault ["intelGranted", 0]
            ]
        } else {
            "[MWF Grand Op] Sky Guardian: Fully Completed. Helicopters unlocked."
        };
        diag_log _logMessage;
    };
};
