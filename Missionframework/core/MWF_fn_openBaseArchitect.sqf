/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBaseArchitect
    Project: Military War Framework

    Description:
    Opens the live baseline local Zeus construction session around the active FOB/MOB anchor.
    Auto-open stays local like baseline. Close is hardened so unloading Zeus tears down the
    curator session immediately instead of leaving a stale curator that can be reopened with Y.
*/

if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]]];

if (!isNull (getAssignedCuratorLogic player)) exitWith {
    systemChat "Base Architect is already active.";
};

private _anchorPos = if (!isNull _terminal) then {
    getPosATL _terminal
} else {
    private _mainBase = missionNamespace getVariable ["MWF_MainBase", objNull];
    if (!isNull _mainBase) then { getPosATL _mainBase } else { getPosATL player };
};

private _maxRange = 500;
private _sessionId = format ["%1:%2:%3", getPlayerUID player, diag_tickTime, floor (random 1000000)];

player setVariable ["MWF_BaseArchitect_AnchorPos", _anchorPos, true];
player setVariable ["MWF_BaseArchitect_MaxRange", _maxRange, true];
player setVariable ["MWF_BaseArchitect_SessionId", _sessionId, true];
player setVariable ["MWF_BaseArchitect_Active", true, true];
player setVariable ["MWF_BaseArchitect_CloseRequested", false];
player setVariable ["MWF_BaseArchitect_CleanupDone", false];

private _group = createGroup [sideLogic, true];
private _curator = _group createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];
if (isNull _curator) exitWith {
    missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
    player setVariable ["MWF_BaseArchitect_Active", false, true];
    player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
    player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
    player setVariable ["MWF_BaseArchitect_SessionId", nil, true];
    player setVariable ["MWF_BaseArchitect_CloseRequested", nil];
    player setVariable ["MWF_BaseArchitect_CleanupDone", nil];
    systemChat "Base Architect failed: curator creation failed.";
};

_curator setVariable ["MWF_BaseArchitect_SessionId", _sessionId, false];
_curator setVariable ["MWF_BaseArchitect_OwnerUID", getPlayerUID player, false];
player setVariable ["MWF_BaseArchitect_LocalCurator", _curator];
player setVariable ["MWF_BaseArchitect_LocalGroup", _group];
uiNamespace setVariable ["MWF_BaseArchitect_ActiveSessionId", _sessionId];

player assignCurator _curator;
[_curator] call MWF_fnc_limitZeusAssets;

_curator addEventHandler ["CuratorObjectPlaced", {
    params ["_curatorModule", "_entity"];
    if (isNull _entity) exitWith {};
    private _sessionId = player getVariable ["MWF_BaseArchitect_SessionId", ""];
    [_entity, player, _sessionId, "PLACE"] remoteExec ["MWF_fnc_handleBuildPlacement", 2];
}];

missionNamespace setVariable ["MWF_BaseArchitect_Active", true];
openCuratorInterface;
[format ["ARCHITECT MODE ACTIVE | Construction Area: %1m radius", _maxRange], "info"] call MWF_fnc_showNotification;

[_sessionId, _curator, _group, _anchorPos, _maxRange] spawn {
    params ["_sessionId", "_curator", "_group", "_anchorPos", "_range"];

    private _lastWarning = -10;
    private _displayOpenDeadline = time + 5;
    private _displayUnloadHooked = false;

    private _runCleanup = {
        if (player getVariable ["MWF_BaseArchitect_CleanupDone", false]) exitWith {};

        player setVariable ["MWF_BaseArchitect_CleanupDone", true];

        private _display = findDisplay 312;
        if (!isNull _display) then {
            _display closeDisplay 2;
            uiSleep 0.01;
        };

        private _localCurator = player getVariable ["MWF_BaseArchitect_LocalCurator", objNull];
        private _localGroup = player getVariable ["MWF_BaseArchitect_LocalGroup", grpNull];

        if (!isNull _localCurator) then {
            unassignCurator _localCurator;
            deleteVehicle _localCurator;
        };

        if (!isNull _localGroup) then {
            deleteGroup _localGroup;
        };

        missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
        player setVariable ["MWF_BaseArchitect_Active", false, true];
        player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
        player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
        player setVariable ["MWF_BaseArchitect_SessionId", nil, true];
        player setVariable ["MWF_BaseArchitect_LocalCurator", objNull];
        player setVariable ["MWF_BaseArchitect_LocalGroup", grpNull];
        player setVariable ["MWF_BaseArchitect_CloseRequested", true];
        uiNamespace setVariable ["MWF_BaseArchitect_ActiveSessionId", nil];

        if (hasInterface) then {
            cutText ["", "BLACK OUT", 0.15];
            uiSleep 0.15;
            cutText ["", "BLACK IN", 0.15];
        };
    };

    waitUntil {
        uiSleep 0.05;

        if ((player getVariable ["MWF_BaseArchitect_SessionId", ""]) isNotEqualTo _sessionId) exitWith { true };
        if (player getVariable ["MWF_BaseArchitect_CloseRequested", false]) exitWith { true };
        if (!alive player) exitWith { true };
        if (isNull _curator) exitWith { true };

        private _display = findDisplay 312;
        if (isNull _display) then {
            if (time > _displayOpenDeadline) exitWith { true };
            false
        } else {
            if (!_displayUnloadHooked) then {
                _displayUnloadHooked = true;
                _display displayAddEventHandler ["Unload", {
                    [] spawn {
                        if (player getVariable ["MWF_BaseArchitect_CleanupDone", false]) exitWith {};

                        player setVariable ["MWF_BaseArchitect_CloseRequested", true];
                        player setVariable ["MWF_BaseArchitect_CleanupDone", true];

                        private _localCurator = player getVariable ["MWF_BaseArchitect_LocalCurator", objNull];
                        private _localGroup = player getVariable ["MWF_BaseArchitect_LocalGroup", grpNull];

                        if (!isNull _localCurator) then {
                            unassignCurator _localCurator;
                            deleteVehicle _localCurator;
                        };

                        if (!isNull _localGroup) then {
                            deleteGroup _localGroup;
                        };

                        missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
                        player setVariable ["MWF_BaseArchitect_Active", false, true];
                        player setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
                        player setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
                        player setVariable ["MWF_BaseArchitect_SessionId", nil, true];
                        player setVariable ["MWF_BaseArchitect_LocalCurator", objNull];
                        player setVariable ["MWF_BaseArchitect_LocalGroup", grpNull];
                        player setVariable ["MWF_BaseArchitect_CloseRequested", true];
                        uiNamespace setVariable ["MWF_BaseArchitect_ActiveSessionId", nil];

                        cutText ["", "BLACK OUT", 0.15];
                        uiSleep 0.15;
                        cutText ["", "BLACK IN", 0.15];
                    };
                }];
            };

            private _cameraPos = getCuratorCameraPos _curator;
            if ((_cameraPos distance2D _anchorPos) > _range) then {
                _curator setCuratorCameraScene [_anchorPos, [0, 0, 60], 0.5];
                if ((time - _lastWarning) > 3) then {
                    systemChat format ["Construction range exceeded. Zeus camera returned to the %1m build zone.", _range];
                    _lastWarning = time;
                };
            };

            false
        };
    };

    call _runCleanup;
};
