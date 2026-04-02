params [["_display", displayNull, [displayNull]]];
if (isNull _display) exitWith { false };

private _hideIds = [12210, 12211, 12212, 12213, 12214];
{
    private _ctrl = _display displayCtrl _x;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow false;
        _ctrl ctrlEnable false;
    };
} forEach _hideIds;

private _leftCtrl = _display displayCtrl 12215;
if (!isNull _leftCtrl) then {
    _leftCtrl ctrlSetText "Back";
    _leftCtrl ctrlEnable true;
    _leftCtrl ctrlSetTooltip "Return to terminal.";
};

private _actionCtrl = _display displayCtrl 12207;
if (!isNull _actionCtrl) then {
    _actionCtrl ctrlSetTooltip "Redeploy to the selected FOB or base.";
};

true
