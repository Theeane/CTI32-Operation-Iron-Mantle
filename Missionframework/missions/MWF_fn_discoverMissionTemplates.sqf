/*
    Author: Theane / ChatGPT
    Function: fn_discoverMissionTemplates
    Project: Military War Framework

    Description:
    Discovers side mission templates from the domain-aware folder structure.
    The mission pool is auto-discovered and no longer depends on a lobby cap.
    Domain availability is feature-switch driven so naval and air can remain
    coded but disabled until their systems are ready.

    Return:
    Array of mission template records:
    [missionKey, category, difficulty, missionId, missionPath, domain]
*/

if (!isServer) exitWith {[]};

private _definitions = [
    ["disrupt", "MissionDisrupt"],
    ["supply", "MissionSupply"],
    ["intel", "MissionIntel"]
];

private _domains = [];
if (missionNamespace getVariable ["MWF_Feature_LandEnabled", true]) then { _domains pushBack "land"; };
if (missionNamespace getVariable ["MWF_Feature_NavalEnabled", false]) then { _domains pushBack "naval"; };
if (missionNamespace getVariable ["MWF_Feature_AirEnabled", false]) then { _domains pushBack "air"; };

private _difficulties = ["easy", "medium", "hard"];
private _templates = [];
private _maxTemplateId = 999;

{
    private _domain = _x;

    {
        _x params ["_category", "_prefix"];

        {
            private _difficulty = _x;

            for "_missionId" from 1 to _maxTemplateId do {
                private _missionPath = format ["SideMissions\%1\%2\%3\%4_%5.sqf", _domain, _category, _difficulty, _prefix, _missionId];

                if (fileExists _missionPath) then {
                    private _missionKey = toLower format ["%1_%2_%3_%4", _domain, _category, _difficulty, _missionId];
                    _templates pushBack [_missionKey, _category, _difficulty, _missionId, _missionPath, _domain];
                };
            };
        } forEach _difficulties;
    } forEach _definitions;
} forEach _domains;

missionNamespace setVariable ["MWF_MissionTemplateRegistry", _templates, true];
diag_log format ["[MWF Missions] Discovered %1 side mission template(s). Enabled domains: %2 | Auto-scan max id: %3.", count _templates, _domains, _maxTemplateId];
_templates
