/* Author: Theeane
    Function: CTI_fnc_economyManager
    Description: 
    Main server-side loop for handling resource income (Supplies & Intel).
    Calculates income based on controlled zones and multipliers.
*/

if (!isServer) exitWith {};

diag_log "[Iron Mantle] Economy Manager Started.";

while {true} do {
    // 1. Wait for the interval defined in GVAR_Economy_Settings.sqf
    // Interval is in minutes, so we multiply by 60 for sleep.
    sleep (GVAR_Economy_IncomeInterval * 60);

    // 2. Calculate current income
    private _totalSupplies = GVAR_Economy_PassiveIncome_Supplies;
    private _totalIntel = GVAR_Economy_PassiveIncome_Intel;

    // 3. Add bonuses for controlled zones
    // (Tomorrow we will implement the logic to count GVAR_ControlledZones)
    {
        private _zoneType = _x getVariable ["GVAR_ZoneType", "Small"];
        switch (_zoneType) do {
            case "Small": { _totalSupplies = _totalSupplies + GVAR_Economy_ZoneBonus_Small; };
            case "Large": { _totalSupplies = _totalSupplies + GVAR_Economy_ZoneBonus_Large; };
            case "Base":  { _totalSupplies = _totalSupplies + GVAR_Economy_ZoneBonus_Base; };
        };
    } forEach (missionNamespace getVariable ["GVAR_ControlledZones_BLUFOR", []]);

    // 4. Update global resource variables
    GVAR_CurrentSupplies = GVAR_CurrentSupplies + _totalSupplies;
    GVAR_CurrentIntel = GVAR_CurrentIntel + _totalIntel;

    // 5. Broadcast to all players so their UI updates
    publicVariable "GVAR_CurrentSupplies";
    publicVariable "GVAR_CurrentIntel";

    // 6. Notification to players
    ["EconomyUpdate", [_totalSupplies, _totalIntel]] remoteExec ["BIS_fnc_showNotification", 0];

    diag_log format ["[Iron Mantle] Income Distributed: %1 Supplies, %2 Intel.", _totalSupplies, _totalIntel];
};
