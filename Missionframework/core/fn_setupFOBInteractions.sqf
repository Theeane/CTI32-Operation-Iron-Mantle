/*
    Author: Theane / ChatGPT
    Function: fn_setupFOBInteractions
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
        "<t color='#00bbff' size='1.2'>[ FOB ] Open Base Architect</t>",
        {
            [] spawn MWF_fnc_openBaseArchitect;
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
            [] spawn MWF_fnc_openBuildMenu;
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
            private _supplies = missionNamespace getVariable ["MWF_res_supplies", 0];
            hint format ["Current FOB Logistics:\nSupplies: %1", _supplies];
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
