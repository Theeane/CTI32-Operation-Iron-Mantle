/*
    Author: Theane / ChatGPT
    Function: fn_setupFOBAction
    Project: Military War Framework

    Description:
    Handles setup f o b action for the core framework layer.
*/

params ["_container"];

[
    _container,
    "Initiate FOB Deployment",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_request_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_request_ca.paa",
    "_this distance _target < 5",
    "_caller distance _target < 5",
    { systemChat "Calibrating deployment site..."; },
    {},
    {
        params ["_target", "_caller"];
        private _pos = getPosATL _target;
        deleteVehicle _target;

        // Create a temporary Zeus logic for the player
        private _group = createGroup sideLogic;
        private _curator = _group createUnit ["ModuleCurator_F", [0,0,0], [], 0, "NONE"];
        
        _caller assignCurator _curator;
        
        // Give the curator the ability to place the composition
        // (This part requires a helper script to 'attach' the composition to the cursor)
        [_curator, _pos] remoteExec ["MWF_fnc_startFOBPlacement", _caller];

        systemChat "Deployment Interface Active. Place the FOB Composition.";
    },
    { systemChat "Deployment cancelled."; },
    [],
    10,
    10,
    true,
    false
] call BIS_fnc_holdActionAdd;
