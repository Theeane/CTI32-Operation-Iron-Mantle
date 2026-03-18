/*
    Author: Theane / ChatGPT
    Function: fn_discoverMissionTemplates
    Project: Military War Framework

    Description:
    Discovers side mission templates from the folder-driven mission structure.
    The mission pool is parameter-driven and only scans numbered templates.
    Legacy suffix files such as MissionDisrupt_easy.sqf are ignored.

    Return:
    Array of mission template records:
    [missionKey, category, difficulty, missionId, missionPath]
*/

if (!isServer) exitWith {[]};

private _definitions = [
    ["disrupt", "MissionDisrupt"],
    ["supply", "MissionSupply"],
    ["intel", "MissionIntel"]
];

private _difficulties = ["easy", "medium", "hard"];
private _templates = [];
private _maxTemplateId = (missionNamespace getVariable ["MWF_Param_SideMissionTemplateLimit", 24]) max 1 min 99;

{
    _x params ["_category", "_prefix"];

    {
        private _difficulty = _x;

        for "_missionId" from 1 to _maxTemplateId do {
            private _missionPath = format ["SideMissions\%1\%2\%3_%4.sqf", _category, _difficulty, _prefix, _missionId];

            if (fileExists _missionPath) then {
                private _missionKey = toLower format ["%1_%2_%3", _category, _difficulty, _missionId];
                _templates pushBack [_missionKey, _category, _difficulty, _missionId, _missionPath];
            };
        };
    } forEach _difficulties;
} forEach _definitions;

missionNamespace setVariable ["MWF_MissionTemplateRegistry", _templates, true];
diag_log format ["[MWF Missions] Discovered %1 side mission template(s). Pool limit: %2.", count _templates, _maxTemplateId];
_templates
