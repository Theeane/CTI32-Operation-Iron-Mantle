/*
    Author: OpenAI
    Function: MWF_fnc_applyRespawnLoadout
    Project: Military War Framework

    Description:
    Applies the locally-saved respawn loadout package after player respawn.
*/

if (!hasInterface) exitWith { false };

private _payload = missionNamespace getVariable ["MWF_SavedRespawnProfile", profileNamespace getVariable ["MWF_SavedRespawnProfile", []]];
if !(_payload isEqualType [] && {count _payload >= 4}) exitWith { false };

_payload params ["_savedLoadout", "_savedFace", "_savedSpeaker", "_savedInsignia"];

[_savedLoadout, _savedFace, _savedSpeaker, _savedInsignia] spawn {
    params ["_loadout", "_face", "_speaker", "_insignia"];

    uiSleep 1;
    if (!alive player) exitWith {};

    player setUnitLoadout _loadout;
    player setFace _face;
    player setSpeaker _speaker;
    [player, _insignia] call BIS_fnc_setUnitInsignia;
};

true
