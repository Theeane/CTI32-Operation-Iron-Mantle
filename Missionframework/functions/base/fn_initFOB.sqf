/* Author: Theeane
    Description: Deploys a vehicle/container into a static FOB.
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
        private _fobObject = createVehicle [GVAR_FOB_Box_Deployed, _pos, [], 0, "CAN_COLLIDE"];
        _fobObject setDir _dir;
        _fobObject setPosATL _pos;

        // Register FOB
        private _fobMarker = createMarker [format["fob_%1", round(random 1000)], _pos];
        _fobMarker setMarkerType "b_hq";
        _fobMarker setMarkerText "FOB";

        _fobObject setVariable ["GVAR_isFOB", true, true];
        _fobObject setVariable ["GVAR_FOB_Marker", _fobMarker, true];
        
        // Add to global zones for economy/cleanup
        GVAR_ActiveZones pushBack [_fobMarker, 0];
        publicVariable "GVAR_ActiveZones";

        [_fobObject] call CTI_fnc_packFOB; 
    },
    {}, [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
