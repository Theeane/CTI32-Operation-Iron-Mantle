/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Initializes the holdAction on the truck/container. 
                 On completion, spawns the full FOB asset kit (Table, Laptop, Siren, Locker).
    Language: English
*/

params [["_truck", objNull, [objNull]]];

if (isNull _truck) exitWith { diag_log "[KPIN ERROR] initFOB called with null object."; };

[
    _truck,
    "<t color='#00FF00'>Deploy FOB</t>",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "_this distance _target < 10 && speed _target < 1 && (['CAN_DEPLOY'] call KPIN_fnc_baseManager)",
    "_caller distance _target < 10",
    {}, {},
    {
        params ["_target", "_caller"];
        private _pos = getPosATL _target;
        private _dir = getDir _target;

        // 1. DATA & FAILSAFES (Fetch assets from preset or fallback to vanilla)
        private _assetRoof     = missionNamespace getVariable ["KPIN_FOB_Asset_Roof", ""];
        private _assetTable    = missionNamespace getVariable ["KPIN_FOB_Asset_Table", "Land_CampingTable_small_F"];
        private _assetTerminal = missionNamespace getVariable ["KPIN_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"];
        private _assetSiren    = missionNamespace getVariable ["KPIN_FOB_Asset_Siren", "Land_Loudspeakers_F"];
        private _assetLocker   = missionNamespace getVariable ["KPIN_FOB_Asset_Locker", "Prop_Locker_01_F"];
        private _assetLamp     = missionNamespace getVariable ["KPIN_FOB_Asset_Lamp", ""];

        deleteVehicle _target;

        // 2. SPAWN CORE (Roof & Table)
        if (_assetRoof != "") then {
            private _roof = createVehicle [_assetRoof, _pos, [], 0, "CAN_COLLIDE"];
            _roof setDir _dir; _roof setPosATL _pos;
            _roof allowDamage false;
        };

        private _table = createVehicle [_assetTable, _pos, [], 0, "CAN_COLLIDE"];
        _table setDir _dir; _table setPosATL _pos;
        _table allowDamage false;

        // 3. SPAWN COMMAND PC (The Brain)
        private _laptop = createVehicle [_assetTerminal, [0,0,0], [], 0, "CAN_COLLIDE"];
        _laptop attachTo [_table, [0, 0, 0.6]];
        _laptop setVariable ["KPIN_isCommandPC", true, true];
        _laptop allowDamage false; // Default safe
        [_laptop] remoteExec ["KPIN_fnc_initCommandPC", 0, true];

        // 4. SPAWN OPTIONAL LAMP
        if (_assetLamp != "") then {
            private _lamp = createVehicle [_assetLamp, [0,0,0], [], 0, "CAN_COLLIDE"];
            _lamp attachTo [_table, [-0.4, 0, 0.6]];
            _lamp allowDamage false;
        };

        // 5. SPAWN SIREN & LOCKER (The Tactical Hub)
        private _sirenPos = [_pos, 8, _dir + 45] call BIS_fnc_relPos;
        private _siren = createVehicle [_assetSiren, _sirenPos, [], 0, "NONE"];
        _siren setDir (_dir + 180);
        _siren allowDamage false;

        private _lockerPos = [_pos, 4, _dir - 110] call BIS_fnc_relPos;
        private _locker = createVehicle [_assetLocker, _lockerPos, [], 0, "NONE"];
        _locker setDir (_dir + 70);
        _locker allowDamage false;
        [_locker] remoteExec ["KPIN_fnc_initFOBInventory", 0, true];

        // Link locker to laptop for easy access during attacks
        _laptop setVariable ["KPIN_AttachedLocker", _locker, true];
        _laptop setVariable ["KPIN_AttachedSiren", _siren, true];

        // 6. NAMING & MARKER
        private _currentFOBs = ["GET_ACTIVE"] call KPIN_fnc_baseManager;
        private _fobIndex = (count _currentFOBs) + 1;
        private _displayName = format ["FOB %1", _fobIndex];

        private _markerName = format["fob_marker_%1", round(random 99999)];
        private _mkr = createMarker [_markerName, _pos];
        _mkr setMarkerType "b_hq";
        _mkr setMarkerText _displayName;
        _mkr setMarkerColor "ColorBLUFOR";

        // 7. REGISTRY
        _laptop setVariable ["KPIN_FOB_Marker", _markerName, true];
        _laptop setVariable ["KPIN_isUnderAttack", false, true];
        ["ADD", [_markerName, _laptop]] call KPIN_fnc_baseManager;

        ["TaskSucceeded", ["", format["%1 Deployed and Active.", _displayName]]] remoteExec ["BIS_fnc_showNotification", 0];
    },
    { hint "Deployment Aborted."; },
    [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
