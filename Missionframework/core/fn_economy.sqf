/*
    Author: Theane / ChatGPT
    Function: fn_economy
    Project: Military War Framework

    Description:
    Handles economy for the core framework layer.
*/

if (!isServer) exitWith {};

// --- INITIALIZE GLOBAL RESOURCES ---
// We let initGlobals handle the starting values from Params.hpp
if (isNil "MWF_Economy_Supplies") then { missionNamespace setVariable ["MWF_Economy_Supplies", 0, true]; };
if (isNil "MWF_res_intel") then { missionNamespace setVariable ["MWF_res_intel", 0, true]; };
if (isNil "MWF_res_notoriety") then { missionNamespace setVariable ["MWF_res_notoriety", 0, true]; };

// --- MAIN ECONOMY LOOP ---
[] spawn {
    while {true} do {
        // Get the interval from mission params, defaulting to 60 seconds
        private _sleepTime = (missionNamespace getVariable ["MWF_Economy_SupplyInterval", 1]) * 60;
        uiSleep _sleepTime; 

        private _allZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
        private _incomeSupplies = 0;
        private _activeZonesCount = 0;
        private _underAttackCount = 0;

        {
            private _isCaptured = _x getVariable ["MWF_isCaptured", false];
            private _isUnderAttack = _x getVariable ["MWF_underAttack", false];

            if (_isCaptured) then {
                if (!_isUnderAttack) then {
                    _incomeSupplies = _incomeSupplies + 5; 
                    _activeZonesCount = _activeZonesCount + 1;
                } else {
                    _underAttackCount = _underAttackCount + 1;
                };
            };
        } forEach _allZones;

        if (_incomeSupplies > 0) then {
            private _currentSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
            missionNamespace setVariable ["MWF_Economy_Supplies", _currentSupplies + _incomeSupplies, true];
            
            [format ["Income received: +%1 Supplies.", _incomeSupplies]] remoteExec ["systemChat", 0];
        };

        // --- NOTORIETY DECAY ---
        private _currentNotoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
        if (_currentNotoriety > 0) then {
            // Read the income multiplier from mission params
            private _decay = missionNamespace getVariable ["MWF_Economy_HeatMult", 1];
            missionNamespace setVariable ["MWF_res_notoriety", (0 max (_currentNotoriety - _decay)), true];
        };

        // Force all player HUDs to update after income is added
        remoteExec ["MWF_fnc_updateResourceUI", 0];

        diag_log format ["[AGS Economy] Safe Zones: %1 | Under Attack: %2 | Income: +%3", _activeZonesCount, _underAttackCount, _incomeSupplies];
    };
};

/**
 * Global function to manually add/remove resources
 */
MWF_fnc_addResource = {
    params ["_amount", "_type"];
    
    switch (toUpper _type) do {
        case "SUPPLIES": {
            private _val = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
            missionNamespace setVariable ["MWF_Economy_Supplies", (_val + _amount), true];
        };
        case "INTEL": {
            private _val = missionNamespace getVariable ["MWF_res_intel", 0];
            missionNamespace setVariable ["MWF_res_intel", (_val + _amount), true];
        };
        case "NOTORIETY": {
            private _val = missionNamespace getVariable ["MWF_res_notoriety", 0];
            missionNamespace setVariable ["MWF_res_notoriety", (0 max (100 min (_val + _amount))), true];
        };
    };
    
    // Update the HUD immediately after manual resource changes
    remoteExec ["MWF_fnc_updateResourceUI", 0];
    
    if (!isNil "MWF_fnc_requestDelayedSave") then {
        [] spawn MWF_fnc_requestDelayedSave;
    };
};
