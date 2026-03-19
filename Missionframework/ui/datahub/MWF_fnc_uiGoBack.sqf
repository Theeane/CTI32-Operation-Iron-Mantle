private _stack = uiNamespace getVariable ["MWF_DataHub_ViewStack", []];
if (_stack isEqualTo []) exitWith { false };
private _last = _stack deleteAt ((count _stack) - 1);
uiNamespace setVariable ["MWF_DataHub_ViewStack", _stack];
["SET_MODE", _last] call MWF_fnc_dataHub;
true
