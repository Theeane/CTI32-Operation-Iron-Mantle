/*
    Author: Theane / ChatGPT / Gemini
    Function: MWF_fnc_checkUndercover.sqf
    Project: Military War Framework
    Description: Checks if a unit is using a blacklisted uniform.
*/

params [
    ["_unit", objNull, [objNull]]
];

private _isBlacklisted = false;
private _currentUniform = uniform _unit;

// 1. Ensure the blacklist exists before checking
if (!isNil "MWF_Undercover_Blacklist") then {
    if (_currentUniform in MWF_Undercover_Blacklist) then {
        _isBlacklisted = true;
    };
};

// 2. Logging
if (_isBlacklisted) then {
    diag_log format ["[MWF] Undercover Check: Unit %1 is wearing blacklisted uniform: %2", _unit, _currentUniform];
};

// 3. Return status
_isBlacklisted
