/* Author: Theane
    Project: Operation Iron Mantle
    Description: Deploys a vehicle/container into a static FOB.
    Language: English
*/

params ["_truck"];

[
    _truck,
    "Deploy FOB",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "_this distance _target < 10 && speed _target < 1",
    "_caller distance _target < 10",
    {}, {},
    {
        params ["_target", "_caller"];
        private _pos = getPosATL _target;
        private _dir = getDir _target;

        deleteVehicle _target;
        
        // Using KPIN global variable for the object class
        private _fobObject = createVehicle [KPIN_FOB_Box_Deployed, _pos, [], 0, "CAN_COLLIDE"];
        _fobObject setDir _dir;
        _fobObject setPosATL _pos;

        // Register FOB with Marker
        private _fobMarker = createMarker [format["fob_%1", round(random 1000)], _pos];
        _fobMarker setMarkerType "b_hq";
        _fobMarker setMarkerText "FOB";

        _fobObject setVariable ["KPIN_isFOB", true, true];
        _fobObject setVariable ["KPIN_FOB_Marker", _fobMarker, true];
        
        // Sync with Active Zones for persistence and cleanup
        KPIN_ActiveZones pushBack [_fobMarker, 0];
        publicVariable "KPIN_ActiveZones";

        // Initialize the pack-up option on the new object
        [_fobObject] call KPIN_fnc_packFOB; 
    },
    {}, [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
