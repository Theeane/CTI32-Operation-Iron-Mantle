/*
    Author: Theeane / Gemini (AGS Project)
    Description: Central Economy & Resource System.
    Logic: 
    - Generates Supplies from captured zones.
    - Pauses income if a zone is "Under Attack".
    - Handles Notoriety decay.
*/

if (!isServer) exitWith {};

// --- INITIALIZE GLOBAL RESOURCES (Synced with Buy Menu) ---
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
            private _isCaptured = _x getVariable ["AGS_isCaptured", false];
            private _isUnderAttack = _x getVariable ["AGS_underAttack", false];

            if (_isCaptured) then {
                if (!_isUnderAttack) then {
                    // Normal Income: +5 Supplies per safe zone (Adjusted for Buy Menu prices)
                    _incomeSupplies = _incomeSupplies + 5; 
                    _activeZonesCount = _activeZonesCount + 1;
                } else {
                    // SUPPLY LINE INTERRUPTED
                    _underAttackCount = _underAttackCount + 1;
                };
            };
        } forEach _allZones;

        // Apply Supply Income
        if (_incomeSupplies > 0) then {
            private _currentSupplies = missionNamespace getVariable ["GVAR_Economy_Supplies", 0];
            missionNamespace setVariable ["GVAR_Economy_Supplies", _currentSupplies + _incomeSupplies, true];
            
            // Notification to players (Optional: only if income > 0)
            [format ["Income received: +%1 Supplies.", _incomeSupplies]] remoteExec ["systemChat", 0];
        };

        // --- NOTORIETY DECAY ---
        private _currentNotoriety = missionNamespace getVariable ["AGS_res_notoriety", 0];
        if (_currentNotoriety > 0) then {
            missionNamespace setVariable ["AGS_res_notoriety", (0 max (_currentNotoriety - 1)), true];
        };

        // Log to Server Console
        diag_log format ["[AGS Economy] Zones: %1 | Under Attack: %2 | Income: +%3 | Total: %4", 
            _activeZonesCount, _underAttackCount, _incomeSupplies, missionNamespace getVariable "GVAR_Economy_Supplies"];

        if (_underAttackCount > 0) then {
            ["Supply lines interrupted! Defend sectors to restore full income."] remoteExec ["systemChat", 0];
        };
    };
};

/**
 * Global helper function to add/remove resources
 * Matches your previous setup but uses synced variable names.
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
    
    // Save trigger (Keep this if you have persistence)
    if (!isNil "AGS_fnc_requestDelayedSave") then { [] spawn AGS_fnc_requestDelayedSave; };
};
