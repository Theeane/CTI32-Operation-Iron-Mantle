/*
    Author: Theeane / Gemini
    Function: MWF_fnc_saveRespawnLoadout
    Project: Military War Framework

    Description:
    Saves the player's current gear as their respawn loadout.
    Stops the save if the player is wearing a blacklisted OPFOR uniform to 
    prevent respawning in a "fake" undercover state with weapons.
    Vests, headgear, and civilian uniforms are permitted.
*/

if (!hasInterface) exitWith { false };

// 1. Safety check: Must be in a registered zone (MOB or FOB)
if !(missionNamespace getVariable ["MWF_InLoadoutZone", false]) exitWith {
    ["<t color='#ff4444'>You must be at MOB or a FOB to save your loadout.</t>", 0, 1.2, 5, 0.1] spawn BIS_fnc_dynamicText;
    false
};

// 2. Refresh caches to ensure we have the latest restricted uniform list
[] call MWF_fnc_buildLoadoutCaches;
private _opforUniforms = missionNamespace getVariable ["MWF_OpforUniformClasses", []];

// 3. Validation: Check the uniform only
private _currentUniform = uniform player;

if (_currentUniform in _opforUniforms) exitWith {
    private _displayName = getText (configFile >> "CfgWeapons" >> _currentUniform >> "displayName");
    
    // Display clear reasoning for the block
    hint parseText format [
        "<t color='#ff4444' size='1.2' weight='bold'>SAVE BLOCKED</t><br/><br/>" +
        "You cannot save a respawn loadout while wearing enemy clothing:<br/>" +
        "<t color='#ffffff'>%1</t><br/><br/>" +
        "Please change into a civilian or friendly uniform first.",
        _displayName
    ];
    false
};

// 4. Build the Loadout Payload
// Includes: Full gear, face, speaker, and insignia
private _insignia = [player] call BIS_fnc_getUnitInsignia;
private _payload = [
    getUnitLoadout player,
    face player,
    speaker player,
    _insignia
];

// Save to profileNamespace (persists across game restarts)
profileNamespace setVariable ["MWF_SavedRespawnProfile", _payload];
saveProfileNamespace;

// Update missionNamespace for immediate use in current session
missionNamespace setVariable ["MWF_SavedRespawnProfile", _payload];

// 5. Success Feedback
["<t color='#44ff44'>Respawn loadout saved.</t>", 0, 1.2, 5, 0.1] spawn BIS_fnc_dynamicText;
playSound "HintExpand";

diag_log format ["[MWF] Loadout Saved: %1 has updated their respawn profile.", name player];
true