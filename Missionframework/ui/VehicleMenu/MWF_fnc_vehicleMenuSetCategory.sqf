params [["_category", "LIGHT", [""]]];

private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };
if !((uiNamespace getVariable ["MWF_DataHub_Mode", ""]) isEqualTo "VEHICLE_MENU") exitWith { false };

uiNamespace setVariable ["MWF_VehicleMenu_CurrentCategory", toUpper _category];
uiNamespace setVariable ["MWF_VehicleMenu_SelectedIndex", -1];
[_display] call MWF_fnc_vehicleMenuRefresh;
true
