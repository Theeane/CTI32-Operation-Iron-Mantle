/*
    Author: Gemini + OpenAI / ChatGPT
    Purpose: Server-authoritative terminal upload bridge.

    Notes:
    - Supports legacy carried supplies / intel variables so old data is not lost.
    - Uses the modern temporary-intel deposit pipeline when present.
*/
params [
    ["_unit", objNull, [objNull]],
    ["_serverCommit", false, [true]]
];

if (_serverCommit) exitWith {
    if (!isServer || {isNull _unit}) exitWith {};

    private _legacySupplies = (_unit getVariable ["MWF_CarriedSupplies", 0]) max 0;
    private _legacyIntel = (_unit getVariable ["MWF_CarriedIntel", 0]) max 0;
    private _tempIntel = (_unit getVariable ["MWF_carriedIntelValue", 0]) max 0;

    if (_legacySupplies <= 0 && _legacyIntel <= 0 && _tempIntel <= 0) exitWith {
        [["UPLOAD FAILED", "No digital assets detected on device."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    private _uploadedTempIntel = false;
    if (_tempIntel > 0 && {!isNil "MWF_fnc_depositIntel"}) then {
        private _mobNode = missionNamespace getVariable ["MWF_MainBase", missionNamespace getVariable ["MWF_MOB", objNull]];
        [_mobNode, _unit] call MWF_fnc_depositIntel;
        _uploadedTempIntel = true;
    };

    if (_legacySupplies > 0 && {!isNil "MWF_fnc_addResource"}) then {
        [_legacySupplies, "SUPPLIES"] call MWF_fnc_addResource;
    };
    if (_legacyIntel > 0 && {!isNil "MWF_fnc_addResource"}) then {
        [_legacyIntel, "INTEL"] call MWF_fnc_addResource;
    };

    _unit setVariable ["MWF_CarriedSupplies", 0, true];
    _unit setVariable ["MWF_CarriedIntel", 0, true];

    if ((_legacySupplies > 0 || _legacyIntel > 0) && {!_uploadedTempIntel}) then {
        [["DATA UPLOADED", format ["Transferred: %1 Supplies, %2 Intel.", _legacySupplies, _legacyIntel]], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    if ((_legacySupplies > 0 || _legacyIntel > 0) && {_uploadedTempIntel}) then {
        [["LEGACY DATA UPLOADED", format ["Transferred legacy cache: %1 Supplies, %2 Intel.", _legacySupplies, _legacyIntel]], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
};

if (!hasInterface || {_unit != player} || {!alive _unit}) exitWith {};

[_unit, true] remoteExecCall ["MWF_fnc_terminal_upload", 2];
