/*
    Server-side cleanup for Base Build Zeus.
    This is the authoritative hard teardown used when build mode closes.
*/
if (!isServer) exitWith {};

params [
    ["_builder", objNull, [objNull]],
    ["_sessionId", "", [""]]
];

if (isNull _builder) exitWith {};

private _curator = getAssignedCuratorLogic _builder;
if (isNull _curator && !(_sessionId isEqualTo "")) then {
    {
        if (!isNull _x) then {
            private _curatorSession = _x getVariable ["MWF_BaseArchitect_SessionId", ""];
            private _owner = _x getVariable ["MWF_BaseArchitect_Owner", objNull];
            if ((_curatorSession isEqualTo _sessionId) && {_owner isEqualTo _builder}) exitWith {
                _curator = _x;
            };
        };
    } forEach allCurators;
};

if (!isNull _curator) then {
    private _curatorSession = _curator getVariable ["MWF_BaseArchitect_SessionId", ""];
    if (_sessionId isEqualTo "" || {_curatorSession isEqualTo ""} || {_curatorSession isEqualTo _sessionId}) then {
        private _group = group _curator;
        removeAllCuratorEditableObjects _curator;
        removeAllCuratorAddons _curator;
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
