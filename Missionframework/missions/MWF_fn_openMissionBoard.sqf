/*
    Author: Theane / ChatGPT
    Function: fn_openMissionBoard
    Project: Military War Framework

    Description:
    Opens a lightweight mission board readout for the current rotating side missions.
*/

private _boardSlots = + (missionNamespace getVariable ["MWF_MissionBoardSlots", []]);
private _expiresAt = missionNamespace getVariable ["MWF_MissionBoardExpiresAt", serverTime];
private _secondsLeft = ((_expiresAt - serverTime) max 0) min 300;
private _minimalMode = missionNamespace getVariable ["MWF_MissionBoardMinimalMode", false];

if (_boardSlots isEqualTo []) exitWith {
    hint "Mission board is not ready yet.";
};

private _lines = [
    "<t size='1.2' color='#FFD966'>MWF Mission Board</t>",
    format ["<t size='0.9'>Refresh in %1 seconds</t>", round _secondsLeft]
];

if (_minimalMode) then {
    _lines pushBack "<t size='0.9' color='#FFCC66'>Minimal mode active: one Supply / Intel / Disrupt mission generated for this map.</t>";
};

_lines pushBack " ";

{
    _x params ["_slotIndex", "_category", "_difficulty", "_missionId", "_missionKey", "_missionPath", "_position", "_areaId", "_areaName", "_state", ["_domain", "land", [""]]];

    private _categoryLabel = switch (_category) do {
        case "disrupt": {"DISRUPT"};
        case "supply": {"SUPPLY"};
        case "intel": {"INTEL"};
        default {toUpper _category};
    };

    private _stateLabel = switch (_state) do {
        case "active": {"<t color='#FFAA00'>ACTIVE</t>"};
        case "available": {"<t color='#7CFC00'>AVAILABLE</t>"};
        default {format ["<t color='#CCCCCC'>%1</t>", toUpper _state]};
    };

    _lines pushBack format ["<t color='#00BFFF'>Slot %1</t> - %2 | %3 | %4 | Template %5", _slotIndex + 1, toUpper _domain, _categoryLabel, toUpper _difficulty, _missionId];
    _lines pushBack format ["<t size='0.9'>Area: %1 | State: %2</t>", _areaName, _stateLabel];
    _lines pushBack " ";
} forEach _boardSlots;

hintSilent parseText (_lines joinString "<br/>");
