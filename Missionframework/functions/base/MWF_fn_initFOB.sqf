/*
    Author: OpenAI / repaired from patch
    Function: MWF_fnc_initFOB
    Project: Military War Framework

    Description:
    Adds a visible deploy action to a FOB truck/container and validates deployment
    at runtime instead of hiding the action near MOB/FOB areas.
*/

params [["_asset", objNull, [objNull]]];

if (!hasInterface) exitWith {};
if (isNull _asset) exitWith {
    diag_log "[MWF FOB] initFOB called with null object on client.";
};

if (_asset getVariable ["MWF_FOB_ClientInitComplete", false]) exitWith {};

private _originType = if (typeOf _asset == (missionNamespace getVariable ["MWF_FOB_Truck", ""])) then { "TRUCK" } else { "BOX" };
_asset setVariable ["MWF_FOB_Type", _originType, true];

private _actionId = _asset addAction [
    "<t color='#00FF00'>Deploy FOB</t>",
    {
        params ["_target", "_caller"];

        if (isNull _target) exitWith {};
        if (!alive _caller) exitWith {};
        if (_target getVariable ["MWF_FOB_PlacementInProgress", false]) exitWith {
            hint "FOB deployment already in progress.";
        };
        if ((_caller distance _target) > 10) exitWith {
            hint "Move closer to the FOB asset to deploy it.";
        };
        if ((speed _target) > 1) exitWith {
            hint "Stop the FOB asset before deploying it.";
        };
        if !(isNull objectParent _caller) exitWith {
            hint "Get out of the vehicle before deploying the FOB.";
        };

        private _canDeployHere = ["CAN_DEPLOY", [getPosATL _target]] call MWF_fnc_baseManager;
        if (!_canDeployHere) exitWith {
            hint "Drive the FOB asset away from the MOB/FOB before deploying.";
        };

        _target setVariable ["MWF_FOB_PlacementInProgress", true, true];
        [_target, getPosASL _target, getDir _target] remoteExec ["MWF_fnc_deployFOB", 2];
        hint "FOB deployment requested.";
    },
    nil,
    10,
    false,
    true,
    "",
    "alive _target"
];

_asset setVariable ["MWF_FOB_DeployAction", _actionId];
_asset setVariable ["MWF_FOB_ClientInitComplete", true];

diag_log format ["[MWF FOB] Client init complete for %1 as deployable %2.", _asset, _originType];
