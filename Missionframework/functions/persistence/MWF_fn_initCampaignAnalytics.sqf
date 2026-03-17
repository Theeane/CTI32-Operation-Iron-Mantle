/*
    Author: Theane / ChatGPT
    Function: fn_initCampaignAnalytics
    Project: Military War Framework

    Description:
    Initializes the server-side campaign analytics tracker.
    This registers mission event handlers that attribute kills and destruction to player UIDs.
*/

if (!isServer) exitWith {};
if (missionNamespace getVariable ["MWF_CampaignAnalyticsStarted", false]) exitWith {};

missionNamespace setVariable ["MWF_CampaignAnalyticsStarted", true, true];
missionNamespace setVariable ["MWF_Campaign_Analytics", missionNamespace getVariable ["MWF_Campaign_Analytics", []], true];
missionNamespace setVariable ["MWF_AuthenticatedPlayers", missionNamespace getVariable ["MWF_AuthenticatedPlayers", []], true];

addMissionEventHandler ["EntityKilled", {
    params ["_killed", "_killer", "_instigator"];

    private _actor = if (!isNull _instigator) then { _instigator } else { _killer };
    if (isNull _actor) exitWith {};

    if (!isPlayer _actor) then {
        private _veh = vehicle _actor;
        if (!isNull _veh) then {
            private _cmd = effectiveCommander _veh;
            if (!isNull _cmd && {isPlayer _cmd}) then {
                _actor = _cmd;
            };
        };
    };

    if (isNull _actor || {!isPlayer _actor}) exitWith {};

    private _uid = getPlayerUID _actor;
    if (_uid isEqualTo "") exitWith {};

    private _name = name _actor;

    if (_killed isKindOf "CAManBase") then {
        if (_killed getVariable ["MWF_IsRebelLeader", false]) then {
            if (!(_killed getVariable ["MWF_RebelLeaderResolved", false]) && {!isNil "MWF_fnc_fobAttackSystem"}) then {
                ["START", _killed, _actor] spawn MWF_fnc_fobAttackSystem;
            };
        };

        switch (side group _killed) do {
            case east: {
                [_uid, _name, "OPFOR_KILLED", 1] call MWF_fnc_recordCampaignEvent;
            };
            case resistance: {
                [_uid, _name, "REBELS_KILLED", 1] call MWF_fnc_recordCampaignEvent;
            };
            case civilian: {
                [_uid, _name, "CIVILIANS_KILLED", 1] call MWF_fnc_recordCampaignEvent;

                if (!isNil "MWF_fnc_handleCivilianCasualty") then {
                    [_killed, _actor, _uid, _name] call MWF_fnc_handleCivilianCasualty;
                };
            };
        };

        private _isExecutionTarget = (_killed getVariable ["MWF_IsEndBoss", false]) || (_killed getVariable ["MWF_IsRebelLeader", false]) || {_killed isEqualTo (missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull])};
        private _isUnarmed = ((primaryWeapon _killed) isEqualTo "") && ((secondaryWeapon _killed) isEqualTo "") && ((handgunWeapon _killed) isEqualTo "");
        private _isCaptive = captive _killed || {(_killed getVariable ["ACE_isSurrendering", false])} || {(_killed getVariable ["ACE_captives_isHandcuffed", false])};

        if (_isExecutionTarget && _isUnarmed && _isCaptive) then {
            [_uid, _name, "EXECUTIONER", 1] call MWF_fnc_recordCampaignEvent;
            diag_log format ["[MWF Analytics] Executioner event recorded for %1 (%2).", _name, _uid];
        };
    } else {
        private _infraType = _killed getVariable ["MWF_InfraType", ""];
        if (_infraType isEqualTo "" && {(_killed isKindOf "House") || {_killed isKindOf "Building"}}) then {
            [_uid, _name, "BUILDINGS_DESTROYED", 1] call MWF_fnc_recordCampaignEvent;
        };
    };
}];

diag_log "[MWF Analytics] Campaign analytics tracker initialized.";
