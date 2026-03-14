/*
    Author: Theane / ChatGPT
    Function: fn_setupInteractions
    Project: Military War Framework

    Description:
    Handles setup interactions for the core framework layer.
*/

params ["_object"];

[
    _object,
    "Login to Command Network",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
    "_this distance _target < 2",
    "_caller distance _target < 2",
    { 
        params ["_target", "_caller"];
        _caller playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1"; 
        systemChat "Establishing encrypted connection...";
    },
    {},
    { 
        params ["_target", "_caller"];
        missionNamespace setVariable ["MWF_system_active", true, true];
        
        // Show the Resource UI for the player
        if (hasInterface) then {
            cutRsc ["MWF_ResourceBar", "PLAIN"];
            [] spawn MWF_fnc_updateResourceUI;
        };

        // Trigger the first task: Deploy FOB
        if (isServer) then { 
            [1] spawn MWF_fnc_generateInitialMission; 
        } else { 
            [1] remoteExec ["MWF_fnc_generateInitialMission", 2]; 
        };

        [format ["%1 has authorized system access. FOB Container is ready for transport.", name _caller]] remoteExec ["systemChat", 0];
        _caller switchMove ""; 
    },
    { params ["_target", "_caller"]; _caller switchMove ""; systemChat "Login aborted."; },
    [],
    8, 
    10,
    false,
    false
] call BIS_fnc_holdActionAdd;
