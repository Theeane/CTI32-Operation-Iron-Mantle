/*
    Author: OpenAI / ChatGPT
    Function: MWF_fn_refreshDataMap
    Project: Military War Framework

    Description:
    Rebuilds all local markers for the current Data Hub mode.
    This is intentionally self-contained so the GUI tool can later reuse it.
*/

params [
    ["_display", displayNull, [displayNull]],
    ["_mode", "ZONES", [""]]
];

if (isNull _display) exitWith { false };

private _modeUpper = toUpper _mode;
private _markerNames = uiNamespace getVariable ["MWF_DataHub_Markers", []];
{ deleteMarkerLocal _x; } forEach _markerNames;
_markerNames = [];

private _entries = [_modeUpper] call MWF_fnc_collectDataMapEntries;
uiNamespace setVariable ["MWF_DataHub_Entries", _entries];
uiNamespace setVariable ["MWF_DataHub_Mode", _modeUpper];
uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", []];
uiNamespace setVariable ["MWF_DataHub_SelectedEntry", []];

private _terminalStatusCtrl = _display displayCtrl 12218;
private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
private _carriedIntel = player getVariable ["MWF_carriedIntelValue", 0];
private _worldTier = missionNamespace getVariable ["MWF_WorldTier", 1];
private _baseTier = missionNamespace getVariable ["MWF_CurrentTier", 1];
private _phase = missionNamespace getVariable ["MWF_Campaign_Phase", "TUTORIAL"];
private _freeMainOpCharges = missionNamespace getVariable ["MWF_FreeMainOpCharges", 0];
private _debugText = if (missionNamespace getVariable ["MWF_DebugMode", false]) then {
    "<t color='#FFD27A'> | DEBUG</t>"
} else {
    ""
};
if (!isNull _terminalStatusCtrl) then {
    _terminalStatusCtrl ctrlSetStructuredText parseText format [
        "<t size='0.9' color='#FFFFFF'>SUP %1</t><t color='#AAAAAA'> | </t><t size='0.9' color='#8CC8FF'>INT %2</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFD27A'>TEMP %3</t><t color='#AAAAAA'> | </t><t size='0.9' color='#B7FF9A'>FREE OP %4</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>WORLD T%5</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>BASE T%6</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>PHASE %7</t>%8",
        _supplies,
        _intel,
        _carriedIntel,
        _freeMainOpCharges,
        _worldTier,
        _baseTier,
        _phase,
        _debugText
    ];
};

private _statusCtrl = _display displayCtrl 12206;
private _actionCtrl = _display displayCtrl 12207;
private _infoCtrl = _display displayCtrl 12216;
private _leftCtrl = _display displayCtrl 12215;

if (!isNull _statusCtrl) then {
    private _modeLabel = [_modeUpper, "_", " "] call BIS_fnc_replaceString;
    private _statusText = format ["Mode: %1 | Entries: %2", _modeLabel, count _entries];
    if (_modeUpper in ["SIDE_MISSIONS", "MAIN_OPERATIONS", "REDEPLOY", "SUPPORT", "UPGRADES"]) then {
        _statusText = _statusText + " | Left click marker for details | Right click / Esc = back.";
    };
    _statusCtrl ctrlSetText _statusText;
};

if (!isNull _infoCtrl) then {
    _infoCtrl ctrlSetStructuredText parseText "";
};

if (!isNull _leftCtrl) then {
    private _leftText = switch (_modeUpper) do {
        case "SUPPORT": {"Build Group"};
        case "SIDE_MISSIONS": {"Main Ops"};
        case "UPGRADES": {"Main Ops"};
        default {"Side Missions"};
    };

    _leftCtrl ctrlSetText _leftText;
    _leftCtrl ctrlEnable true;
};

if (!isNull _actionCtrl) then {
    private _actionText = switch (_modeUpper) do {
        case "REDEPLOY": {"Redeploy"};
        case "SUPPORT": {"Build Unit"};
        case "UPGRADES": {"Inspect"};
        case "SIDE_MISSIONS";
        case "MAIN_OPERATIONS": {"Accept"};
        default {"Close"};
    };

    private _actionEnabled = !(_modeUpper in ["REDEPLOY", "SUPPORT", "SIDE_MISSIONS", "MAIN_OPERATIONS", "UPGRADES"]);
    _actionCtrl ctrlSetText _actionText;
    _actionCtrl ctrlEnable _actionEnabled;
};

private _sessionId = format ["%1_%2", floor diag_tickTime, floor random 100000];
{
    _x params ["_kind", "_label", "_pos", ["_meta", createHashMap, [createHashMap]]];

    private _markerName = format ["MWF_DataHub_%1_%2", _forEachIndex, _sessionId];
    private _marker = createMarkerLocal [_markerName, _pos];

    switch (_kind) do {
        case "ZONE": {
            private _range = _meta getOrDefault ["range", 300];
            private _ownerState = _meta getOrDefault ["ownerState", "enemy"];
            private _underAttack = _meta getOrDefault ["underAttack", false];
            private _contested = _meta getOrDefault ["contested", false];
            private _zoneType = toLower (_meta getOrDefault ["zoneType", "town"]);

            _marker setMarkerShapeLocal "ELLIPSE";
            _marker setMarkerSizeLocal [_range, _range];
            _marker setMarkerBrushLocal "SolidBorder";
            _marker setMarkerAlphaLocal 0.65;

            private _color = "ColorOPFOR";
            if (_ownerState isEqualTo "player") then { _color = "ColorBLUFOR"; };
            if (_underAttack || _contested) then { _color = "ColorYellow"; };
            _marker setMarkerColorLocal _color;

            private _textMarkerName = format ["%1_text", _markerName];
            private _textMarker = createMarkerLocal [_textMarkerName, _pos];
            _textMarker setMarkerShapeLocal "ICON";
            _textMarker setMarkerTypeLocal "mil_dot";
            _textMarker setMarkerColorLocal "ColorBlack";
            _textMarker setMarkerTextLocal format ["%1: %2", toUpper _zoneType, _label];
            _markerNames pushBack _textMarkerName;
        };

        case "SIDE_MISSION": {
            private _state = toLower (_meta getOrDefault ["state", "available"]);
            private _difficulty = toLower (_meta getOrDefault ["difficulty", "easy"]);
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTypeLocal "mil_unknown";
            _marker setMarkerColorLocal (["ColorYellow", "ColorOrange", "ColorRed"] select (["easy", "medium", "hard"] find _difficulty max 0));
            if (_state isEqualTo "active") then {
                _marker setMarkerTypeLocal "mil_objective";
            };
            _marker setMarkerTextLocal _label;
        };

        case "MAIN_OPERATION": {
            private _isActive = _meta getOrDefault ["active", false];
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTypeLocal (if (_isActive) then {"mil_objective"} else {"mil_pickup"});
            _marker setMarkerColorLocal (if (_isActive) then {"ColorRed"} else {"ColorOrange"});
            _marker setMarkerTextLocal _label;
        };

        case "SUPPORT": {
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTypeLocal "mil_triangle";
            _marker setMarkerColorLocal "ColorBLUFOR";
            _marker setMarkerTextLocal _label;
        };

        case "UPGRADE": {
            private _statusText = toUpper (_meta getOrDefault ["statusText", "LOCKED"]);
            private _isBuilt = _meta getOrDefault ["isBuilt", false];
            private _actionMode = _meta getOrDefault ["actionMode", "LOCKED"];
            private _color = "ColorOrange";
            if ((_statusText find "ATTACK") > -1 || {(_statusText find "OFFLINE") > -1} || {(_statusText find "UNAVAILABLE") > -1}) then {
                _color = "ColorRed";
            } else {
                if (_isBuilt) then {
                    _color = "ColorGreen";
                } else {
                    if (_actionMode in ["BASE_BUILDING", "GARAGE_BUILD"]) then {
                        _color = "ColorBlue";
                    };
                };
            };
            _marker setMarkerShapeLocal "ICON";
            _marker setMarkerTypeLocal "mil_box";
            _marker setMarkerColorLocal _color;
            _marker setMarkerTextLocal format ["%1 [%2]", _label, _statusText];
        };

        case "RESPAWN": {
            private _respawnKind = _meta getOrDefault ["kind", "FOB"];
            _marker setMarkerShapeLocal "ICON";
            switch (_respawnKind) do {
                case "MOB": {
                    _marker setMarkerTypeLocal "mil_flag";
                    _marker setMarkerColorLocal "ColorYellow";
                };
                case "MRU": {
                    _marker setMarkerTypeLocal "mil_warning";
                    _marker setMarkerColorLocal "ColorGreen";
                };
                case "TENT": {
                    _marker setMarkerTypeLocal "loc_Bunker";
                    _marker setMarkerColorLocal "ColorBlue";
                };
                default {
                    _marker setMarkerTypeLocal "mil_box";
                    _marker setMarkerColorLocal "ColorBlue";
                };
            };
            _marker setMarkerTextLocal _label;
        };
    };

    _markerNames pushBack _markerName;
} forEach _entries;

private _mapCtrl = _display displayCtrl 12205;
if (!isNull _mapCtrl) then {
    private _focusPos = if (_entries isEqualTo []) then {
        if (!isNull player) then { getPosATL player } else { getMarkerPos "respawn_west" }
    } else {
        (_entries # 0) param [2, getPosATL player, [[]]]
    };

    _mapCtrl ctrlMapAnimAdd [0.1, 0.2, _focusPos];
    ctrlMapAnimCommit _mapCtrl;
};

uiNamespace setVariable ["MWF_DataHub_Markers", _markerNames];
true
