/*
    Author: Theane / ChatGPT
    Function: fn_initFOB
    Project: Military War Framework

    Description:
    Adds the deploy hold action to a FOB truck/container and routes deployment to the
    server-side FOB deployment pipeline.
*/

params [["_truck", objNull, [objNull]]];

if (isNull _truck) exitWith { diag_log "[MWF FOB] initFOB called with null object."; };
if (_truck getVariable ["MWF_FOB_InitComplete", false]) exitWith {};

private _originType = if (typeOf _truck == (missionNamespace getVariable ["MWF_FOB_Truck", ""])) then { "TRUCK" } else { "BOX" };
_truck setVariable ["MWF_FOB_Type", _originType, true];

[
    _truck,
    "<t color='#00FF00'>Deploy FOB</t>",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "_this distance _target < 10 && speed _target < 1 && !(_target getVariable ['MWF_FOB_PlacementInProgress', false])",
    "_caller distance _target < 10",
    {},
    {},
    {
        params ["_target", "_caller"];
        _target setVariable ["MWF_FOB_PlacementInProgress", true, true];
        [_target] remoteExec ["MWF_fnc_startFOBPlacement", _caller];
    },
    {
        params ["_target"];
        _target setVariable ["MWF_FOB_PlacementInProgress", false, true];
        hint "Deployment aborted.";
    },
    [],
    10,
    0,
    true,
    false
] call BIS_fnc_holdActionAdd;

_truck setVariable ["MWF_FOB_InitComplete", true, true];
