/*
    Author: Theane / ChatGPT
    Function: fn_initCommandPC
    Project: Military War Framework

    Description:
    Initializes the FOB command PC action set.
    The command computer is the authoritative UX entry for missions, upgrades and support.
*/

params [["_laptop", objNull, [objNull]]];

if (isNull _laptop) exitWith {};

// Legacy locker-driven FOB inventory has been retired.
// Command PC actions remain focused on terminal/base-control logic only.
_laptop allowDamage false;

private _condOpenWar = "(missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR'";
private _condPeace = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && !(_target getVariable ['MWF_isUnderAttack', false]) && !(_target getVariable ['MWF_FOB_IsDamaged', false])";
private _condDamaged = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (_target getVariable ['MWF_FOB_IsDamaged', false])";
private _condIntel = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (player getVariable ['MWF_carriedIntelValue', 0]) > 0 && !(_target getVariable ['MWF_FOB_IsDamaged', false])";
private _condAttack = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (_target getVariable ['MWF_isUnderAttack', false])";

_laptop addAction [
    "<t color='#00FF00'>[ ACCESS COMMAND NETWORK ]</t>",
    {
        params ["_target", "_caller"];
        [_target, _caller] spawn MWF_fnc_openBuyMenu;
    },
    nil, 10, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#66CCFF'>[ OPEN MISSION MAP ]</t>",
    {
        missionNamespace setVariable ['MWF_CommandTerminal_Object', _target];
        missionNamespace setVariable ['MWF_CommandTerminal_User', _caller];
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub;
    },
    nil, 9, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#FFCC66'>[ OPEN MAIN OPERATIONS MAP ]</t>",
    {
        missionNamespace setVariable ['MWF_CommandTerminal_Object', _target];
        missionNamespace setVariable ['MWF_CommandTerminal_User', _caller];
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "MAIN_OPERATIONS"] call MWF_fnc_dataHub;
    },
    nil, 8.5, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#99DDFF'>[ OPEN REDEPLOY MAP ]</t>",
    {
        missionNamespace setVariable ['MWF_CommandTerminal_Object', _target];
        missionNamespace setVariable ['MWF_CommandTerminal_User', _caller];
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "REDEPLOY"] call MWF_fnc_dataHub;
    },
    nil, 8, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#66FFCC'>[ OPEN SUPPORT MAP ]</t>",
    {
        missionNamespace setVariable ['MWF_CommandTerminal_Object', _target];
        missionNamespace setVariable ['MWF_CommandTerminal_User', _caller];
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "SUPPORT"] call MWF_fnc_dataHub;
    },
    nil, 7.5, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#00FFFF'>[ UPLOAD SECURED INTEL ]</t>",
    {
        params ["_target", "_caller"];
        [_target, _caller] remoteExecCall ["MWF_fnc_depositIntel", 2];
    },
    nil, 7, true, true, "", _condIntel
];

_laptop addAction [
    "<t color='#FFFF00'>[ UPGRADE BASE TIER ]</t>",
    {
        params ["_target", "_caller"];
        [_target, _caller] remoteExecCall ["MWF_fnc_upgradeBaseTier", 2];
    },
    nil, 6.5, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#FF0000'>[ SYSTEM LOCKDOWN - LOCAL FOB UNDER ATTACK ]</t>",
    {
        params ["_target"];
        private _displayName = _target getVariable ['MWF_FOB_DisplayName', 'FOB'];
        private _state = missionNamespace getVariable ['MWF_FOBAttackState', ['idle']];
        private _remainingText = "Unknown";
        private _remaining = -1;
        if ((_state param [0, 'idle']) isEqualTo 'active') then {
            _remaining = ((_state param [4, diag_tickTime]) - diag_tickTime) max 0;
        } else {
            private _localEndAt = _target getVariable ['MWF_FOB_AttackEndAt', -1];
            if (_localEndAt >= 0) then {
                _remaining = (_localEndAt - diag_tickTime) max 0;
            };
        };
        if (_remaining >= 0) then {
            private _minutes = floor (_remaining / 60);
            private _seconds = floor (_remaining mod 60);
            _remainingText = if (_minutes > 0) then {
                format ['%1m %2s', _minutes, _seconds]
            } else {
                format ['%1s', _seconds]
            };
        };
        hint format ["%1 is currently under attack. This FOB computer is locked until the assault ends.\n\nRemaining: %2\n\nIntel turn-in remains available during the assault. The MOB and other FOB computers remain usable.", _displayName, _remainingText];
    },
    nil, 6, true, true, "", _condAttack, 5
];

_laptop addAction [
    "<t color='#ff8800'>[ TERMINAL OFFLINE - REPAIR REQUIRED ]</t>",
    {
        params ["_target"];
        private _displayName = _target getVariable ['MWF_FOB_DisplayName', 'FOB'];
        private _cost = _target getVariable ['MWF_FOB_RepairCost', 0];
        private _deadline = _target getVariable ['MWF_FOB_DespawnDeadline', -1];
        private _remainingText = "Expired";
        if (_deadline >= 0) then {
            private _remaining = (_deadline - diag_tickTime) max 0;
            private _minutes = floor (_remaining / 60);
            private _seconds = floor (_remaining mod 60);
            _remainingText = if (_minutes > 0) then {
                format ['%1m %2s', _minutes, _seconds]
            } else {
                format ['%1s', _seconds]
            };
        };
        hint format ["%1 terminal offline.\n\nRepair cost: %2 Supplies\nTime until FOB collapse: %3\n\nRedeploy to this FOB is disabled until the terminal is repaired.", _displayName, _cost, _remainingText];
    },
    nil, 6, true, true, "", _condDamaged, 5
];

_laptop setObjectTextureGlobal [0, "A3\Structures_F\Items\Electronics\Data\Laptops_01_screen_CO.paa"];
diag_log "[KPIN] Command PC Initialized.";

_laptop addAction [
    "<t color='#ffaa00'>[ AUTHORIZE FOB REPACK ]</t>",
    {
        params ["_target", "_caller"];
        [_target, true] remoteExec ["MWF_fnc_commanderToggleRepack", 2];
    },
    nil, 4, true, true, "", "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && !(_target getVariable ['MWF_FOB_CanRepack', false]) && !(_target getVariable ['MWF_FOB_IsDamaged', false])"
];

_laptop addAction [
    "<t color='#ff6600'>[ LOCK FOB REPACK ]</t>",
    {
        params ["_target", "_caller"];
        [_target, false] remoteExec ["MWF_fnc_commanderToggleRepack", 2];
    },
    nil, 4, true, true, "", "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (_target getVariable ['MWF_FOB_CanRepack', false]) && !(_target getVariable ['MWF_FOB_IsDamaged', false])"
];

[_laptop] call MWF_fnc_packFOB;
