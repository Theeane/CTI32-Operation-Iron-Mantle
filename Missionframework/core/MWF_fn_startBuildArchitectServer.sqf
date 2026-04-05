/*
    Server-side curator creation for Base Build Zeus.
*/
if (!isServer) exitWith {};

params [
    ["_builder", objNull, [objNull]],
    ["_anchorPos", [], [[]]],
    ["_maxRange", 500, [0]],
    ["_sessionId", "", [""]]
];

if (isNull _builder) exitWith {};
if (!isPlayer _builder) exitWith {};
if (_sessionId isEqualTo "") exitWith {};

private _existing = getAssignedCuratorLogic _builder;
if (!isNull _existing) exitWith {
    ["Base Build unavailable: curator already assigned."] remoteExec ["systemChat", owner _builder];
};

private _group = createGroup [sideLogic, true];
private _curator = _group createUnit ["ModuleCurator_F", [0, 0, 0], [], 0, "NONE"];
if (isNull _curator) exitWith {
    if (!isNull _group) then {
        deleteGroup _group;
    };
    ["Base Build failed: curator creation failed."] remoteExec ["systemChat", owner _builder];
};

_curator setVariable ["MWF_BaseArchitect_SessionId", _sessionId, false];
_curator setVariable ["MWF_BaseArchitect_Owner", _builder, false];
_curator setVariable ["MWF_BaseArchitect_AnchorPos", +_anchorPos, false];
_curator setVariable ["MWF_BaseArchitect_MaxRange", _maxRange, false];

_builder assignCurator _curator;
[_curator] call MWF_fnc_limitZeusAssets;

_curator addEventHandler ["CuratorObjectPlaced", {
    params ["_curatorModule", "_entity"];
    if (isNull _entity) exitWith {};

    private _owner = getAssignedCuratorUnit _curatorModule;
    if (isNull _owner) then {
        _owner = _curatorModule getVariable ["MWF_BaseArchitect_Owner", objNull];
    };
    if (isNull _owner) exitWith {};

    private _sessionId = _owner getVariable ["MWF_BaseArchitect_SessionId", ""];
    [_entity, _owner, _sessionId, "PLACE"] call MWF_fnc_handleBuildPlacement;
}];

[_sessionId, _maxRange] remoteExecCall ["MWF_fnc_beginBuildArchitectClient", owner _builder];
true
