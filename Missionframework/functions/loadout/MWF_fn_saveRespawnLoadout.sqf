/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_saveRespawnLoadout
    Project: Military War Framework

    Description:
    Saves the player's respawn loadout, face, voice and insignia. Saving is
    blocked if any OPFOR-classified clothing item is currently worn.
*/

if (!hasInterface) exitWith { false };
if !(missionNamespace getVariable ["MWF_InLoadoutZone", false]) exitWith {
    hint "Du måste vara i en loadout-zon nära MOB eller FOB för att spara respawn-loadout.";
    false
};

[] call MWF_fnc_buildLoadoutCaches;
private _opforClothing = missionNamespace getVariable ["MWF_OpforClothingClasses", missionNamespace getVariable ["MWF_OpforUniformClasses", []]];

private _blockedItems = [];
{
    if !(_x isEqualTo "") then {
        if (_x in _opforClothing) then {
            _blockedItems pushBackUnique _x;
        };
    };
} forEach [
    uniform player,
    vest player,
    headgear player
];

if (_blockedItems isNotEqualTo []) exitWith {
    hint format ["Du kan inte spara respawn-loadout med OPFOR-kläder utrustade (%1).", _blockedItems joinString ", "];
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
