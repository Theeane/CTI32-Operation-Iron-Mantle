/*
    Client-side open + monitor for Base Build Zeus after server assignment.
*/
if (!hasInterface) exitWith {};

params [
    ["_sessionId", "", [""]],
    ["_maxRange", 500, [0]]
];

if (_sessionId isEqualTo "") exitWith {};
if ((player getVariable ["MWF_BaseArchitect_SessionId", ""]) isNotEqualTo _sessionId) exitWith {};

[_sessionId, _maxRange] spawn {
    params ["_sessionId", "_maxRange"];

    private _timeoutAt = time + 5;
    waitUntil {
        uiSleep 0.05;
        (!isNull (getAssignedCuratorLogic player)) || {time > _timeoutAt}
    };

    private _curator = getAssignedCuratorLogic player;
    if (isNull _curator) exitWith {
        player setVariable ["MWF_BaseArchitect_Active", false, true];
        player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
        player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
        player setVariable ["MWF_BaseArchitect_SessionId", nil, true];
        missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
        systemChat "Base Build failed: curator assignment timed out.";
    };

    missionNamespace setVariable ["MWF_BaseArchitect_Active", true];

    private _openTimeoutAt = time + 4;
    waitUntil {
        if (isNull (findDisplay 312)) then {
            openCuratorInterface;
        };
        uiSleep 0.15;
        (!isNull (findDisplay 312)) || {time > _openTimeoutAt}
    };

    if (isNull (findDisplay 312)) then {
        systemChat "Base Build ready. Press Y if Zeus did not open automatically.";
    };

    [format ["ARCHITECT MODE ACTIVE | Construction Area: %1m radius", _maxRange], "info"] call MWF_fnc_showNotification;

    [_sessionId, _maxRange] spawn {
        params ["_sessionId", "_range"];
        private _lastWarning = -10;

        waitUntil {
            uiSleep 0.5;

            private _curator = getAssignedCuratorLogic player;
            if (isNull _curator) exitWith { true };

            private _anchorPos = player getVariable ["MWF_BaseArchitect_AnchorPos", getPosATL player];
            private _cameraPos = getCuratorCameraPos _curator;
            if ((_cameraPos distance2D _anchorPos) > _range) then {
                _curator setCuratorCameraScene [_anchorPos, [0, 0, 60], 0.5];
                if ((time - _lastWarning) > 3) then {
                    systemChat format ["Construction range exceeded. Zeus camera returned to the %1m build zone.", _range];
                    _lastWarning = time;
                };
            };

            isNull (findDisplay 312)
        };

        [player, _sessionId] remoteExecCall ["MWF_fnc_stopBuildArchitectServer", 2];

        missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
        player setVariable ["MWF_BaseArchitect_Active", false, true];
        player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
        player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
        player setVariable ["MWF_BaseArchitect_SessionId", nil, true];

        cutText ["", "BLACK OUT", 0.25];
        uiSleep 0.25;
        cutText ["", "BLACK IN", 0.25];
    };
};
true
