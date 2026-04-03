if (!hasInterface) exitWith { false };
uiNamespace setVariable ["MWF_Redeploy_Active", false];
uiNamespace setVariable ["MWF_Redeploy_Selected", []];
{ deleteMarkerLocal _x; } forEach (uiNamespace getVariable ["MWF_Redeploy_Markers", []]);
uiNamespace setVariable ["MWF_Redeploy_Markers", []];
private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };
private _leftCtrl = _display displayCtrl 12215;
private _actionCtrl = _display displayCtrl 12207;
if (!isNull _leftCtrl) then { _leftCtrl buttonSetAction "['ACTION_SECONDARY'] call MWF_fnc_dataHub;"; };
if (!isNull _actionCtrl) then { _actionCtrl buttonSetAction "['ACTION'] call MWF_fnc_dataHub;"; };
private _setShow = {
    params ["_idc", "_show"];
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow _show;
        _ctrl ctrlEnable _show;
    };
};
{ [_x, true] call _setShow; } forEach [12210,12211,12212,12213,12214,12230,12231,12232,12233,12234,12208,12209,12235,12236,12237,12238];
["SET_MODE", uiNamespace getVariable ["MWF_Redeploy_ReturnMode", "UPGRADES"]] call MWF_fnc_dataHub;
true
