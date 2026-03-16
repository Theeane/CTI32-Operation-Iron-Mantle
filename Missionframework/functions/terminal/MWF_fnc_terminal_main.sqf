/*
    Author: Gemini (Production Pass 3.0)
    Purpose: Setup for FOB/MOB Terminal. Full parity between ACE and Scroll.
*/
if (!hasInterface) exitWith {};

params [
    ["_mode", "INIT_SCROLL", [""]],
    ["_terminal", objNull, [objNull]]
];

if (isNull _terminal) exitWith {};

switch (toUpper _mode) do {
    case "INIT_SCROLL": {
        if (_terminal getVariable ["MWF_Terminal_ScrollInit", false]) exitWith {};
        _terminal setVariable ["MWF_Terminal_ScrollInit", true]; 

        private _cond = "alive _target && alive _this && _this distance _target < 3";
        _terminal addAction ["<t color='#7CC8FF'>[Terminal] Upload Data</t>", { [player] call MWF_fnc_terminal_upload; }, nil, 1.5, true, true, "", _cond];
        _terminal addAction ["<t color='#7CC8FF'>[Terminal] Mission Hub</t>", { ["MISSION_HUB"] call MWF_fnc_terminal_main; }, nil, 1.4, true, true, "", _cond];
        _terminal addAction ["<t color='#FFD700'>[Terminal] Intelligence Disrupt (150 I)</t>", { [player] call MWF_fnc_terminal_disrupt; }, nil, 1.3, true, true, "", _cond];
        _terminal addAction ["<t color='#7CFF9B'>[Terminal] Vehicle Menu</t>", { ["OPEN", _target] call MWF_fnc_terminal_vehicleMenu; }, nil, 1.2, true, true, "", _cond];
    };

    case "INIT_ACE": {
        if !(isClass (configFile >> "CfgPatches" >> "ace_interact_menu")) exitWith { ["INIT_SCROLL", _terminal] call MWF_fnc_terminal_main; };
        if (_terminal getVariable ["MWF_Terminal_ACEInit", false]) exitWith {};
        _terminal setVariable ["MWF_Terminal_ACEInit", true];
        
        private _root = ["MWF_Term_Root", "Terminal", "", {true}, {true}] call ace_interact_menu_fnc_createAction;
        [_terminal, 0, ["ACE_MainActions"], _root] call ace_interact_menu_fnc_addActionToObject;

        private _upld = ["MWF_Term_Up", "Upload Data", "", { [player] call MWF_fnc_terminal_upload; }, {alive _target}] call ace_interact_menu_fnc_createAction;
        [_terminal, 0, ["ACE_MainActions", "MWF_Term_Root"], _upld] call ace_interact_menu_fnc_addActionToObject;

        // ACE Parity: Mission Hub added
        private _hub = ["MWF_Term_Hub", "Mission Hub", "", { ["MISSION_HUB"] call MWF_fnc_terminal_main; }, {alive _target}] call ace_interact_menu_fnc_createAction;
        [_terminal, 0, ["ACE_MainActions", "MWF_Term_Root"], _hub] call ace_interact_menu_fnc_addActionToObject;

        private _disr = ["MWF_Term_Di", "Intel Disrupt (150 I)", "", { [player] call MWF_fnc_terminal_disrupt; }, {alive _target}] call ace_interact_menu_fnc_createAction;
        [_terminal, 0, ["ACE_MainActions", "MWF_Term_Root"], _disr] call ace_interact_menu_fnc_addActionToObject;

        private _veh = ["MWF_Term_Veh", "Vehicle Menu", "", { ["OPEN", _target] call MWF_fnc_terminal_vehicleMenu; }, {alive _target}] call ace_interact_menu_fnc_createAction;
        [_terminal, 0, ["ACE_MainActions", "MWF_Term_Root"], _veh] call ace_interact_menu_fnc_addActionToObject;
    };

    case "MISSION_HUB": {
        [["MISSION HUB", "Accessing encrypted quest database..."], "info"] call MWF_fnc_showNotification;
        openMap [true, false]; 
    };

    case "VEHICLE_MENU": {
        ["OPEN", _terminal] call MWF_fnc_terminal_vehicleMenu;
    };
};