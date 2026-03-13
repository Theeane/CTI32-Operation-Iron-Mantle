/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Deploys a vehicle/container into a static FOB. 
    Integrates Base Manager limits and dynamic naming logic.
    Language: English
*/

params [["_truck", objNull, [objNull]]];

if (isNull _truck) exitWith {};

[
    _truck,
    "Deploy FOB",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    // Condition: Close to vehicle, standing still, and within logistical Max FOB limit
    "_this distance _target < 10 && speed _target < 1 && (['CAN_DEPLOY'] call KPIN_fnc_baseManager)",
    "_caller distance _target < 10",
    { 
        // Start effect or animation if desired
    }, 
    {},
    {
        params ["_target", "_caller"];
        private _pos = getPosATL _target;
        private _dir = getDir _target;

        // 1. Prepare Deployment
        deleteVehicle _target;
        private _fobObject = createVehicle [KPIN_FOB_Box_Deployed, _pos, [], 0, "CAN_COLLIDE"];
        _fobObject setDir _dir;
        _fobObject setPosATL _pos;

        // 2. Dynamic Naming Logic
        // Determine index based on current registry count
        private _currentFOBs = ["GET_ACTIVE"] call KPIN_fnc_baseManager;
        private _fobIndex = (count _currentFOBs) + 1;
        
        // Look for custom name (e.g., KPIN_FOB_1_Name), fallback to default "FOB X"
        private _varName = format ["KPIN_FOB_%1_Name", _fobIndex];
        private _displayName = missionNamespace getVariable [_varName, format ["FOB %1", _fobIndex]];

        // 3. Create Marker with Dynamic Label
        private _markerName = format["fob_marker_%1_%2", _fobIndex, round(random 9999)];
        private _fobMarker = createMarker [_markerName, _pos];
        _fobMarker setMarkerType "b_hq";
        _fobMarker setMarkerText _displayName;

        // 4. Registry and Variable Sync
        _fobObject setVariable ["KPIN_isFOB", true, true];
        _fobObject setVariable ["KPIN_FOB_Marker", _markerName, true];
        _fobObject setVariable ["KPIN_FOB_DisplayName", _displayName, true];
        
        // Register with the Base Manager
        ["ADD", [_markerName, _fobObject]] call KPIN_fnc_baseManager;

        // 5. Initialize Pack-up / Logistics options
        [_fobObject] call KPIN_fnc_packFOB; 

        ["TaskSucceeded", ["", format["%1 Deployed and Active.", _displayName]]] remoteExec ["BIS_fnc_showNotification", allPlayers];
    },
    {
        // On interrupt - Check if limit was the cause
        if !(["CAN_DEPLOY"] call KPIN_fnc_baseManager) then {
            hint "Deployment Aborted: Logistical limit (Max FOBs) reached.";
        };
    }, 
    [], 10, 0, true, false
] call BIS_fnc_holdActionAdd;
