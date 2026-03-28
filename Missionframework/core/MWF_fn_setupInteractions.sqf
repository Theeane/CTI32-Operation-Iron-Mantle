/*
    Author: OpenAI / Operation Iron Mantle
    Function: MWF_fnc_setupInteractions
    Project: Military War Framework

    Description:
    Resolves the runtime MOB terminal and initializes terminal actions directly.
    Keeps a short retry window but does not gate the rest of startup.
*/

params [["_object", objNull, [objNull]]];

if (!hasInterface) exitWith { false };

private _terminalClasses = [];
{
    if (_x isEqualType "" && {_x isNotEqualTo ""} && {(_terminalClasses find _x) < 0}) then {
        _terminalClasses pushBack _x;
    };
} forEach [
    missionNamespace getVariable ["MWF_FOB_Asset_Terminal", "Land_Laptop_unfolded_F"],
    "Land_Laptop_unfolded_F",
    "RuggedTerminal_01_communications_F",
    "Land_DataTerminal_01_F"
];

if (isNull _object) then {
    private _deadline = diag_tickTime + 45;

    while {isNull _object && {diag_tickTime < _deadline}} do {
        _object = missionNamespace getVariable ["MWF_Intel_Center", objNull];

        if (isNull _object && {!isNil "MWF_Intel_Center"}) then {
            _object = MWF_Intel_Center;
        };

        if (isNull _object) then {
            private _assetAnchor = missionNamespace getVariable ["MWF_MOB_AssetAnchor", objNull];
            if (isNull _assetAnchor && {!isNil "MWF_MOB_AssetAnchor"}) then {
                _assetAnchor = MWF_MOB_AssetAnchor;
            };

            if (!isNull _assetAnchor) then {
                private _nearAnchor = nearestObjects [_assetAnchor, _terminalClasses, 12, true];
                if !(_nearAnchor isEqualTo []) then {
                    _object = _nearAnchor # 0;
                };
            };
        };

        if (isNull _object) then {
            uiSleep 0.5;
        };
    };
};

if (isNull _object) exitWith {
    diag_log "[MWF Setup] Terminal setup skipped: no valid MOB computer object found after retries.";
    false
};

missionNamespace setVariable ["MWF_system_active", true, true];
player setVariable ["MWF_Player_Authenticated", true, true];
missionNamespace setVariable ["MWF_Intel_Center", _object, true];
MWF_Intel_Center = _object;

if (!isNil "MWF_fnc_terminal_main") then {
    ["INIT_SCROLL", _object] call MWF_fnc_terminal_main;
    ["INIT_ACE", _object] call MWF_fnc_terminal_main;
};

_object setVariable ["MWF_MOB_TerminalReady", true, true];
diag_log format ["[MWF Setup] MOB terminal initialized locally on %1.", _object];
true
