/* Author: Theane
    Project: Operation Iron Mantle
    Description: Deploys a vehicle/container into a static FOB. Integrated with Base Manager.
    Language: English
*/

params ["_truck"];

[
    _truck,
    "Deploy FOB",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    // Condition: Distance, Speed AND Check with Base Manager for Max FOB limit
    "_this distance _target < 10 && speed _target < 1 && (['CAN_DEPLOY'] call KPIN_fnc_baseManager)",
    "_caller distance _target < 10",
    {}, {},
    {
        params ["_target", "_caller"];
        private _pos = getPosATL _target;
        private _dir = getDir _target;

        // 1. Create the new FOB object
        deleteVehicle _target;
        private _fobObject = createVehicle [KPIN_FOB_Box_Deployed, _pos, [], 0, "CAN_COLLIDE"];
        _fobObject setDir _dir;
        _fobObject setPosATL _pos;

        // 2. Create the Marker
        private _fobMarker = createMarker [format["fob_%1", round(random 10000)], _pos];
        _fobMarker setMarkerType "b_hq";
        _fobMarker setMarkerText "FOB";

        // 3. Set variables
        _fobObject setVariable ["KPIN_isFOB", true, true];
        _fobObject setVariable ["KPIN_FOB_Marker", _fobMarker, true];
        
        // 4. REGISTER with Base Manager (This handles ActiveZones and Registry)
        ["ADD", [_fobMarker, _fobObject]] call KPIN_fnc_baseManager;

        // 5. Initialize the pack-up option on the new object
        [_fobObject] call KPIN_fnc_packFOB; 
        
        ["TaskSucceeded", ["", "FOB Deployed and Registered."]] remoteExec ["BIS_fnc_showNotification", _caller];
    },
    {
        // If they fail or cancel, and the limit was reached mid-action
        if !(['CAN_DEPLOY'] call KPIN_fnc_baseManager) then {
            hint "Deployment cancelled: FOB Limit reached.";
        };
    }, [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
