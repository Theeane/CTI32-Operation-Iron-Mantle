/*
    Author: Theeane / Gemini (AGS Project)
    Description: Central Economy & Resource System.
    Language: English
*/

if (!isServer) exitWith {};

// --- INITIALIZE GLOBAL RESOURCES ---
// We let initGlobals handle the starting values from Params.hpp
if (isNil "GVAR_Economy_Supplies") then { missionNamespace setVariable ["GVAR_Economy_Supplies", 0, true]; };
if (isNil "AGS_res_intel") then { missionNamespace setVariable ["AGS_res_intel", 0, true]; };
if (isNil "AGS_res_notoriety") then { missionNamespace setVariable ["AGS_res_notoriety", 0, true]; };

// --- MAIN ECONOMY LOOP ---
[] spawn {
    while {true} do {
        // Hämta intervallet från våra Params (standard 60s om inget annat satts)
        private _sleepTime = (missionNamespace getVariable ["GVAR_Economy_SupplyInterval", 1]) * 60;
        uiSleep _sleepTime; 

        private _allZones = missionNamespace getVariable ["AGS_all_mission_zones", []];
        private _incomeSupplies = 0;
        private _activeZonesCount = 0;
        private _underAttackCount = 0;

        {
            private _isCaptured = _x getVariable ["AGS_isCaptured", false];
            private _isUnderAttack = _x getVariable ["AGS_underAttack", false];

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
            private _currentSupplies = missionNamespace getVariable ["GVAR_Economy_Supplies", 0];
            missionNamespace setVariable ["GVAR_Economy_Supplies", _currentSupplies + _incomeSupplies, true];
            
            [format ["Income received: +%1 Supplies.", _incomeSupplies]] remoteExec ["systemChat", 0];
        };

        // --- NOTORIETY DECAY ---
        private _currentNotoriety = missionNamespace getVariable ["AGS_res_notoriety", 0];
        if (_currentNotoriety > 0) then {
            // Vi hämtar vår multiplier från Params här också!
            private _decay = missionNamespace getVariable ["GVAR_Economy_HeatMult", 1];
            missionNamespace setVariable ["AGS_res_notoriety", (0 max (_currentNotoriety - _decay)), true];
        };

        // Tvinga alla spelares HUD att uppdateras efter inkomst
        remoteExec ["AGS_fnc_updateResourceUI", 0];

        diag_log format ["[AGS Economy] Safe Zones: %1 | Under Attack: %2 | Income: +%3", _activeZonesCount, _underAttackCount, _incomeSupplies];
    };
};

/**
 * Global function to manually add/remove resources
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
    
    // Uppdatera HUD direkt vid manuella tillägg
    remoteExec ["AGS_fnc_updateResourceUI", 0];
    
    if (!isNil "AGS_fnc_requestDelayedSave") then {
        [] spawn AGS_fnc_requestDelayedSave;
    };
};
