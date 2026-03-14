/*
    Author: Theane / ChatGPT
    Function: fn_initFOB
    Project: Military War Framework

    Description:
    Handles init f o b for the base system.
*/

params [["_truck", objNull, [objNull]]];

if (isNull _truck) exitWith { diag_log "[KPIN ERROR] initFOB called with null object."; };

[
    _truck,
    "<t color='#00FF00'>Deploy FOB</t>",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "_this distance _target < 10 && speed _target < 1 && (['CAN_DEPLOY'] call MWF_fnc_baseManager)",
    "_caller distance _target < 10",
    {}, {},
    {
        params ["_target", "_caller"];
        private _pos = getPosATL _target;
        private _dir = getDir _target;

        // 1. DATA
        private _assetRoof     = missionNamespace getVariable ["MWF_FOB_Asset_Roof", ""];
        private _assetTable    = missionNamespace getVariable ["MWF_FOB_Asset_Table", "Land_CampingTable_small_F"];
        private _assetTerminal = missionNamespace getVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"];
        private _assetSiren    = missionNamespace getVariable ["MWF_FOB_Asset_Siren", "Land_Loudspeakers_F"];
        private _assetLocker   = missionNamespace getVariable ["MWF_FOB_Asset_Locker", "Prop_Locker_01_F"];
        private _assetLamp     = missionNamespace getVariable ["MWF_FOB_Asset_Lamp", ""];

        deleteVehicle _target;

        // 2. SPAWN CORE (Table is the physical anchor)
        private _table = createVehicle [_assetTable, _pos, [], 0, "CAN_COLLIDE"];
        _table setDir _dir; _table setPosATL _pos;
        _table allowDamage false; // Damage handling is controlled through the laptop interaction

        // 3. SPAWN ROOF (Ghost Mode)
        private _roofObj = objNull;
        if (_assetRoof != "") then {
            _roofObj = createVehicle [_assetRoof, _pos, [], 0, "CAN_COLLIDE"];
            _roofObj setDir _dir; _roofObj setPosATL _pos;
            _roofObj enableSimulationGlobal false; // Disable simulation so bullets pass through as intended
            _roofObj allowDamage false;
        };

        // 4. SPAWN COMMAND PC (The Brain)
        private _laptop = createVehicle [_assetTerminal, [0,0,0], [], 0, "CAN_COLLIDE"];
        _laptop attachTo [_table, [0, 0, 0.6]];
        _laptop setVariable ["MWF_isCommandPC", true, true];
        _laptop allowDamage false; 
        [_laptop] remoteExec ["MWF_fnc_initCommandPC", 0, true];

        // 5. SPAWN GHOST SIREN
        private _sirenPos = [_pos, 8, _dir + 45] call BIS_fnc_relPos;
        private _siren = createVehicle [_assetSiren, _sirenPos, [], 0, "NONE"];
        _siren setDir (_dir + 180);
        _siren enableSimulationGlobal false; // Ghost mode
        _siren allowDamage false;

        // 6. SPAWN PHYSICAL LOCKER
        private _lockerPos = [_pos, 4, _dir - 110] call BIS_fnc_relPos;
        private _locker = createVehicle [_assetLocker, _lockerPos, [], 0, "NONE"];
        _locker setDir (_dir + 70);
        _locker allowDamage false; // Only destroyed if laptop dies
        [_locker] remoteExec ["MWF_fnc_initFOBInventory", 0, true];

        // --- LINK EVERYTHING TO THE BRAIN (Laptop) ---
        _laptop setVariable ["MWF_AttachedTable", _table, true];
        _laptop setVariable ["MWF_AttachedRoof", _roofObj, true];
        _laptop setVariable ["MWF_AttachedSiren", _siren, true];
        _laptop setVariable ["MWF_AttachedLocker", _locker, true];

        // 7. NAMING & MARKER (Samma som din kod)
        private _currentFOBs = ["GET_ACTIVE"] call MWF_fnc_baseManager;
        private _fobIndex = (count _currentFOBs) + 1;
        private _displayName = format ["FOB %1", _fobIndex];
        private _markerName = format["fob_marker_%1", round(random 99999)];
        private _mkr = createMarker [_markerName, _pos];
        _mkr setMarkerType "b_hq";
        _mkr setMarkerText _displayName;
        _mkr setMarkerColor "ColorBLUFOR";

        _laptop setVariable ["MWF_FOB_Marker", _markerName, true];
        _laptop setVariable ["MWF_isUnderAttack", false, true];
        ["ADD", [_markerName, _laptop]] call MWF_fnc_baseManager;

        // 8. UNIVERSAL CLEANUP TRIGGER (On Table or Laptop)
        _laptop addEventHandler ["Killed", {
            params ["_unit"];
            [_unit] spawn {
                params ["_laptop"];
                // Radera alla Ghost-objekt omedelbart
                deleteVehicle (_laptop getVariable ["MWF_AttachedRoof", objNull]);
                deleteVehicle (_laptop getVariable ["MWF_AttachedSiren", objNull]);
                deleteVehicle (_laptop getVariable ["MWF_AttachedLocker", objNull]);
                deleteVehicle (_laptop getVariable ["MWF_AttachedTable", objNull]);
                
                deleteMarker (_laptop getVariable ["MWF_FOB_Marker", ""]);
                
                sleep 10; // Clean up the laptop object after 10 seconds
                deleteVehicle _laptop;
            };
        }];

        ["TaskSucceeded", ["", format["%1 Deployed and Active.", _displayName]]] remoteExec ["BIS_fnc_showNotification", 0];
    },
    { hint "Deployment Aborted."; },
    [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
