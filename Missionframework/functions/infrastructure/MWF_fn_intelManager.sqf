/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_intelManager
    Project: Military War Framework

    Description:
    Searchable officer/computer intel pipeline for HQ and roadblock infrastructure.
    This replaces the old server-`cameraView` discovery loop with authoritative
    search interactions that award digital intel or return nothing when the player
    is already carrying too much useful intel.
*/

if (!isServer) exitWith { false };

params [
    ["_mode", "SPAWN_INTEL", [""]],
    ["_params", []]
];

private _getCurrentIntel = {
    missionNamespace getVariable ["MWF_res_intel", missionNamespace getVariable ["MWF_Intel", 0]]
};

private _pickOfficerClass = {
    private _preset = missionNamespace getVariable ["MWF_OPFOR_Preset", createHashMap];
    private _candidates = [];
    {
        private _key = _x;
        private _list = _preset getOrDefault [_key, []];
        if (_list isEqualType []) then { _candidates append _list; };
    } forEach ["Infantry_T5", "Infantry_T4", "Infantry_T3", "Infantry_T2", "Infantry_T1"];

    private _preferred = _candidates select {
        private _cls = toLower str _x;
        (_cls find "officer") >= 0 || {(_cls find "leader") >= 0} || {(_cls find "sl") >= 0}
    };

    if (_preferred isNotEqualTo []) exitWith { _preferred # 0 };
    if (_candidates isNotEqualTo []) exitWith { _candidates # 0 };
    "O_Officer_F"
};

private _registerSearchAction = {
    params ["_object", "_label", ["_searchType", "COMPUTER", [""]]];
    if (isNull _object) exitWith {};

    _object setVariable ["MWF_IntelSearchType", _searchType, true];
    _object setVariable ["MWF_IntelSearchUsed", false, true];

    _object addAction [
        format ["<t color='#FFD866'>%1</t>", _label],
        {
            params ["_target", "_caller", "_actionId", "_args"];
            _args params [["_searchType", "COMPUTER", [""]]];
            ["SEARCH", [_target, _caller, _searchType]] remoteExecCall ["MWF_fnc_intelManager", 2];
        },
        [_searchType],
        2,
        true,
        true,
        "",
        "alive _target && !(_target getVariable ['MWF_IntelSearchUsed', false])"
    ];
};

switch (toUpper _mode) do {
    case "SPAWN_INTEL": {
        _params params [
            ["_basePos", [0,0,0], [[]]],
            ["_type", "ROADBLOCK", [""]]
        ];

        if !(_basePos isEqualType [] && {count _basePos >= 2}) exitWith { false };

        private _normalizedType = toUpper _type;
        private _spawnComputer = _normalizedType isEqualTo "HQ" || {random 1 > 0.4};
        private _spawnOfficer = _normalizedType isEqualTo "HQ" || {random 1 > 0.55};
        private _spawned = [];

        if (_spawnComputer) then {
            private _computerPos = _basePos vectorAdd [2 + random 2, 0.5 - random 1, 0];
            private _computer = createVehicle ["Land_Laptop_unfolded_F", _computerPos, [], 0, "NONE"];
            _computer setDir (random 360);
            _computer allowDamage false;
            _computer setVariable ["MWF_parentBasePos", _basePos, true];
            [_computer, if (_normalizedType isEqualTo "HQ") then {"Search HQ Computer"} else {"Search Roadblock Computer"}, "COMPUTER"] call _registerSearchAction;
            _spawned pushBack _computer;
        };

        if (_spawnOfficer) then {
            private _officerClass = call _pickOfficerClass;
            private _group = createGroup [east, true];
            private _officer = _group createUnit [_officerClass, _basePos vectorAdd [-2 - random 2, 0.5 - random 1, 0], [], 0, "NONE"];
            removeAllWeapons _officer;
            removeAllItems _officer;
            removeAllAssignedItems _officer;
            _officer disableAI "PATH";
            _officer disableAI "AUTOCOMBAT";
            _officer disableAI "TARGET";
            _officer disableAI "AUTOTARGET";
            _officer setBehaviourStrong "SAFE";
            _officer setCombatMode "BLUE";
            _officer setVariable ["MWF_parentBasePos", _basePos, true];
            [_officer, "Search Officer", "OFFICER"] call _registerSearchAction;
            _spawned pushBack _officer;
        };

        missionNamespace setVariable ["MWF_ActiveIntelAnchors", (missionNamespace getVariable ["MWF_ActiveIntelAnchors", []]) + _spawned, true];
        diag_log format ["[MWF INTEL] Spawned %1 searchable intel anchor(s) for %2 at %3.", count _spawned, _normalizedType, _basePos];
        _spawned
    };

    case "SEARCH": {
        _params params [
            ["_target", objNull, [objNull]],
            ["_caller", objNull, [objNull]],
            ["_searchType", "COMPUTER", [""]]
        ];

        if (isNull _target || {isNull _caller}) exitWith { false };
        if (_target getVariable ["MWF_IntelSearchUsed", false]) exitWith { false };
        if ((_caller distance _target) > 6) exitWith { false };

        _target setVariable ["MWF_IntelSearchUsed", true, true];

        private _currentIntel = call _getCurrentIntel;
        private _findChance = (85 - (_currentIntel / 4)) max 10 min 85;
        private _foundIntel = (random 100) <= _findChance;
        private _reward = 0;

        if (_foundIntel) then {
            _reward = switch (toUpper _searchType) do {
                case "OFFICER": { 18 + floor (random 13) };
                default { 10 + floor (random 11) };
            };
            [_reward, "INTEL"] call MWF_fnc_addResource;
            [format ["Recovered %1 intel from the %2.", _reward, toLower _searchType]] remoteExec ["hint", owner _caller];
            [["INTEL RECOVERED", format ["%1 Intel secured.", _reward]], "success"] remoteExec ["MWF_fnc_showNotification", 0];
        } else {
            [format ["You found nothing useful on the %1.", toLower _searchType]] remoteExec ["hint", owner _caller];
            [["SEARCH COMPLETE", "Nothing useful was recovered."], "info"] remoteExec ["MWF_fnc_showNotification", 0];
        };

        if (!isNil "MWF_fnc_requestDelayedSave") then { [] call MWF_fnc_requestDelayedSave; };
        true
    };

    default { false };
};
