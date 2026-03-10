/*
    Author: Theane (AGS Project)
    Description: HQ Terminal Interaction. Handles login animation, unlocks HUD, 
                 and triggers the initial mission sequence.
    Language: English
*/

AGS_fnc_addTerminalAction = {
    params ["_object"];

    [
        _object,
        "Login to Command Network",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
        "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_connect_ca.paa",
        "_this distance _target < 2",
        "_caller distance _target < 2",
        { 
            // START: Play keyboard/typing animation on the player
            params ["_target", "_caller"];
            _caller playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1"; 
            systemChat "Accessing Command Terminal...";
        },
        {},
        { 
            // COMPLETION: Systems Online
            params ["_target", "_caller"];
            
            // 1. Unlock global framework systems
            missionNamespace setVariable ["AGS_system_active", true, true];
            
            // 2. Initialize the HUD for the local player
            if (hasInterface) then {
                cutRsc ["AGS_ResourceBar", "PLAIN"];
                [] spawn AGS_fnc_updateResourceUI;
            };

            // 3. Trigger the initial infiltration mission on the server
            if (isServer) then {
                [] spawn AGS_fnc_generateInitialMission;
            } else {
                [] remoteExec ["AGS_fnc_generateInitialMission", 2];
            };

            [format ["%1 has established a secure link. Operations online.", name _caller]] remoteExec ["systemChat", 0];
            
            // Stop animation gracefully
            _caller switchMove ""; 
        },
        { 
            // INTERRUPT: Stop animation if the player lets go
            params ["_target", "_caller"];
            _caller switchMove ""; 
            systemChat "Connection Terminated.";
        },
        [],
        8, // Login duration in seconds
        10,
        false,
        false
    ] call BIS_fnc_holdActionAdd;
};
