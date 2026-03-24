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

        private _undercoverState = player getVariable ["MWF_UndercoverState", player getVariable ["MWF_UndercoverBaseState", "NONE"]];
        private _isUndercover = player getVariable ["MWF_isUndercover", false];
        private _isSuspicious = false;
        private _eyeState = "OFF";
        private _redHoldSeconds = missionNamespace getVariable ["MWF_UndercoverRedDecaySeconds", 45];
        private _redUntil = player getVariable ["MWF_UndercoverRedUntil", 0];
        private _redActive = _redUntil > diag_tickTime;

        if (_undercoverState isEqualTo "OPFOR") then {
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
                    _redUntil = diag_tickTime + _redHoldSeconds;
                    _redActive = true;
                    _isUndercover = false;
                    missionNamespace setVariable ["MWF_Op_Detected", true, true];
                };
            } forEach _nearEnemies;

            private _inspectionTime = player getVariable ["MWF_InspectionExposure", 0];
            if (_inspectionActive && {!_redActive}) then {
                _inspectionTime = _inspectionTime + 1;
                player setVariable ["MWF_InspectionExposure", _inspectionTime];
                if (_inspectionTime >= 10) then {
                    _redUntil = diag_tickTime + _redHoldSeconds;
                    _redActive = true;
                    _isUndercover = false;
                    missionNamespace setVariable ["MWF_Op_Detected", true, true];
                };
            } else {
                player setVariable ["MWF_InspectionExposure", 0 max (_inspectionTime - 2)];
            };
        } else {
            player setVariable ["MWF_InspectionExposure", 0];
        };

        if (_redActive) then {
            private _activeHostileSeen = false;
            {
                if (alive _x && {side _x == east} && {_x distance player <= 60}) then {
                    private _targetPos = eyePos player;
                    private _observerPos = eyePos _x;
                    private _visibility = [_x, "VIEW"] checkVisibility [_observerPos, _targetPos];
                    if (_visibility > 0.05 || {lineIntersectsSurfaces [_observerPos, _targetPos, _x, player] isEqualTo []}) exitWith {
                        _activeHostileSeen = true;
                    };
                };
            } forEach allUnits;

            if (_activeHostileSeen) then {
                _redUntil = diag_tickTime + 5;
            };
            _eyeState = "RED";
            _isUndercover = false;
        } else {
            switch (_undercoverState) do {
                case "OPFOR": {
                    _eyeState = if (_isSuspicious) then {"YELLOW"} else {"GREEN"};
                    _isUndercover = true;
                };
                case "CIV": {
                    _eyeState = "GREEN";
                    _isUndercover = true;
                };
                default {
                    _eyeState = "OFF";
                    _isUndercover = false;
                };
            };
        };

        player setVariable ["MWF_UndercoverRedUntil", _redUntil, true];
        player setVariable ["MWF_isUndercover", _isUndercover, true];
        player setVariable ["MWF_UndercoverEyeState", _eyeState, true];

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
