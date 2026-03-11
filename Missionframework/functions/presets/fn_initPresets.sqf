/*
    Author: Theeane
    Description: 
    Initializes the selected presets for BLUFOR, OPFOR, Resistance, and Civilians 
    based on mission parameters.
*/

// 1. Hämta valen från mission-parametrarna (Lobbyn)
private _bluforFaction = ["GVAR_Param_Blufor", 0] call BIS_fnc_getParamValue;
private _opforFaction  = ["GVAR_Param_Opfor", 0] call BIS_fnc_getParamValue;
private _resFaction    = ["GVAR_Param_Resistance", 0] call BIS_fnc_getParamValue;
private _civFaction    = ["GVAR_Param_Civilians", 0] call BIS_fnc_getParamValue;

// 2. Ladda BLUFOR
switch (_bluforFaction) do {
    case 0: { [] execVM "Missionframework\presets\blufor\RHS_USAF_Army_Woodland.sqf" };
    case 1: { [] execVM "Missionframework\presets\blufor\CUP_BAF_Desert.sqf" };
    // Lägg till fler cases baserat på din description.ext
};

// 3. Ladda OPFOR (Vår nya HashMap-struktur)
switch (_opforFaction) do {
    case 0: { [] execVM "Missionframework\presets\opfor\CUP_AFRF_Modern.sqf" };
    case 1: { [] execVM "Missionframework\presets\opfor\Contact.sqf" };
    case 2: { [] execVM "Missionframework\presets\opfor\Islamic_State.sqf" };
    // Osv...
};

// 4. Ladda RESISTANCE (Vår nya HashMap-struktur)
switch (_resFaction) do {
    case 0: { [] execVM "Missionframework\presets\resistance\AAF.sqf" };
    case 1: { [] execVM "Missionframework\presets\resistance\RACS.sqf" };
    case 2: { [] execVM "Missionframework\presets\resistance\Vietnam_CIDG.sqf" };
};

// 5. Ladda CIVILIANS
switch (_civFaction) do {
    case 0: { [] execVM "Missionframework\presets\civilians\European.sqf" };
    case 1: { [] execVM "Missionframework\presets\civilians\Middle_Eastern.sqf" };
    case 2: { [] execVM "Missionframework\presets\civilians\Vietnam.sqf" };
};

// Logga i RPT-filen att alla presets är laddade
diag_log "[Iron Mantle] All presets have been successfully initialized.";
