if (!hasInterface) exitWith { false };

private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };

{
    private _ctrl = _display displayCtrl _x;
    if (!isNull _ctrl) then {
        ctrlDelete _ctrl;
    };
} forEach (uiNamespace getVariable ["MWF_VehicleMenu_DynamicCtrls", []]);
uiNamespace setVariable ["MWF_VehicleMenu_DynamicCtrls", []];
uiNamespace setVariable ["MWF_VehicleMenu_RowCtrls", []];
uiNamespace setVariable ["MWF_VehicleMenu_Catalog", nil];
uiNamespace setVariable ["MWF_VehicleMenu_CurrentEntries", []];
uiNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", -1];
uiNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", nil];

private _mapFrame = _display displayCtrl 12204;
private _mapCtrl = _display displayCtrl 12205;
if (!isNull _mapFrame) then { _mapFrame ctrlShow true; };
if (!isNull _mapCtrl) then { _mapCtrl ctrlShow true; };

private _statusCtrl = _display displayCtrl 12206;
private _infoCtrl = _display displayCtrl 12216;
if (!isNull _statusCtrl) then { _statusCtrl ctrlShow true; };
if (!isNull _infoCtrl) then { _infoCtrl ctrlShow true; };

private _buttonDefs = [
    [12210, "Vehicle Menu", "['SET_MODE','VEHICLE_MENU'] call MWF_fnc_dataHub;", "Open vehicle menu."],
    [12211, "Base Building", "['SET_MODE','BUILD_MENU'] call MWF_fnc_dataHub;", "Base building."],
    [12212, "Main Operations", "['SET_MODE','MAIN_OPERATIONS'] call MWF_fnc_dataHub;", "Main operations."],
    [12213, "Build Support", "['SET_MODE','SUPPORT'] call MWF_fnc_dataHub;", "Build support."],
    [12214, "Base Upgrades", "['SET_MODE','UPGRADES'] call MWF_fnc_dataHub;", "Base upgrades."]
];

{
    _x params ["_idc", "_text", "_action", "_tooltip"];
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlSetText _text;
        buttonSetAction [_ctrl, _action];
        _ctrl ctrlSetTooltip _tooltip;
        _ctrl ctrlEnable true;
    };
} forEach _buttonDefs;

true
