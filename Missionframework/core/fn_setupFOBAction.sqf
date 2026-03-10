/*
    Author: Theane (AGS Project)
    Description: Adds the "Unpack FOB" hold action to a container.
    Language: English
*/

params ["_container"];

[
    _container,
    "Unpack Forward Operating Base",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_request_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_request_ca.paa",
    "_this distance _target < 5",
    "_caller distance _target < 5",
    { systemChat "Unpacking logistics gear..."; },
    {},
    {
        params ["_target", "_caller"];
        private _pos = getPos _target;
        deleteVehicle _target;

        // Spawn FOB Building (e.g., a HQ tent or house)
        private _fob = "Land_Cargo_HQ_V1_F" createVehicle _pos;
        
        // Register the new FOB position
        private _fobs = missionNamespace getVariable ["AGS_active_fobs", []];
        _fobs pushBack (getPos _fob);
        missionNamespace setVariable ["AGS_active_fobs", _fobs, true];

        // Trigger the next Mission Stage (Supply Run)
        if (missionNamespace getVariable ["AGS_current_stage", 0] == 1) then {
            [2] remoteExec ["AGS_fnc_generateInitialMission", 2];
        };

        ["FOB Deployed. Communications Established."] remoteExec ["systemChat", 0];
    },
    { systemChat "Deployment interrupted."; },
    [],
    10,
    10,
    true,
    false
] call BIS_fnc_holdActionAdd;
