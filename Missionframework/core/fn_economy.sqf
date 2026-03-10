/*
    Author: Theane using gemini (AGS Project)
    Description: Central Economy & Resource System.
    Logic: 
    - Generates Supplies from captured zones.
    - Pauses income if a zone is "Under Attack".
    - Handles Intel collection and Notoriety decay.
    Language: English
*/

if (!isServer) exitWith {};

// --- INITIALIZE GLOBAL RESOURCES (If not loaded from Persistence) ---
if (isNil "AGS_res_supplies") then { missionNamespace setVariable ["AGS_res_supplies", 100, true]; };
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
                    // Normal Income: +2 Supplies per safe zone
                    _incomeSupplies = _incomeSupplies + 2;
                    _activeZonesCount = _activeZonesCount + 1;
                } else {
                    // SUPPLY LINE INTERRUPTED
                    _underAttackCount = _underAttackCount + 1;
                };
            };
        } forEach _allZones;

        // Apply Supply Income
        if (_incomeSupplies > 0) then {
            private _currentSupplies = missionNamespace getVariable ["AGS_res_supplies", 0];
            missionNamespace setVariable ["AGS_res_supplies", _currentSupplies + _incomeSupplies, true];
        };

        // --- NOTORIETY DECAY ---
        // Your heat levels drop slowly over time (-1% per minute)
        private _currentNotoriety = missionNamespace getVariable ["AGS_res_notoriety", 0];
        if (_currentNotoriety > 0) then {
            private _decay = 1; 
            // If no players are fired recently, decay faster? (Optional future logic)
            missionNamespace setVariable ["AGS_res_notoriety", (0 max (_currentNotoriety - _decay)), true];
        };

        // --- LOGGING (Server Console) ---
        diag_log format ["AGS Economy: Safe Zones: %1 | Under Attack: %2 | Income: +%3 Supplies | Notoriety: %4%5", 
            _activeZonesCount, 
            _underAttackCount, 
            _incomeSupplies, 
            missionNamespace getVariable "AGS_res_notoriety", 
            "%"
        ];

        // If zones are under attack, notify players of the lost income
        if (_underAttackCount > 0) then {
            [format ["Supply lines interrupted in %1 sectors! Defend them to restore income.", _underAttackCount]] remoteExec ["systemChat", 0];
        };
    };
};

/**
 * Function to manually add/remove resources (use this in other scripts)
 * Example: [50, "SUPPLIES"] call AGS_fnc_addResource;
 */
AGS_fnc_addResource = {
    params ["_amount", "_type"];
    
    switch (toUpper _type) do {
        case "SUPPLIES": {
            private _val = missionNamespace getVariable ["AGS_res_supplies", 0];
            missionNamespace setVariable ["AGS_res_supplies", (_val + _amount), true];
        };
        case "INTEL": {
            private _val = missionNamespace getVariable ["AGS_res_intel", 0];
            missionNamespace setVariable ["AGS_res_intel", (_val + _amount), true];
        };
        case "NOTORIETY": {
            private _val = missionNamespace getVariable ["AGS_res_notoriety", 0];
            // Clamp notoriety between 0 and 100
            missionNamespace setVariable ["AGS_res_notoriety", (0 max (100 min (_val + _amount))), true];
        };
    };
    
    // Trigger a delayed save when resources change significantly
    [] spawn AGS_fnc_requestDelayedSave;
};
