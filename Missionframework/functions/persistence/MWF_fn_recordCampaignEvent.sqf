/*
    Author: Theane / ChatGPT
    Function: fn_recordCampaignEvent
    Project: Military War Framework

    Description:
    Updates campaign analytics for a specific player UID.

    Record format:
    [UID, Name, OPFOR_Killed, Rebels_Killed, Civilians_Killed, Buildings_Destroyed, HQ_Roadblocks_Destroyed, Executioner]
*/

if (!isServer) exitWith { false };

params [
    ["_uid", "", [""]],
    ["_name", "Unknown", [""]],
    ["_eventType", "", [""]],
    ["_delta", 1, [0]]
];

if (_uid isEqualTo "" || {_eventType isEqualTo ""}) exitWith { false };

private _analytics = + (missionNamespace getVariable ["MWF_Campaign_Analytics", []]);
private _index = _analytics findIf { (_x param [0, ""]) isEqualTo _uid };

if (_index < 0) then {
    _analytics pushBack [_uid, _name, 0, 0, 0, 0, 0, 0];
    _index = (count _analytics) - 1;
};

private _record = + (_analytics # _index);
_record set [1, _name];

private _fieldIndex = switch (toUpper _eventType) do {
    case "OPFOR_KILLED": { 2 };
    case "REBELS_KILLED": { 3 };
    case "CIVILIANS_KILLED": { 4 };
    case "BUILDINGS_DESTROYED": { 5 };
    case "HQ_ROADBLOCKS_DESTROYED": { 6 };
    case "EXECUTIONER": { 7 };
    default { -1 };
};

if (_fieldIndex < 0) exitWith { false };

private _currentValue = _record param [_fieldIndex, 0];
_record set [_fieldIndex, _currentValue + _delta];
_analytics set [_index, _record];

missionNamespace setVariable ["MWF_Campaign_Analytics", _analytics, true];
true
