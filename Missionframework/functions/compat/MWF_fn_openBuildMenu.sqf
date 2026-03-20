/*
    Author: Theane / ChatGPT
    Function: MWF_fn_openBuildMenu
    Project: Military War Framework

    Description:
    Compatibility wrapper for legacy FOB logistics routes.
    Opens the current logistics procurement dialog instead of redirecting to Base Architect.
*/

if (!hasInterface) exitWith {};

params [["_terminal", objNull, [objNull]]];

if (dialog) then {
    closeDialog 0;
};

private _opened = createDialog "MWF_BuildMenu";
if (!_opened) then {
    [["LOGISTICS MENU UNAVAILABLE", "Could not open the logistics procurement dialog."], "warning"] call MWF_fnc_showNotification;
};
