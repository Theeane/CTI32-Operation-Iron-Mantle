/*
    Author: Theane / ChatGPT
    Function: fn_generateZonesFromMap
    Project: Military War Framework

    Description:
    Generates automatic zone objects from map metadata while respecting manual overrides by zone type.
*/

if (!isServer) exitWith {[]};

params [
    ["_existingZones", [], [[]]]
];

private _generatedZones = [];
private _disabledTypes = [];

{
    private _zoneType = toLower (_x getVariable ["MWF_zoneType", ""]);
    if (_zoneType != "") then {
        _disabledTypes pushBackUnique _zoneType;
    };
} forEach _existingZones;

private _createGeneratedZone = {
    params ["_zoneType", "_zoneName", "_zonePos", "_zoneRange", ["_source", "auto_map", [""]]];

    private _zone = createVehicle ["Logic", _zonePos, [], 0, "CAN_COLLIDE"];
    _zone setPosWorld _zonePos;
    _zone setVariable ["MWF_zoneID", toLower format ["%1_%2", _zoneType, _zone call BIS_fnc_netId], true];
    _zone setVariable ["MWF_zoneType", _zoneType, true];
    _zone setVariable ["MWF_zoneName", _zoneName, true];
    _zone setVariable ["MWF_zoneRange", _zoneRange, true];
    _zone setVariable ["MWF_zoneSource", _source, true];
    _zone setVariable ["MWF_zoneOwnerState", "enemy", true];
    _zone setVariable ["MWF_isCaptured", false, true];
    _zone setVariable ["MWF_underAttack", false, true];
    _zone setVariable ["MWF_contested", false, true];
    _zone setVariable ["MWF_capProgress", 0, true];

    _zone
};

private _mapLocations = nearestLocations [[worldSize * 0.5, worldSize * 0.5, 0], ["NameCityCapital", "NameCity", "NameVillage"], worldSize];

if !(("capital" in _disabledTypes) && ("town" in _disabledTypes)) then {
    {
        private _location = _x;
        private _locationType = type _location;
        private _zoneType = switch (_locationType) do {
            case "NameCityCapital": {"capital"};
            case "NameCity": {"town"};
            default {"town"};
        };

        if !(_zoneType in _disabledTypes) then {
            private _zonePos = locationPosition _location;
            private _zoneName = text _location;
            private _zoneRange = if (_zoneType isEqualTo "capital") then {450} else {300};

            if (_zoneName isEqualTo "") then {
                _zoneName = format ["%1 Zone", _zoneType];
            };

            private _tooClose = false;
            {
                if ((_x distance2D _zonePos) < 800) exitWith {
                    _tooClose = true;
                };
            } forEach (_existingZones apply { getPosWorld _x });

            if (!_tooClose) then {
                _generatedZones pushBack ([_zoneType, _zoneName, _zonePos, _zoneRange, "auto_location"] call _createGeneratedZone);
            };
        };
    } forEach _mapLocations;
};

if !("factory" in _disabledTypes) then {
    private _industrialClasses = ["Land_Factory_Main_F", "Land_Industrial_Main_F", "Land_dp_mainFactory_F", "Land_u_Barracks_V2_F"];
    private _industrialObjects = nearestObjects [[worldSize * 0.5, worldSize * 0.5, 0], _industrialClasses, worldSize];

    {
        private _pos = getPosWorld _x;
        private _occupied = false;

        {
            if ((_x distance2D _pos) < 1000) exitWith {
                _occupied = true;
            };
        } forEach ((_existingZones + _generatedZones) apply { getPosWorld _x });

        if (!_occupied) then {
            _generatedZones pushBack (["factory", "Industrial Complex", _pos, 300, "auto_factory"] call _createGeneratedZone);
        };
    } forEach _industrialObjects;
};

if !("military" in _disabledTypes) then {
    private _militaryClasses = ["Land_Cargo_HQ_V1_F", "Land_Radar_Small_F", "Land_BagBunker_Large_F", "Land_MilOffices_V1_F", "Land_Airport_01_controlTower_F"];
    private _militaryObjects = nearestObjects [[worldSize * 0.5, worldSize * 0.5, 0], _militaryClasses, worldSize];

    {
        private _pos = getPosWorld _x;
        private _occupied = false;

        {
            if ((_x distance2D _pos) < 1200) exitWith {
                _occupied = true;
            };
        } forEach ((_existingZones + _generatedZones) apply { getPosWorld _x });

        if (!_occupied) then {
            _generatedZones pushBack (["military", "Military Outpost", _pos, 350, "auto_military"] call _createGeneratedZone);
        };
    } forEach _militaryObjects;
};

_generatedZones
