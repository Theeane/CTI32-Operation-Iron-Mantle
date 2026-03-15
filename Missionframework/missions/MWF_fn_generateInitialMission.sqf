/*
    Author: Theane / ChatGPT
    Function: fn_generateInitialMission
    Project: Military War Framework

    Description:
    Handles mission logic for generate initial mission.
*/

if (!isServer) exitWith {};

params [["_stage", 1]];

switch (_stage) do {
    case 1: {
        [
            west,
            "task_deploy_fob",
            [
                "Use the HQ Terminal to build or deploy your first Forward Operating Base (FOB). This will serve as your respawn point and logistics hub.",
                "Deploy FOB",
                ""
            ],
            objNull,
            "CREATED",
            5,
            true,
            "setup",
            true
        ] call BIS_fnc_taskCreate;

        missionNamespace setVariable ["MWF_current_stage", 1, true];
    };

    case 2: {
        ["task_deploy_fob", "SUCCEEDED"] call BIS_fnc_taskSetState;

        [
            west,
            "task_supply_run",
            [
                "We are low on resources. A supply crate has been located in a nearby village. Recover it to fund our first offensive.",
                "Conduct Supply Run",
                ""
            ],
            objNull,
            "CREATED",
            5,
            true,
            "container",
            true
        ] call BIS_fnc_taskCreate;

        missionNamespace setVariable ["MWF_current_stage", 2, true];
    };

    case 3: {
        ["task_supply_run", "SUCCEEDED"] call BIS_fnc_taskSetState;

        private _basePos = getMarkerPos "MWF_base_marker";
        private _allZones = missionNamespace getVariable ["MWF_all_mission_zones", []];
        private _targetZone = [_allZones, _basePos] call BIS_fnc_nearestPosition;

        if (!isNull _targetZone) then {
            private _zoneName = _targetZone getVariable ["MWF_zoneName", "the nearest sector"];
            private _zonePos = getPosWorld _targetZone;

            [
                west,
                "task_initial_capture",
                [
                    format ["With the FOB and supplies secured, capture %1 to establish a permanent Supply Line.", _zoneName],
                    "Secure First Sector",
                    _zonePos
                ],
                _zonePos,
                "CREATED",
                5,
                true,
                "target",
                true
            ] call BIS_fnc_taskCreate;
        };

        missionNamespace setVariable ["MWF_current_stage", 3, true];
    };
};
