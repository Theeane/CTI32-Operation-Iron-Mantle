/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_openGuide
    Project: Military War Framework

    Description:
    Opens the in-terminal MWF Guide and swaps between topic pages.
*/

params [
    ["_mode", "OPEN", [""]],
    ["_payload", "START", [""]]
];

private _modeUpper = toUpper _mode;

private _pages = [
    ["START", 12310, "STR_MWF_GUIDE_TOPIC_START", "STR_MWF_GUIDE_BODY_START"],
    ["UNDERCOVER", 12311, "STR_MWF_GUIDE_TOPIC_UNDERCOVER", "STR_MWF_GUIDE_BODY_UNDERCOVER"],
    ["THREAT", 12312, "STR_MWF_GUIDE_TOPIC_THREAT", "STR_MWF_GUIDE_BODY_THREAT"],
    ["WORLD_TIER", 12313, "STR_MWF_GUIDE_TOPIC_TIER", "STR_MWF_GUIDE_BODY_TIER"],
    ["ZONES", 12314, "STR_MWF_GUIDE_TOPIC_ZONES", "STR_MWF_GUIDE_BODY_ZONES"],
    ["SUPPLY", 12315, "STR_MWF_GUIDE_TOPIC_SUPPLY", "STR_MWF_GUIDE_BODY_SUPPLY"],
    ["INTEL", 12316, "STR_MWF_GUIDE_TOPIC_INTEL", "STR_MWF_GUIDE_BODY_INTEL"],
    ["MAIN_OPS", 12317, "STR_MWF_GUIDE_TOPIC_MAINOPS", "STR_MWF_GUIDE_BODY_MAINOPS"],
    ["FOB_ATTACKS", 12318, "STR_MWF_GUIDE_TOPIC_FOB", "STR_MWF_GUIDE_BODY_FOB"],
    ["ENDGAME", 12319, "STR_MWF_GUIDE_TOPIC_ENDGAME", "STR_MWF_GUIDE_BODY_ENDGAME"]
];

private _applyPage = {
    params ["_display", "_pageKey", "_pagesDef"];
    if (isNull _display) exitWith { false };

    private _pageUpper = toUpper _pageKey;
    private _page = _pagesDef select ((_pagesDef findIf { (_x # 0) isEqualTo _pageUpper }) max 0);
    _page params ["_resolvedKey", "_activeIdc", "_titleKey", "_bodyKey"];

    {
        _x params ["_key", "_idc", "_buttonTextKey"];
        private _ctrl = _display displayCtrl _idc;
        if (!isNull _ctrl) then {
            private _isActive = (_key isEqualTo _resolvedKey);
            _ctrl ctrlSetText (localize _buttonTextKey);
            _ctrl ctrlEnable (!_isActive);
            _ctrl ctrlSetTextColor (if (_isActive) then {[0.98, 0.84, 0.42, 1]} else {[0.94, 0.94, 0.94, 1]});
            _ctrl ctrlSetBackgroundColor (if (_isActive) then {[1, 1, 1, 0.10]} else {[0, 0, 0, 0]});
            _ctrl ctrlSetTooltip localize _buttonTextKey;
        };
    } forEach _pagesDef;

    private _headerCtrl = _display displayCtrl 12304;
    private _titleCtrl = _display displayCtrl 12320;
    private _bodyCtrl = _display displayCtrl 12321;

    if (!isNull _headerCtrl) then {
        _headerCtrl ctrlSetStructuredText parseText format [
            "<t size='0.95' color='#FFFFFF'>%1</t><t color='#AAAAAA'> | </t><t size='0.9' color='#8CC8FF'>%2</t>",
            localize "STR_MWF_GUIDE_HEADER",
            localize _titleKey
        ];
    };

    if (!isNull _titleCtrl) then {
        _titleCtrl ctrlSetStructuredText parseText format ["<t size='1.15' color='#F3F3F3' shadow='1'>%1</t>", localize _titleKey];
    };

    if (!isNull _bodyCtrl) then {
        _bodyCtrl ctrlSetStructuredText parseText format ["<t color='#F0F0F0' shadow='1'>%1</t>", localize _bodyKey];
    };

    uiNamespace setVariable ["MWF_Guide_CurrentPage", _resolvedKey];
    true
};

switch (_modeUpper) do {
    case "OPEN": {
        if (!hasInterface) exitWith { false };
        uiNamespace setVariable ["MWF_Guide_ReturnMode", uiNamespace getVariable ["MWF_Guide_ReturnMode", "ZONES"]];
        createDialog "MWF_RscGuide";
        private _display = findDisplay 12300;
        if (isNull _display) exitWith { false };
        uiNamespace setVariable ["MWF_Guide_Display", _display];
        _display displayAddEventHandler ["KeyDown", {
            params ["_display", "_dikCode"];
            if (_dikCode isEqualTo 1) exitWith { ['CLOSE'] call MWF_fnc_openGuide; true };
            false
        }];
        [_display, _payload, _pages] call _applyPage
    };

    case "SET_PAGE": {
        private _display = uiNamespace getVariable ["MWF_Guide_Display", displayNull];
        if (isNull _display) exitWith { false };
        [_display, _payload, _pages] call _applyPage
    };

    case "CLOSE": {
        private _display = uiNamespace getVariable ["MWF_Guide_Display", displayNull];
        private _returnMode = uiNamespace getVariable ["MWF_Guide_ReturnMode", "ZONES"];
        if (!isNull _display) then { closeDialog 0; };
        uiNamespace setVariable ["MWF_Guide_Display", displayNull];
        uiNamespace setVariable ["MWF_Guide_CurrentPage", ""];
        ["OPEN", _returnMode] call MWF_fnc_dataHub;
        true
    };

    default { false };
};
