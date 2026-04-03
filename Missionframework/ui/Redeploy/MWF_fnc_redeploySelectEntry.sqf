if (!hasInterface) exitWith { false };
params [["_mouseX", 0, [0]], ["_mouseY", 0, [0]]];
if !(uiNamespace getVariable ["MWF_Redeploy_Active", false]) exitWith { false };
private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };
private _mapCtrl = _display displayCtrl 12205;
if (isNull _mapCtrl) exitWith { false };
private _worldPos = _mapCtrl ctrlMapScreenToWorld [_mouseX, _mouseY];
private _entries = uiNamespace getVariable ["MWF_Redeploy_Entries", []];
private _nearest = [];
private _bestDistance = 1e10;
{
    private _pos = _x param [2, [0,0,0], [[]]];
    private _dist = _worldPos distance2D _pos;
    if (_dist < _bestDistance) then { _bestDistance = _dist; _nearest = _x; };
} forEach _entries;
if (_nearest isEqualTo [] || {_bestDistance > 100}) exitWith { false };
uiNamespace setVariable ["MWF_Redeploy_Selected", _nearest];
private _actionCtrl = _display displayCtrl 12207;
if (!isNull _actionCtrl) then { _actionCtrl ctrlEnable true; };
private _statusCtrl = _display displayCtrl 12206;
private _infoCtrl = _display displayCtrl 12216;
private _label = _nearest param [1, "Unknown", [""]];
private _kind = _nearest param [0, "FOB", [""]];
if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText format ["Redeploy Target: %1 | Ready", _label]; };
if (!isNull _infoCtrl) then { _infoCtrl ctrlSetStructuredText parseText format ["<t size='1.05' color='#111111'>%1</t><br/><t color='#222222'>Type: %2</t><br/><t color='#222222'>Press Redeploy to travel.</t>", _label, _kind]; };
true
