/*
    Author: OpenAI
    Function: MWF_fn_undercoverHandler
    Project: Military War Framework

    Description:
    Uniform-driven undercover runtime.
    - OPFOR uniforms provide military disguise everywhere.
    - Civilian uniforms provide civilian disguise only when unarmed and without vest.
    - Military disguise uses short-range inspection, with leaders inspecting further.
*/

if (!hasInterface) exitWith {};
if (missionNamespace getVariable ["MWF_UndercoverHandlerStarted", false]) exitWith {};
missionNamespace setVariable ["MWF_UndercoverHandlerStarted", true];

[] call MWF_fnc_buildLoadoutCaches;

cutRsc ["MWF_Undercover_Eye", "PLAIN"];

[] spawn {
    private _ctrl = controlNull;

    while {true} do {
        waitUntil { !isNull player };
        uiSleep 1;

        if (isNull _ctrl) then {
            _ctrl = uiNamespace getVariable ["MWF_ctrl_eye", controlNull];
        };

        [] call MWF_fnc_checkUndercover;

        private _opforUniforms = missionNamespace getVariable ["MWF_OpforUniformClasses", []];
        private _civilianUniforms = missionNamespace getVariable ["MWF_CivilianUniformClasses", []];
        private _uniform = uniform player;
        private _isOpfor = _uniform in _opforUniforms;
        private _isCivilian = _uniform in _civilianUniforms;
        private _hasVest = (vest player) != "";
        private _armed = (primaryWeapon player) != "" || {(handgunWeapon player) != ""} || {(secondaryWeapon player) != ""};

        private _isUndercover = false;
        private _isSuspicious = false;
        private _eyeIcon = "media\icons\eye_red.paa";

        if (_isOpfor) then {
            _isUndercover = true;
            _eyeIcon = "media\icons\eye_green.paa";

            private _nearEnemies = allUnits select {
                alive _x &&
                {side _x == east} &&
                {_x distance player <= 8}
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
                };
            } forEach _nearEnemies;

            private _inspectionTime = player getVariable ["MWF_InspectionExposure", 0];
            if (_inspectionActive && {_isUndercover}) then {
                _inspectionTime = _inspectionTime + 1;
                player setVariable ["MWF_InspectionExposure", _inspectionTime];
                if (_inspectionTime >= 10) then {
                    _isUndercover = false;
                };
            } else {
                player setVariable ["MWF_InspectionExposure", 0 max (_inspectionTime - 2)];
            };
        } else {
            player setVariable ["MWF_InspectionExposure", 0];
            if (_isCivilian && {!_hasVest} && {!_armed}) then {
                _isUndercover = true;
                _eyeIcon = "media\icons\eye_green.paa";
            };
        };

        if (_isUndercover && {_isSuspicious}) then {
            _eyeIcon = "media\icons\eye_yellow.paa";
        };

        player setVariable ["MWF_isUndercover", _isUndercover, true];

        if (_isUndercover) then {
            if (!captive player) then {
                [player, true] remoteExec ["setCaptive", 0];
            };
        } else {
            if (captive player) then {
                [player, false] remoteExec ["setCaptive", 0];
            };
        };

        if (!isNull _ctrl) then {
            _ctrl ctrlSetText _eyeIcon;
        };
    };
};
