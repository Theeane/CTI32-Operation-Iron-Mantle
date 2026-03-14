/*
    Author: Theane / ChatGPT
    Function: fn_economyManager
    Project: Military War Framework

    Description:
    Handles economy manager for the economy system.
*/

if (!isServer) exitWith {};

diag_log "[Iron Mantle] Economy Manager Started.";

while {true} do {
    // 1. Wait for the interval defined in MWF_Economy_Settings.sqf
    // Interval is in minutes, so we multiply by 60 for sleep.
    sleep (MWF_Economy_IncomeInterval * 60);

    // 2. Calculate current income
    private _totalSupplies = MWF_Economy_PassiveIncome_Supplies;
    private _totalIntel = MWF_Economy_PassiveIncome_Intel;

    // 3. Add bonuses for controlled zones
    // (Tomorrow we will implement the logic to count MWF_ControlledZones)
    {
        private _zoneType = _x getVariable ["MWF_ZoneType", "Small"];
        switch (_zoneType) do {
            case "Small": { _totalSupplies = _totalSupplies + MWF_Economy_ZoneBonus_Small; };
            case "Large": { _totalSupplies = _totalSupplies + MWF_Economy_ZoneBonus_Large; };
            case "Base":  { _totalSupplies = _totalSupplies + MWF_Economy_ZoneBonus_Base; };
        };
    } forEach (missionNamespace getVariable ["MWF_ControlledZones_BLUFOR", []]);

    // 4. Update global resource variables
    MWF_CurrentSupplies = MWF_CurrentSupplies + _totalSupplies;
    MWF_CurrentIntel = MWF_CurrentIntel + _totalIntel;

    // 5. Broadcast to all players so their UI updates
    publicVariable "MWF_CurrentSupplies";
    publicVariable "MWF_CurrentIntel";

    // 6. Notification to players
    ["EconomyUpdate", [_totalSupplies, _totalIntel]] remoteExec ["BIS_fnc_showNotification", 0];

    diag_log format ["[Iron Mantle] Income Distributed: %1 Supplies, %2 Intel.", _totalSupplies, _totalIntel];
};
