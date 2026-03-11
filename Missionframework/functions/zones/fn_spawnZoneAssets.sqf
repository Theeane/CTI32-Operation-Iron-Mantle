/* Author: Theeane
    Description: 
    Spawns infantry, civilians, and informants in a zone.
    Uses presets from yesterday and interaction-logic from today.
*/

params ["_zonePos", "_tier"];

// 1. Hämta inställningar för denna Tier (mängd gubbar etc)
private _tierData = GVAR_Zone_Tier_Settings get _tier;
private _multiplier = _tierData select 2;

// 2. SPAWNA INFANTERI (Fiender)
private _groupCount = round (3 * _multiplier); // Fler grupper vid högre Tier
for "_i" from 1 to _groupCount do {
    private _spawnPos = [_zonePos, 10, 100, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    private _group = [_spawnPos, east, (configfile >> "CfgGroups" >> "Indep" >> "IND_F" >> "Infantry" >> "HAF_InfSquad")] call BIS_fnc_spawnGroup;
    
    // Ge varje soldat i gruppen våra nya interaktioner (Search Body, Undercover etc)
    {
        [_x] call CTI_fnc_initInteractions;
    } forEach units _group;
    
    // Sätt dem på patrull i zonen
    [_group, _zonePos, 150] call bis_fnc_taskPatrol;
};

// 3. SPAWNA CIVILA & INFORMATÖRER
private _civCount = round (5 * _multiplier);
for "_i" from 1 to _civCount do {
    private _civClass = selectRandom GVAR_Civ_List; // Hämtas från gårdagens Preset
    private _spawnPos = [_zonePos, 10, 150, 3, 0, 20, 0] call BIS_fnc_findSafePos;
    
    private _group = createGroup civilian;
    private _civ = _group createUnit [_civClass, _spawnPos, [], 0, "NONE"];
    
    // Bestäm om denna civila är en INFORMATÖR (t.ex. 20% chans)
    if (random 100 < 20) then {
        _civ setVariable ["GVAR_isInformant", true, true];
    };

    // Applicera våra nya interaktioner (Vinka, Prata, Trade)
    [_civ] call CTI_fnc_initInteractions;
    
    [_group, _zonePos, 100] call bis_fnc_taskPatrol;
};
