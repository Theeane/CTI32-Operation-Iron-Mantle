/*
    Author: OpenAI
    Function: MWF_fnc_saveRespawnLoadout
    Project: Military War Framework

    Description:
    Saves the player's respawn loadout, face, voice and insignia. Saving is
    blocked if an OPFOR uniform is currently worn.
*/

if (!hasInterface) exitWith { false };

[] call MWF_fnc_buildLoadoutCaches;
private _opforUniforms = missionNamespace getVariable ["MWF_OpforUniformClasses", []];

if ((uniform player) in _opforUniforms) exitWith {
    hint "Du kan inte spara respawn-loadout med OPFOR-uniform utrustad.";
    false
};

private _insignia = [player] call BIS_fnc_getUnitInsignia;
private _payload = [
    getUnitLoadout player,
    face player,
    speaker player,
    _insignia
];

profileNamespace setVariable ["MWF_SavedRespawnProfile", _payload];
saveProfileNamespace;
missionNamespace setVariable ["MWF_SavedRespawnProfile", _payload];
missionNamespace setVariable ["MWF_SaveLoadout_Enabled", true, true];

hint "Respawn-loadout sparad.";
true
