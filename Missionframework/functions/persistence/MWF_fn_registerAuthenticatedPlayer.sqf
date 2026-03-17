/*
    Author: Theane / ChatGPT
    Function: fn_registerAuthenticatedPlayer
    Project: Military War Framework

    Description:
    Registers a player UID as permanently tutorial-cleared for the current campaign.
    The authenticated list is kept in missionNamespace and profileNamespace so a
    loaded campaign can immediately grant terminal access without replaying the
    onboarding gates.
*/

if (!isServer) exitWith { false };

params [
    ["_input", objNull, [objNull, ""]]
];

private _uid = "";
private _name = "Unknown";

if (_input isEqualType objNull) then {
    if (isNull _input) exitWith { false };
    _uid = getPlayerUID _input;
    _name = name _input;
} else {
    _uid = _input;
};

if (_uid isEqualTo "") exitWith { false };

private _authPlayers = + (missionNamespace getVariable ["MWF_AuthenticatedPlayers", []]);
if !(_uid in _authPlayers) then {
    _authPlayers pushBack _uid;
    missionNamespace setVariable ["MWF_AuthenticatedPlayers", _authPlayers, true];
    profileNamespace setVariable ["MWF_Save_AuthenticatedPlayers", _authPlayers];
    saveProfileNamespace;
    diag_log format ["[MWF Auth] Registered authenticated player UID %1 (%2).", _uid, _name];
};

true
