/* Dedicated redeploy shell refresh */
if (!hasInterface) exitWith { false };
private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) exitWith { false };

{ deleteMarkerLocal _x; } forEach (uiNamespace getVariable ["MWF_DataHub_Markers", []]);
uiNamespace setVariable ["MWF_DataHub_Markers", []];
{ deleteMarkerLocal _x; } forEach (uiNamespace getVariable ["MWF_Redeploy_Markers", []]);
private _markerNames = [];

private _entries = ([] call MWF_fnc_collectRespawnPoints) select { (_x param [0, "", [""]]) in ["MOB", "FOB"] };
uiNamespace setVariable ["MWF_Redeploy_Entries", _entries];

private _setShow = {
    params ["_idc", "_show"];
    private _ctrl = _display displayCtrl _idc;
    if (!isNull _ctrl) then {
        _ctrl ctrlShow _show;
        _ctrl ctrlEnable _show;
    };
};
{ [_x, false] call _setShow; } forEach [12210,12211,12212,12213,12214,12230,12231,12232,12233,12234,12208,12209,12236,12237];
{ [_x, true] call _setShow; } forEach [12215,12207,12235,12238];

private _leftCtrl = _display displayCtrl 12215;
private _actionCtrl = _display displayCtrl 12207;
if (!isNull _leftCtrl) then { _leftCtrl ctrlSetText "Back"; _leftCtrl ctrlSetTooltip "Return to terminal root."; _leftCtrl buttonSetAction "[] call MWF_fnc_redeployBack;"; _leftCtrl ctrlEnable true; };
if (!isNull _actionCtrl) then { _actionCtrl ctrlSetText "Redeploy"; _actionCtrl ctrlSetTooltip "Redeploy to selected FOB/MOB."; _actionCtrl buttonSetAction "[] call MWF_fnc_redeployPrimaryAction;"; _actionCtrl ctrlEnable false; };

private _statusCtrl = _display displayCtrl 12206;
if (!isNull _statusCtrl) then { _statusCtrl ctrlSetText format ["Redeploy | Destinations: %1 | Click a FOB/MOB to select.", count _entries]; };
private _infoCtrl = _display displayCtrl 12216;
if (!isNull _infoCtrl) then { _infoCtrl ctrlSetStructuredText parseText "<t color='#222222'>Select a FOB or the MOB on the map, then press Redeploy.</t>"; };

private _terminalStatusCtrl = _display displayCtrl 12218;
if (!isNull _terminalStatusCtrl) then {
    private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", missionNamespace getVariable ["MWF_Supplies", 0]];
    private _intel = missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]];
    _terminalStatusCtrl ctrlSetStructuredText parseText format ["<t size='0.9' color='#FFFFFF'>SUP %1</t><t color='#AAAAAA'> | </t><t size='0.9' color='#8CC8FF'>INT %2</t><t color='#AAAAAA'> | </t><t size='0.9' color='#FFFFFF'>REDEPLOY NETWORK</t>", _supplies, _intel];
};

private _sessionId = format ["%1_%2", floor diag_tickTime, floor random 100000];
{
    _x params ["_kind", "_label", "_pos", ["_source", objNull, [objNull]]];
    private _meta = createHashMapFromArray [["kind", _kind], ["source", _source]];
    private _markerName = format ["MWF_Redeploy_%1_%2", _forEachIndex, _sessionId];
    private _marker = createMarkerLocal [_markerName, _pos];
    _marker setMarkerShapeLocal "ICON";
    if (_kind isEqualTo "MOB") then {
        _marker setMarkerTypeLocal "mil_flag";
        _marker setMarkerColorLocal "ColorYellow";
    } else {
        _marker setMarkerTypeLocal "mil_box";
        _marker setMarkerColorLocal "ColorBlue";
    };
    _marker setMarkerTextLocal _label;
    _markerNames pushBack _markerName;
    _entries set [_forEachIndex, [_kind, _label, _pos, _meta]];
} forEach _entries;
uiNamespace setVariable ["MWF_Redeploy_Entries", _entries];
uiNamespace setVariable ["MWF_Redeploy_Markers", _markerNames];

private _mapCtrl = _display displayCtrl 12205;
if (!isNull _mapCtrl) then {
    private _focusPos = if (_entries isEqualTo []) then { getPosATL player } else { (_entries # 0) param [2, getPosATL player, [[]]] };
    _mapCtrl ctrlMapAnimAdd [0.1, 0.2, _focusPos];
    ctrlMapAnimCommit _mapCtrl;
};
true
