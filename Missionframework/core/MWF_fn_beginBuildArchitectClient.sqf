/*
    Client-side open + monitor for Base Build Zeus after server assignment.
    Build Mode must auto-open from the terminal flow, never from a manual Y fallback.
    Closing with Y must request a hard server teardown so the curator cannot reopen.
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

    private _clearLocalState = {
        missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
        player setVariable ["MWF_BaseArchitect_Active", false, true];
        player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
        player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
        player setVariable ["MWF_BaseArchitect_SessionId", nil, true];
        player setVariable ["MWF_BaseArchitect_StopRequested", nil];
        player setVariable ["MWF_BaseArchitect_ClosingSessionId", nil];
    };

    private _requestHardStop = {
        if ((player getVariable ["MWF_BaseArchitect_StopRequested", false])) exitWith {};
        player setVariable ["MWF_BaseArchitect_StopRequested", true];
        player setVariable ["MWF_BaseArchitect_ClosingSessionId", _sessionId];
        [player, _sessionId] remoteExecCall ["MWF_fnc_stopBuildArchitectServer", 2];
    };

    private _assignTimeoutAt = time + 10;
    waitUntil {
        uiSleep 0.05;
        (!isNull (getAssignedCuratorLogic player)) || {time > _assignTimeoutAt}
    };

    private _curator = getAssignedCuratorLogic player;
    if (isNull _curator) exitWith {
        call _clearLocalState;
        systemChat "Base Build failed: curator assignment timed out.";
    };

    missionNamespace setVariable ["MWF_BaseArchitect_Active", true];

    private _display = displayNull;
    private _openTimeoutAt = time + 4;
    uiSleep 0.15;

    while {time <= _openTimeoutAt} do {
        if ((player getVariable ["MWF_BaseArchitect_SessionId", ""]) isNotEqualTo _sessionId) exitWith {};

        _display = findDisplay 312;
        if (!isNull _display) exitWith {};

        openCuratorInterface;
        uiSleep 0.1;
    };

    _display = findDisplay 312;
    if (isNull _display) exitWith {
        call _requestHardStop;

        private _cleanupTimeoutAt = time + 2;
        waitUntil {
            uiSleep 0.05;
            isNull (getAssignedCuratorLogic player) || {time > _cleanupTimeoutAt}
        };

        call _clearLocalState;
        systemChat "Base Build failed: curator interface did not open automatically.";
    };

    [_display] call MWF_fnc_sanitizeBuildCuratorDisplay;
    _display displayAddEventHandler ["Unload", {
        private _sessionId = player getVariable ["MWF_BaseArchitect_ClosingSessionId", ""];
        if (_sessionId isEqualTo "") exitWith {};
        if (player getVariable ["MWF_BaseArchitect_StopRequested", false]) exitWith {};
        player setVariable ["MWF_BaseArchitect_StopRequested", true];
        [player, _sessionId] remoteExecCall ["MWF_fnc_stopBuildArchitectServer", 2];
    }];

    [format ["ARCHITECT MODE ACTIVE | Construction Area: %1m radius", _maxRange], "info"] call MWF_fnc_showNotification;

    waitUntil {
        uiSleep 0.1;

        private _curator = getAssignedCuratorLogic player;
        if (isNull _curator) exitWith { true };

        private _anchorPos = player getVariable ["MWF_BaseArchitect_AnchorPos", getPosATL player];
        private _cameraPos = getCuratorCameraPos _curator;
        if ((_cameraPos distance2D _anchorPos) > _maxRange) then {
            _curator setCuratorCameraScene [_anchorPos, [0, 0, 60], 0.5];
            if (isNil "MWF_BaseArchitect_LastRangeWarning" || {(time - MWF_BaseArchitect_LastRangeWarning) > 3}) then {
                systemChat format ["Construction range exceeded. Zeus camera returned to the %1m build zone.", _maxRange];
                MWF_BaseArchitect_LastRangeWarning = time;
            };
        };

        if (player getVariable ["MWF_BaseArchitect_StopRequested", false]) then {
            private _curatorDisplay = findDisplay 312;
            if (!isNull _curatorDisplay) then {
                _curatorDisplay closeDisplay 2;
            };
        };

        isNull (findDisplay 312) || {player getVariable ["MWF_BaseArchitect_StopRequested", false]}
    };

    call _requestHardStop;

    private _cleanupTimeoutAt = time + 2;
    waitUntil {
        uiSleep 0.05;
        isNull (getAssignedCuratorLogic player) || {time > _cleanupTimeoutAt}
    };

    call _clearLocalState;

    cutText ["", "BLACK OUT", 0.25];
    uiSleep 0.25;
    cutText ["", "BLACK IN", 0.25];
};
true
