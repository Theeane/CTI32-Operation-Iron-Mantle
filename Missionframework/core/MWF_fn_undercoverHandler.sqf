/*
    Author: Theane / ChatGPT
    Function: MWF_fn_undercoverHandler
    Project: Military War Framework

    Description:
    Handles undercover status, suspicion state, and detection logic for the player.
    Supports both marker-based and object-based mission zones.
*/

if (!hasInterface) exitWith {};

waitUntil {
    !isNull player &&
    {!isNil "MWF_cfg_civUniforms"} &&
    {!isNil "MWF_cfg_enemyUniforms"} &&
    {!isNil "MWF_cfg_enemyVests"} &&
    {!isNil "MWF_cfg_enemyHeadgear"}
};

cutRsc ["MWF_Undercover_Eye", "PLAIN"];

[] spawn {
    private _ctrl = controlNull;

    while {alive player} do {
        uiSleep 2;

        if (isNull _ctrl) then {
            _ctrl = uiNamespace getVariable ["MWF_ctrl_eye", controlNull];
        };

        private _civUniforms   = missionNamespace getVariable ["MWF_cfg_civUniforms", []];
        private _enemyUniforms = missionNamespace getVariable ["MWF_cfg_enemyUniforms", []];
        private _enemyVests    = missionNamespace getVariable ["MWF_cfg_enemyVests", []];
        private _enemyHeadgear = missionNamespace getVariable ["MWF_cfg_enemyHeadgear", []];
        private _contraband    = missionNamespace getVariable ["MWF_cfg_contrabandItems", []];
        private _contrabandCat = missionNamespace getVariable ["MWF_cfg_contrabandCategories", []];

        private _isUndercover = true;
        private _isSuspicious = false;
        private _eyeIcon = "media\icons\eye_green.paa";

        private _hasEnemyUniform = uniform player in _enemyUniforms;
        private _hasEnemyVest = vest player in _enemyVests;
        private _hasEnemyHelmet = headgear player in _enemyHeadgear;
        private _isCivilian = uniform player in _civUniforms;

        if (_hasEnemyUniform) then {
            if (_hasEnemyVest && _hasEnemyHelmet) then {
                _isSuspicious = false;
                _eyeIcon = "media\icons\eye_green.paa";
            } else {
                if (_hasEnemyVest || _hasEnemyHelmet) then {
                    _isUndercover = false;
                } else {
                    _isSuspicious = true;
                    _eyeIcon = "media\icons\eye_yellow.paa";
                };
            };

            private _nearEnemies = allUnits select {
                alive _x &&
                {side _x == east} &&
                {_x distance player < 5}
            };

            {
                private _detectRange = if (rank _x in ["SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"]) then {2.2} else {1.2};
                if ((_x distance player) < _detectRange) exitWith {
                    _isUndercover = false;
                };
            } forEach _nearEnemies;

            private _suspFactor = if (_hasEnemyVest && _hasEnemyHelmet) then {1} else {4};
            private _staringUnits = allUnits select {
                alive _x &&
                {side _x == east} &&
                {_x distance player < 15}
            };

            if (count _staringUnits > 0) then {
                private _susp = player getVariable ["MWF_suspicionLevel", 0];
                private _newSusp = _susp + _suspFactor;
                player setVariable ["MWF_suspicionLevel", _newSusp];
                if (_newSusp > 15) then {
                    _isUndercover = false;
                };
            };
        } else {
            if (_hasEnemyVest || _hasEnemyHelmet) then {
                _isUndercover = false;
            } else {
                if (_isCivilian) then {
                    if (currentWeapon player != "" && {currentWeapon player != binocular}) then {
                        _isUndercover = false;
                    } else {
                        private _playerPos = getPosATL player;
                        private _zones = missionNamespace getVariable ["MWF_all_mission_zones", []];
                        private _uncapturedZones = [];

                        {
                            private _zoneRef = _x;

                            if (_zoneRef isEqualType "") then {
                                if (_zoneRef in allMapMarkers) then {
                                    if !(missionNamespace getVariable [format ["MWF_zoneState_%1_MWF_isCaptured", _zoneRef], false]) then {
                                        _uncapturedZones pushBack [getMarkerPos _zoneRef, (getMarkerSize _zoneRef) select 0];
                                    };
                                };
                            } else {
                                if (!isNull _zoneRef && {!(_zoneRef getVariable ["MWF_isCaptured", false])}) then {
                                    _uncapturedZones pushBack [getPosWorld _zoneRef, _zoneRef getVariable ["MWF_zoneRange", 150]];
                                };
                            };
                        } forEach _zones;

                        {
                            _x params ["_zonePos", "_zoneRange"];
                            if ((_playerPos distance2D _zonePos) < (_zoneRange max 150)) exitWith {
                                _isSuspicious = true;
                                _eyeIcon = "media\icons\eye_yellow.paa";
                                if ((_playerPos distance2D _zonePos) < 50) then {
                                    _isUndercover = false;
                                };
                            };
                        } forEach _uncapturedZones;
                    };
                } else {
                    _isUndercover = false;
                };
            };
        };

        if (vehicle player != player && _isUndercover) then {
            private _veh = vehicle player;
            private _cargoItems = (weaponCargo _veh) + (magazineCargo _veh) + (itemCargo _veh);
            private _hasContraband = false;

            {
                private _item = _x;
                if (_item in _contraband) exitWith {
                    _hasContraband = true;
                };

                if ({_item isKindOf _x} count _contrabandCat > 0) exitWith {
                    _hasContraband = true;
                };
            } forEach _cargoItems;

            if (_hasContraband) then {
                _isSuspicious = true;
                _eyeIcon = "media\icons\eye_yellow.paa";

                if (count (allUnits select {
                    alive _x &&
                    {side _x == east} &&
                    {_x distance _veh < 4}
                }) > 0) then {
                    _isUndercover = false;
                };
            };

            private _checkpointGuards = allUnits select {
                alive _x &&
                {side _x == east} &&
                {_x distance player < 25}
            };

            if (count _checkpointGuards > 0 && {speed player < 2}) then {
                private _inspectTime = (player getVariable ["MWF_inspectTimer", 0]) + 1;
                player setVariable ["MWF_inspectTimer", _inspectTime];

                if (_inspectTime > 5) then {
                    player setVariable ["MWF_suspicionLevel", -15];
                    player setVariable ["MWF_inspectTimer", 0];
                };
            };
        };

        if (_isUndercover) then {
            if (!captive player) then {
                [player, true] remoteExec ["setCaptive", 0];
            };

            if (_isSuspicious) then {
                _eyeIcon = "media\icons\eye_yellow.paa";
            };
        } else {
            if (captive player) then {
                [player, false] remoteExec ["setCaptive", 0];
            };

            _eyeIcon = "media\icons\eye_red.paa";
            player setVariable ["MWF_suspicionLevel", 0];
            player setVariable ["MWF_inspectTimer", 0];
        };

        if (!isNull _ctrl) then {
            _ctrl ctrlSetText _eyeIcon;
        };
    };
};

player addEventHandler ["Fired", {
    params ["_unit"];
    _unit setVariable ["MWF_firedRecently", true, true];
    [_unit] spawn {
        params ["_firingUnit"];
        uiSleep 45;
        _firingUnit setVariable ["MWF_firedRecently", false, true];
    };
}];

player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator"];

    if (vehicle _unit != _unit && {_damage > 0.01}) then {
        private _witnesses = allUnits select {
            alive _x &&
            {side _x == east} &&
            {_x distance _unit < 100} &&
            {([_x, "VIEW"] checkVisibility [getPosASL _x, getPosASL _unit]) > 0.6}
        };

        if (count _witnesses > 0) then {
            private _investigator = [_witnesses, _unit] call BIS_fnc_nearestPosition;
            _investigator doMove (getPos _unit);
            player setVariable ["MWF_suspicionLevel", 10];
        };
    };

    _damage
}];

diag_log "[MWF Undercover] Handler initialized for player.";