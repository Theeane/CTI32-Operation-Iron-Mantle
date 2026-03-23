/*
    Author: OpenAI
    Function: MWF_fn_undercoverHandler
    Project: Military War Framework

    Description:
    Uniform-driven undercover runtime.
    Drives undercover state and eye-state only; HUD rendering is handled by MWF_fnc_updateResourceUI.
*/

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["MWF_UndercoverHandlerStarted", false]) exitWith {};
missionNamespace setVariable ["MWF_UndercoverHandlerStarted", true];

[] call MWF_fnc_buildLoadoutCaches;

[] spawn {
    while {true} do {
        waitUntil { !isNull player };
        uiSleep 1;

        [player] call MWF_fnc_checkUndercover;

        private _undercoverState = player getVariable ["MWF_UndercoverState", "NONE"];
        private _isUndercover = player getVariable ["MWF_isUndercover", false];
        private _isSuspicious = false;
        private _eyeState = "RED";

        if (_undercoverState isEqualTo "OPFOR") then {
            _eyeState = "GREEN";

            private _nearEnemies = allUnits select {
                alive _x && {side _x == east} && {_x distance player <= 8}
            };

            private _inspectionActive = false;
            {
                private _observer = _x;
                private _isLeader = (leader (group _observer) == _observer) || {rankId _observer >= 4};
                private _suspiciousRange = if (_isLeader) then {5} else {2};
                private _detectRange = if (_isLeader) then {3} else {1};
                private _dist = _observer distance player;

                if (_dist <= _suspiciousRange) then {
                    _inspectionActive = true;
                    _isSuspicious = true;
                    _observer doWatch player;
                    _observer doMove (getPosATL player);
                };

                if (_dist <= _detectRange) exitWith {
                    _isUndercover = false;
                    missionNamespace setVariable ["MWF_Op_Detected", true, true];
                    player setVariable ["MWF_OpforDisguiseCompromised", true, true];
                };
            } forEach _nearEnemies;

            private _inspectionTime = player getVariable ["MWF_InspectionExposure", 0];
            if (_inspectionActive && {_isUndercover}) then {
                _inspectionTime = _inspectionTime + 1;
                player setVariable ["MWF_InspectionExposure", _inspectionTime];
                if (_inspectionTime >= 10) then {
                    _isUndercover = false;
                    missionNamespace setVariable ["MWF_Op_Detected", true, true];
                    player setVariable ["MWF_OpforDisguiseCompromised", true, true];
                };
            } else {
                player setVariable ["MWF_InspectionExposure", 0 max (_inspectionTime - 2)];
            };
        } else {
            player setVariable ["MWF_InspectionExposure", 0];
            if (_undercoverState isEqualTo "CIV") then {
                _eyeState = "GREEN";
            };
        };

        if (_isUndercover && {_isSuspicious}) then {
            _eyeState = "YELLOW";
        };

        player setVariable ["MWF_isUndercover", _isUndercover, true];
        player setVariable ["MWF_UndercoverEyeState", _eyeState];

        if (_isUndercover) then {
            if (!captive player) then {
                [player, true] remoteExec ["setCaptive", 0];
            };
        } else {
            if (captive player) then {
                [player, false] remoteExec ["setCaptive", 0];
            };
        };
    };
};
