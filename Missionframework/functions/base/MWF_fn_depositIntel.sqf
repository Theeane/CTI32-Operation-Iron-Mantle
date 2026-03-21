/*
    Author: Theane / ChatGPT
    Function: MWF_fnc_depositIntel
    Project: Military War Framework

    Description:
    Deposits a player's carried intel into the authoritative shared Intel pool.
    Intel turn-in is the only place where infrastructure reveals and jackpot main-op
    charges can roll.

    Rules:
    - exactly one reveal roll per true turn-in action (10%)
    - exactly one jackpot roll per true turn-in action (0.5%)
    - amount carried does not change the number of rolls
*/

params [["_laptop", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (!isServer) exitWith { [_laptop, _caller] remoteExecCall ["MWF_fnc_depositIntel", 2]; };
if (isNull _caller) exitWith {};

private _tempIntel = _caller getVariable ["MWF_carriedIntelValue", 0];

if (_tempIntel <= 0) exitWith {
    [["INTEL UPLOAD", "No temporary intel is currently being carried."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
};

private _nodeLabel = "Command Network";
if (!isNull _laptop) then {
    if (_laptop getVariable ["MWF_isFOB", false]) then {
        _nodeLabel = _laptop getVariable ["MWF_FOB_DisplayName", "FOB"];
    } else {
        _nodeLabel = missionNamespace getVariable ["MWF_MOB_Name", "Main Operating Base"];
    };
};

private _currentIntel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _newIntel = _currentIntel + _tempIntel;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _notoriety = missionNamespace getVariable ["MWF_res_notoriety", 0];
[_supplies, _newIntel, _notoriety] call MWF_fnc_syncEconomyState;

_caller setVariable ["MWF_carriedIntelValue", 0, true];
_caller setVariable ["MWF_carryingIntel", false, true];

private _revealedTargetText = "";
private _jackpotText = "";

private _pickRevealTarget = {
    private _registry = +(missionNamespace getVariable ["MWF_InfrastructureRegistry", []]);
    private _revealedIds = +(missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
    private _candidates = [];

    {
        if (_x isEqualType [] && {count _x >= 4}) then {
            _x params [
                ["_infraId", "", [""]],
                ["_infraType", "ROADBLOCK", [""]],
                ["_object", objNull, [objNull]],
                ["_storedPos", [0,0,0], [[]]]
            ];

            if (
                _infraId isNotEqualTo "" &&
                {!(_infraId in _revealedIds)} &&
                ((toUpper _infraType) in ["HQ", "ROADBLOCK"]) &&
                ((isNull _object) || {alive _object})
            ) then {
                _candidates pushBack [_infraId, _infraType, _object, _storedPos];
            };
        };
    } forEach _registry;

    if (_candidates isEqualTo []) exitWith { [] };
    selectRandom _candidates
};

if ((random 1) <= 0.10) then {
    private _picked = call _pickRevealTarget;
    if !(_picked isEqualTo []) then {
        _picked params ["_infraId", "_infraType", "_object", "_storedPos"];
        private _revealedIds = +(missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
        _revealedIds pushBackUnique _infraId;
        missionNamespace setVariable ["MWF_RevealedInfrastructureIDs", _revealedIds, true];
        _revealedTargetText = if ((toUpper _infraType) isEqualTo "HQ") then {" Enemy HQ location identified."} else {" Roadblock location identified."};
        [["INTEL BREAKTHROUGH", if ((toUpper _infraType) isEqualTo "HQ") then {"Enemy HQ location revealed on the map."} else {"Roadblock location revealed on the map."}], "info"] remoteExec ["MWF_fnc_showNotification", 0];
    };
};

if ((random 1) <= 0.005) then {
    private _charges = missionNamespace getVariable ["MWF_FreeMainOpCharges", 0];
    missionNamespace setVariable ["MWF_FreeMainOpCharges", _charges + 1, true];
    _jackpotText = " Intel breakthrough secured a free next main operation charge.";
    [["INTEL JACKPOT", "Commander's next main operation is now free."], "success"] remoteExec ["MWF_fnc_showNotification", 0];
};

[
    [
        "INTEL BANKED",
        format ["Uploaded %1 Intel at %2. Banked total: %3.%4%5", _tempIntel, _nodeLabel, _newIntel, _revealedTargetText, _jackpotText]
    ],
    "success"
] remoteExecCall ["MWF_fnc_showNotification", owner _caller];

if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };

diag_log format ["[MWF] Economy: %1 deposited %2 Intel at %3. New Intel total: %4. Reveal: %5 | Jackpot: %6", name _caller, _tempIntel, _nodeLabel, _newIntel, _revealedTargetText, _jackpotText];
