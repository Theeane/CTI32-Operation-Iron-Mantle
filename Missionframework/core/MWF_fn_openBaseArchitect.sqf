/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBaseArchitect
    Project: Military War Framework

    Description:
    Opens a restricted local Zeus construction session around the active FOB/MOB anchor.
    The curator camera is range-limited and each placed asset is server-validated for
    allowed class and dynamic supply cost.
*/

if (!hasInterface) exitWith {};

params [
    ["_terminal", objNull, [objNull]],
    ["_forcedAnchorPos", [], [[]]]
];

if (!isNull (getAssignedCuratorLogic player)) exitWith {
    systemChat "Base Architect is already active.";
};

private _anchorPos = if (_forcedAnchorPos isEqualType [] && {count _forcedAnchorPos >= 2}) then {
    +_forcedAnchorPos
} else {
    if (!isNull _terminal) then {
        getPosATL _terminal
    } else {
        private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
        if (!isNull _mainBase) then { getPosATL _mainBase } else { getPosATL player };
    }
};
if (_anchorPos isEqualTo [] || {_anchorPos isEqualTo [0,0,0]}) then {
    _anchorPos = getPosATL player;
};

private _maxRange = 500;
private _sessionId = format ["%1:%2:%3", getPlayerUID player, diag_tickTime, floor (random 1000000)];
player setVariable ["MWF_BaseArchitect_AnchorPos", _anchorPos, true];
player setVariable ["MWF_BaseArchitect_MaxRange", _maxRange, true];
player setVariable ["MWF_BaseArchitect_SessionId", _sessionId, true];
player setVariable ["MWF_BaseArchitect_Active", true, true];

private _group = createGroup [sideLogic, true];
private _curator = _group createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];

player assignCurator _curator;
[_curator] call MWF_fnc_limitZeusAssets;

_curator addEventHandler ["CuratorObjectPlaced", {
    params ["_curatorModule", "_entity"];
    if (isNull _entity) exitWith {};
    private _sessionId = player getVariable ["MWF_BaseArchitect_SessionId", ""];
    [_entity, player, _sessionId, "PLACE"] remoteExec ["MWF_fnc_handleBuildPlacement", 2];
}];

missionNamespace setVariable ["MWF_BaseArchitect_Active", true];

[_curator] spawn {
    params ["_curator"];
    private _opened = false;
    private _deadline = diag_tickTime + 8;

    waitUntil {
        uiSleep 0.05;
        ((getAssignedCuratorLogic player) isEqualTo _curator) || {diag_tickTime > _deadline}
    };

    if (!((getAssignedCuratorLogic player) isEqualTo _curator)) exitWith {
        systemChat "Base Build failed to assign curator.";
    };

    /* Keep trying until the Zeus display exists. */
    private _tries = 0;
    while {isNull (findDisplay 312) && {_tries < 80}} do {
        openCuratorInterface;
        uiSleep 0.1;
        _tries = _tries + 1;
    };

    _opened = !isNull (findDisplay 312);
    if (!_opened) then {
        systemChat "Base Build ready. Press Y if Zeus did not open automatically.";
    } else {
        /* Prune the Zeus UI repeatedly for a short window because tree controls populate progressively. */
        [] spawn {
            private _sanitizeDeadline = time + 6;
            waitUntil {
                uiSleep 0.05;
                !isNull (findDisplay 312) || {time > _sanitizeDeadline}
            };

            while {!isNull (findDisplay 312) && {time < _sanitizeDeadline}} do {
                [findDisplay 312] call MWF_fnc_sanitizeBuildCuratorDisplay;
                uiSleep 0.2;
            };
        };
    };
};

[format ["ARCHITECT MODE ACTIVE | Construction Area: %1m radius", _maxRange], "info"] call MWF_fnc_showNotification;

[_curator, _group, _anchorPos, _maxRange] spawn {
    params ["_curator", "_group", "_anchorPos", "_range"];
    private _lastWarning = -10;

    waitUntil {
        uiSleep 0.5;

        if (isNull _curator) exitWith { true };

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

    if (!isNull _curator) then {
        unassignCurator _curator;
        deleteVehicle _curator;
    };
    if (!isNull _group) then {
        deleteGroup _group;
    };
    missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
    player setVariable ["MWF_BaseArchitect_Active", false, true];
    player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
    player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
    player setVariable ["MWF_BaseArchitect_SessionId", nil, true];
    if (hasInterface) then {
        cutText ["", "BLACK OUT", 0.25];
        uiSleep 0.25;
        cutText ["", "BLACK IN", 0.25];
    };
};
