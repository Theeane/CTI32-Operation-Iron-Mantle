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
uiNamespace setVariable ["MWF_DataHub_SelectedRespawn", nil];

private _statusCtrl = _display displayCtrl 12206;
private _actionCtrl = _display displayCtrl 12207;
if (!isNull _statusCtrl) then {
    _statusCtrl ctrlSetText format ["Mode: %1 | Entries: %2", [_modeUpper, "_", " "] call BIS_fnc_replaceString, count _entries];
};
if (!isNull _actionCtrl) then {
    _actionCtrl ctrlSetText (if (_modeUpper isEqualTo "REDEPLOY") then {"Select Redeploy"} else {"Close"});
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
