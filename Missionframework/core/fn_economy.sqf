/*
    Author: Theane using Gemini (AGS Project)
    Description: Core Economy Engine. 
    Synced with: fn_zoneManager.sqf to ensure correct payouts based on captured territory.
*/

if (!isServer) exitWith {};

// --- 1. WAIT FOR INITIALIZATION ---
// We wait until the Zone Manager has scanned the map and created the zones
waitUntil { !isNil "AGS_all_mission_zones" };
diag_log "AGS Economy: Zones detected, starting economy engine.";

// --- 2. INITIALIZE GLOBAL CURRENCY ---
private _startSupplies = ["AGS_Param_StartSupplies", 500] call BIS_fnc_getParamValue;
missionNamespace setVariable ["AGS_valuta_supplies", _startSupplies, true];
missionNamespace setVariable ["AGS_valuta_intel", 0, true];
// Note: AGS_captured_zones_list is managed by fn_zoneManager.sqf

// --- 3. THE PASSIVE INCOME LOOP ---
[] spawn {
    // Get income interval from params (Default 10 min)
    private _intervalMinutes = ["AGS_Param_IncomeInterval", 10] call BIS_fnc_getParamValue;
    private _sleepTime = _intervalMinutes * 60;

    while {true} do {
        uiSleep _sleepTime;

        private _totalIncome = 0;
        private _capturedZones = missionNamespace getVariable ["AGS_captured_zones_list", []];

        {
            private _zoneType = _x getVariable ["AGS_zoneType", "Village"];
            
            // Payouts based on the types defined in Zone Manager
            private _income = switch (_zoneType) do {
                case "Factory": { 150 }; // Major industrial hubs / Capitals
                case "City":    { 100 }; // Standard cities
                case "Village": { 40 };  // Small settlements
                case "Outpost": { 25 };  // Military points (Lower income, but strategic)
                default { 30 };
            };
            
            _totalIncome = _totalIncome + _income;
        } forEach _capturedZones;

        // Apply payout if players own any zones
        if (_totalIncome > 0) then {
            private _current = missionNamespace getVariable ["AGS_valuta_supplies", 0];
            missionNamespace setVariable ["AGS_valuta_supplies", _current + _totalIncome, true];
            
            // Global notification so players know why they got money
            [format ["Income Received: +%1 Supplies from %2 zones.", _totalIncome, count _capturedZones]] remoteExec ["systemChat", 0];
            diag_log format ["AGS Economy: Payout of %1 Supplies.", _totalIncome];
        };
    };
};

// --- 4. GLOBAL ACCESS FUNCTIONS ---
// Use these in other scripts to add/remove funds
AGS_fnc_updateSupplies = {
    params ["_amount"];
    private _current = missionNamespace getVariable ["AGS_valuta_supplies", 0];
    private _newVal = (_current + _amount) max 0; 
    missionNamespace setVariable ["AGS_valuta_supplies", _newVal, true];
};

AGS_fnc_updateIntel = {
    params ["_amount"];
    private _current = missionNamespace getVariable ["AGS_valuta_intel", 0];
    private _newVal = (_current + _amount) max 0;
    missionNamespace setVariable ["AGS_valuta_intel", _newVal, true];
};

diag_log "AGS: Economy Engine Fully Synced and Operational.";
