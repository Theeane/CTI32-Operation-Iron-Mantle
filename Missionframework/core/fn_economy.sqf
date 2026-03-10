/*
    Author: Theane using Gemini (AGS Project)
    Description: The core economy engine. 
    Handles: Passive income, zone-based multipliers, and resource transactions.
*/

if (!isServer) exitWith {};

// --- 1. INITIALIZE GLOBAL VARIABLES ---
// These are broadcasted to all players so the Terminal can see them.
missionNamespace setVariable ["AGS_valuta_supplies", ("AGS_Param_StartSupplies" call BIS_fnc_getParamValue), true];
missionNamespace setVariable ["AGS_valuta_intel", 0, true];
missionNamespace setVariable ["AGS_captured_zones_list", [], true]; // Array to store captured zone objects

// --- 2. THE PASSIVE INCOME LOOP ---
[] spawn {
    // Get the interval from your mission parameters (5, 10, 15, 20, or 30 mins)
    private _intervalMinutes = ["AGS_Param_IncomeInterval", 10] call BIS_fnc_getParamValue;
    private _sleepTime = _intervalMinutes * 60;

    diag_log format ["AGS Economy: Passive income loop started with %1 minute intervals.", _intervalMinutes];

    while {true} do {
        uiSleep _sleepTime;

        private _totalIncome = 0;
        private _capturedZones = missionNamespace getVariable ["AGS_captured_zones_list", []];

        {
            // Each captured zone provides income based on its type
            private _zoneType = _x getVariable ["AGS_zoneType", "Village"];
            
            private _income = switch (_zoneType) do {
                case "Factory": { 150 }; 
                case "City":    { 100 }; 
                case "Village": { 40 };  
                case "Outpost": { 25 };  
                default { 30 };
            };
            
            _totalIncome = _totalIncome + _income;
        } forEach _capturedZones;

        if (_totalIncome > 0) then {
            // Update the global supply count
            private _current = missionNamespace getVariable ["AGS_valuta_supplies", 0];
            missionNamespace setVariable ["AGS_valuta_supplies", _current + _totalIncome, true];
            
            // Notify server log
            diag_log format ["AGS Economy: Payout of %1 Supplies added from %2 zones.", _totalIncome, count _capturedZones];
        };
    };
};

// --- 3. GLOBAL ACCESS FUNCTIONS ---
// Other scripts will call these to add/remove resources.

// Update Supplies (Usage: [500] call AGS_fnc_updateSupplies;)
AGS_fnc_updateSupplies = {
    params ["_amount"];
    private _current = missionNamespace getVariable ["AGS_valuta_supplies", 0];
    private _newVal = (_current + _amount) max 0; // Prevent negative balance
    missionNamespace setVariable ["AGS_valuta_supplies", _newVal, true];
};

// Update Intel (Usage: [25] call AGS_fnc_updateIntel;)
AGS_fnc_updateIntel = {
    params ["_amount"];
    private _current = missionNamespace getVariable ["AGS_valuta_intel", 0];
    private _newVal = (_current + _amount) max 0;
    missionNamespace setVariable ["AGS_valuta_intel", _newVal, true];
};

diag_log "AGS: Economy Engine Fully Initialized";
