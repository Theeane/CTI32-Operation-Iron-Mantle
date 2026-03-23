/*
    Author: Theane / ChatGPT
    Function: fn_despawnZoneAssets
    Project: Military War Framework

    Description:
    Cleans temporary zone-owned AI assets while preserving player-owned vehicles and
    persistent/base-built objects.
*/

params ["_zonePos", "_despawnRadius"];

private _isProtectedObject = {
    params ["_obj"];
    (_obj getVariable ["MWF_isBought", false]) ||
    (_obj getVariable ["MWF_isBuiltByPlayer", false]) ||
    (_obj getVariable ["MWF_isPermanent", false])
};

private _unitsInArea = allUnits select { _x distance2D _zonePos < _despawnRadius };

{
    private _unit = _x;
    if (!isPlayer _unit) then {
        private _carrier = vehicle _unit;
        private _protectedCarrier = (!isNull _carrier) && {_carrier != _unit} && {[_carrier] call _isProtectedObject};
        private _protectedUnit = [_unit] call _isProtectedObject;

        if !(_protectedCarrier || _protectedUnit) then {
            private _group = group _unit;
            deleteVehicle _unit;

            if ((count (units _group)) == 0) then {
                deleteGroup _group;
            };
        };
    };
} forEach _unitsInArea;

private _vehiclesInArea = vehicles select {
    alive _x &&
    {(_x distance2D _zonePos) < _despawnRadius} &&
    {!(_x isKindOf "StaticWeapon")}
};

{
    private _veh = _x;
    private _protected = [_veh] call _isProtectedObject;
    private _playerCrew = (crew _veh) findIf { isPlayer _x };

    if (!_protected && {_playerCrew < 0} && {(count crew _veh) == 0}) then {
        deleteVehicle _veh;
    };
} forEach _vehiclesInArea;

diag_log format ["[Iron Mantle] Zone at %1 cleaned up. Temporary units and vehicles removed.", _zonePos];
