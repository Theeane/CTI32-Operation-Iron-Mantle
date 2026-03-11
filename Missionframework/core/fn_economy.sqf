/*
    Author: Theeane / Gemini (AGS Project)
    Description: Central Economy & Resource System.
    Logic: 
    - Generates Supplies from captured zones.
    - Pauses income if a zone is "Under Attack".
    - Handles Intel collection and Notoriety decay.
    Language: English
*/

if (!isServer) exitWith {};

// --- INITIALIZE GLOBAL RESOURCES (Synced with Buy Menu) ---
// We use GVAR_Economy_Supplies to match our UI scripts from today.
if (isNil "GVAR_Economy_Supplies") then { missionNamespace setVariable ["GVAR_Economy_Supplies", 100, true]; };
if (isNil "AGS_res_intel") then { missionNamespace setVariable ["AGS_res_intel", 0, true]; };
if (isNil "AGS_res_notoriety") then { missionNamespace setVariable ["AGS_res_notoriety", 0, true]; };

// --- MAIN ECONOMY LOOP ---
[] spawn {
    while {true} do {
        uiSleep 60; // Resources tick every 60 seconds

        private _allZones = missionNamespace getVariable ["AGS_all_mission_zones", []];
        private _incomeSupplies = 0;
        private _activeZonesCount = 0;
        private _underAttackCount = 0;

        {
            // Check status for each zone managed by the framework
            private _isCaptured = _x getVariable ["AGS_isCaptured", false];
            private _isUnderAttack = _x getVariable ["AGS_underAttack", false];

            if (_isCaptured) then {
                if (!_isUnderAttack) then {
                    // Normal Income: +5 Supplies per safe zone
                    _incomeSupplies = _incomeSupplies + 5; 
                    _activeZonesCount = _activeZonesCount + 1;
                } else {
                    // SUPPLY LINE INTERRUPTED
                    _underAttackCount = _underAttackCount + 1;
                };
            };
        } forEach _allZones;

        // Apply Supply Income to the global pool
        if (_incomeSupplies > 0) then {
            private _currentSupplies = missionNamespace getVariable ["GVAR_Economy_Supplies", 0];
            missionNamespace setVariable ["GVAR_Economy_Supplies", _currentSupplies + _incomeSupplies, true];
            
            // Optional: Notification to players that money has arrived
            [format ["Income received: +%1 Supplies.", _incomeSupplies]] remoteExec ["systemChat", 0];
        };

        // --- NOTORIETY DECAY ---
        // Your heat levels drop slowly over time (-1 unit per minute)
        private _currentNotoriety = missionNamespace getVariable ["AGS_res_notoriety", 0];
        if (_currentNotoriety > 0) then {
            missionNamespace setVariable ["AGS_res_notoriety", (0 max (_currentNotoriety - 1)), true];
        };

        // --- LOGGING (Server Console) ---
        diag_log format ["[AGS Economy] Safe Zones: %1 | Under Attack: %2 | Income: +%3 | Total Supplies: %4", 
            _activeZonesCount, 
            _underAttackCount, 
            _incomeSupplies, 
            missionNamespace getVariable "GVAR_Economy_Supplies"
        ];

        // Notify players if income is blocked by enemy presence
        if (_underAttackCount > 0) then {
            [format ["Supply lines interrupted in %1 sectors! Defend them to restore income.", _underAttackCount]] remoteExec ["systemChat", 0];
        };
    };
};

/**
 * Global function to manually add/remove resources (use this in other scripts)
 * Example: [50, "SUPPLIES"] call AGS_fnc_addResource;
 */
AGS_fnc_addResource = {
    params ["_amount", "_type"];
    
    switch (toUpper _type) do {
        case "SUPPLIES": {
            private _val = missionNamespace getVariable ["GVAR_Economy_Supplies", 0];
            missionNamespace setVariable ["GVAR_Economy_Supplies", (_val + _amount), true];
        };
        case "INTEL": {
            private _val = missionNamespace getVariable ["AGS_res_intel", 0];
            missionNamespace setVariable ["AGS_res_intel", (_val + _amount), true];
        };
        case "NOTORIETY": {
            private _val = missionNamespace getVariable ["AGS_res_notoriety", 0];
            missionNamespace setVariable ["AGS_res_notoriety", (0 max (100 min (_val + _amount))), true];
        };
    };
    
    // Trigger a save if the persistence system is active
    if (!isNil "AGS_fnc_requestDelayedSave") then {
        [] spawn AGS_fnc_requestDelayedSave;
    };
};
