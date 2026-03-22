/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_terminal_upload
    Project: Military War Framework

    Description:
    Server-authoritative terminal upload bridge.
    Supports the current temporary-intel deposit pipeline and safely drains any
    remaining legacy carried digital resources if present.
*/
params [
    ["_unit", objNull, [objNull]],
    ["_serverCommit", false, [true]],
    ["_terminal", objNull, [objNull]]
];

if (_serverCommit) exitWith {
    if (!isServer || {isNull _unit}) exitWith {};

    private _tempIntel = _unit getVariable ["MWF_carriedIntelValue", 0];
    private _legacySupplies = (_unit getVariable ["MWF_CarriedSupplies", 0]) max 0;
    private _legacyIntel = (_unit getVariable ["MWF_CarriedIntel", 0]) max 0;

    if (_tempIntel <= 0 && {_legacySupplies <= 0} && {_legacyIntel <= 0}) exitWith {
        [["UPLOAD FAILED", "No temporary intel or legacy digital assets detected."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    if (_tempIntel > 0) then {
        [_terminal, _unit] call MWF_fnc_depositIntel;
    };

    if (_legacySupplies > 0 || {_legacyIntel > 0}) then {
        private _curSupplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
        private _curIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
        private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
        [_curSupplies + _legacySupplies, _curIntel + _legacyIntel, _notoriety] call MWF_fnc_syncEconomyState;

        _unit setVariable ["MWF_CarriedSupplies", 0, true];
        _unit setVariable ["MWF_CarriedIntel", 0, true];

        [["LEGACY DATA UPLOADED", format ["Transferred legacy cache: %1 Supplies, %2 Intel.", _legacySupplies, _legacyIntel]], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];

        if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
    };
};

if (!hasInterface || {_unit != player} || {!alive _unit}) exitWith {};

[_unit, true, _terminal] remoteExecCall ["MWF_fnc_terminal_upload", 2];
