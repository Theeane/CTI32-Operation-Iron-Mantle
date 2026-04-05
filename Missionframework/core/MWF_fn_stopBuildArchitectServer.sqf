/*
    Server-side cleanup for Base Build Zeus.
*/
if (!isServer) exitWith {};

params [
    ["_builder", objNull, [objNull]],
    ["_sessionId", "", [""]]
];

if (isNull _builder) exitWith {};

private _curator = getAssignedCuratorLogic _builder;
if (!isNull _curator) then {
    private _curatorSession = _curator getVariable ["MWF_BaseArchitect_SessionId", ""];
    if (_sessionId isEqualTo "" || {_curatorSession isEqualTo ""} || {_curatorSession isEqualTo _sessionId}) then {
        private _group = group _curator;
        unassignCurator _curator;
        deleteVehicle _curator;
        if (!isNull _group) then {
            deleteGroup _group;
        };
    };
};

_builder setVariable ["MWF_BaseArchitect_Active", false, true];
_builder setVariable ["MWF_BaseArchitect_AnchorPos", nil, true];
_builder setVariable ["MWF_BaseArchitect_MaxRange", nil, true];
_builder setVariable ["MWF_BaseArchitect_SessionId", nil, true];
missionNamespace setVariable ["MWF_BaseArchitect_Active", false];
true
