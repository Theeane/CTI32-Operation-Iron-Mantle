/*
    Author: Theane (AGS Project)
    Description: HQ Login with animation and mission trigger.
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
            // START: Spela animation på spelaren
            params ["_target", "_caller"];
            _caller playMoveNow "AinvPknlMstpSnonWnonDnon_medic_1"; 
            systemChat "Accessing Command Terminal...";
        },
        {},
        { 
            // COMPLETION: Systemet startar
            params ["_target", "_caller"];
            
            // 1. Lås upp globala system
            missionNamespace setVariable ["AGS_system_active", true, true];
            
            // 2. Starta HUD för spelaren
            if (hasInterface) then {
                cutRsc ["AGS_ResourceBar", "PLAIN"];
                [] spawn AGS_fnc_updateResourceUI;
            };

            // 3. Trigga det första uppdraget (Infiltration / Capture)
            if (isServer) then {
                [] spawn AGS_fnc_generateInitialMission;
            } else {
                [] remoteExec ["AGS_fnc_generateInitialMission", 2];
            };

            [format ["%1 has established a secure link. Operations online.", name _caller]] remoteExec ["systemChat", 0];
            _caller switchMove ""; // Avbryt animationen snyggt
        },
        { 
            // INTERRUPT: Om man slutar hålla in knappen
            params ["_target", "_caller"];
            _caller switchMove ""; 
            systemChat "Connection Terminated.";
        },
        [],
        8, // Tid för inloggning (sekunder)
        10,
        false,
        false
    ] call BIS_fnc_holdActionAdd;
};
