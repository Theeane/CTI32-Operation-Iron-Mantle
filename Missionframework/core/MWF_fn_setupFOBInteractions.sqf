/*
    Author: Theane / ChatGPT
    Function: MWF_fn_setupFOBInteractions
    Project: Military War Framework

    Description:
    Adds the FOB terminal interaction set and prevents duplicate actions from being added.
*/

params [["_terminal", objNull, [objNull]]];

if (isNull _terminal) exitWith {};
if !((_terminal getVariable ["MWF_FOB_InteractionActionIds", []]) isEqualTo []) exitWith {};

private _actionIds = [];

_actionIds pushBack (
    _terminal addAction [
        "<t color='#00bbff' size='1.2'>[ FOB ] Open Base Architect (Structures)</t>",
        {
            [_target] spawn MWF_fnc_openBaseArchitect;
        },
        [],
        10,
        true,
        true,
        "",
        "_this distance _target < 3"
    ]
);

_actionIds pushBack (
    _terminal addAction [
        "<t color='#00ff00' size='1.2'>[ FOB ] Open Logistics Menu</t>",
        {
            [_target] spawn MWF_fnc_openBuildMenu;
        },
        [],
        9,
        true,
        true,
        "",
        "_this distance _target < 3"
    ]
);

_actionIds pushBack (
    _terminal addAction [
        "<t color='#ffffff'>Check Resource Levels</t>",
        {
            private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
            private _intel = missionNamespace getVariable ["MWF_res_intel", 0];
            hint format ["Current FOB Logistics:
Supplies: %1
Intel: %2", _supplies, _intel];
        },
        [],
        1,
        false,
        true,
        "",
        "_this distance _target < 3"
    ]
);

_terminal setVariable ["MWF_FOB_InteractionActionIds", _actionIds, true];

diag_log format ["[MWF FOB] Interaction actions added to terminal %1. Total actions: %2.", _terminal, count _actionIds];
