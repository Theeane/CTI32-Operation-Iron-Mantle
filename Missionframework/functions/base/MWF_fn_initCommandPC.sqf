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
private _condPeace = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && !(missionNamespace getVariable ['MWF_isUnderAttack', false]) && !(_target getVariable ['MWF_FOB_IsDamaged', false])";
private _condDamaged = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (_target getVariable ['MWF_FOB_IsDamaged', false])";
private _condIntel = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (player getVariable ['MWF_carriedIntelValue', 0]) > 0 && !(_target getVariable ['MWF_FOB_IsDamaged', false])";
private _condAttack = "((missionNamespace getVariable ['MWF_Campaign_Phase', 'TUTORIAL']) isEqualTo 'OPEN_WAR') && (missionNamespace getVariable ['MWF_isUnderAttack', false])";

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
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "SIDE_MISSIONS"] call MWF_fnc_dataHub;
    },
    nil, 9, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#FFCC66'>[ OPEN MAIN OPERATIONS MAP ]</t>",
    {
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "MAIN_OPERATIONS"] call MWF_fnc_dataHub;
    },
    nil, 8.5, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#99DDFF'>[ OPEN REDEPLOY MAP ]</t>",
    {
        ["OPEN"] call MWF_fnc_dataHub;
        ["SET_MODE", "REDEPLOY"] call MWF_fnc_dataHub;
    },
    nil, 8, true, true, "", _condPeace
];

_laptop addAction [
    "<t color='#66FFCC'>[ OPEN SUPPORT MAP ]</t>",
    {
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
    "<t color='#FF0000'>[ SYSTEM LOCKDOWN - UNDER ATTACK ]</t>",
    { hint "Critical Error: Command functions disabled during active engagement. Defend the perimeter!"; },
    nil, 6, true, true, "", _condAttack, 5
];

_laptop addAction [
    "<t color='#ff8800'>[ TERMINAL OFFLINE - REPAIR REQUIRED ]</t>",
    {
        params ["_target", "_caller"];
        private _cost = _target getVariable ['MWF_FOB_RepairCost', 0];
        hint format ["FOB terminal damaged. Repair cost: %1 Supplies.", _cost];
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
