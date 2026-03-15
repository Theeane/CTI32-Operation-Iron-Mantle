/*
    Author: Gemini (Production Pass 3.0)
    Purpose: Server-Authoritative transfer. No client-side value trust.
*/
params [
    ["_unit", objNull, [objNull]],
    ["_serverCommit", false, [true]]
];

if (_serverCommit) exitWith {
    if (!isServer || isNull _unit) exitWith {};

    private _s = (_unit getVariable ["MWF_CarriedSupplies", 0]) max 0;
    private _i = (_unit getVariable ["MWF_CarriedIntel", 0]) max 0;

    if (_s <= 0 && _i <= 0) exitWith {
        [["UPLOAD FAILED", "No digital assets detected on device."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    if (_s > 0) then { [_s, "SUPPLIES"] call MWF_fnc_addResource; };
    if (_i > 0) then { [_i, "INTEL"] call MWF_fnc_addResource; };

    _unit setVariable ["MWF_CarriedSupplies", 0, true];
    _unit setVariable ["MWF_CarriedIntel", 0, true];

    [["DATA UPLOADED", format ["Transferred: %1 Supplies, %2 Intel.", _s, _i]], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
};

if (!hasInterface || _unit != player || !alive _unit) exitWith {};

[_unit, true] remoteExecCall ["MWF_fnc_terminal_upload", 2];