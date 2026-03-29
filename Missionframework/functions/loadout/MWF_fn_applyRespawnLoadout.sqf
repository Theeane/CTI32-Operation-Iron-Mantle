/*
    Author: Theeane / Gemini
    Function: MWF_fnc_applyRespawnLoadout
    Project: Military War Framework

    Description:
    Applies the locally-saved respawn loadout package after a player respawns.
    Ensures the player's face, voice, and insignia are restored along with 
    their gear.
*/

if (!hasInterface) exitWith { false };

// 1. Retrieve the saved profile from memory or persistent storage
// Checks missionNamespace first for speed, then falls back to profileNamespace
private _savedProfile = missionNamespace getVariable ["MWF_SavedRespawnProfile", profileNamespace getVariable ["MWF_SavedRespawnProfile", []]];

// 2. Validate the profile data (expects [Loadout, Face, Speaker, Insignia])
if !(_savedProfile isEqualType [] && {count _savedProfile >= 4}) exitWith {
    diag_log "[MWF] Respawn Loadout: No valid profile found. Using mission default gear.";
    false 
};

_savedProfile params ["_loadout", "_face", "_speaker", "_insignia"];

// 3. Apply the loadout with a safety delay
// A short sleep is required to ensure the engine has fully initialized the new unit post-respawn.
[_loadout, _face, _speaker, _insignia] spawn {
    params ["_loadout", "_face", "_speaker", "_insignia"];

    // Small delay to allow the engine to finalize the respawn process
    uiSleep 0.5;

    if (!alive player) exitWith {
        diag_log "[MWF] Respawn Loadout: Player is not alive. Aborting application.";
    };

    // Apply the full gear package
    player setUnitLoadout _loadout;
    
    // Apply identity settings
    if (_face != "") then { player setFace _face; };
    if (_speaker != "") then { player setSpeaker _speaker; };
    
    // Apply unit insignia (patch)
    if (_insignia != "") then {
        [player, _insignia] call BIS_fnc_setUnitInsignia;
    };

    diag_log format ["[MWF] Respawn Loadout: Successfully applied profile to %1.", name player];
};

true