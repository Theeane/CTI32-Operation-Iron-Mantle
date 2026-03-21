/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_intelManager
    Project: Military War Framework

    Description:
    Temporary-intel pipeline manager.
    - search interactions on HQ / roadblock intel anchors award temporary intel
    - generic carried-intel awards are centralized here for bodies / civilians / infrastructure
    - location reveals never happen here; they only roll during a true command-network turn-in
*/

if (!isServer) exitWith { false };

params [
    ["_mode", "SPAWN_INTEL", [""]],
    ["_params", []]
];

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
    case "ADD_CARRIED": {
        _params params [
            ["_receiver", objNull, [objNull]],
            ["_amount", 0, [0]],
            ["_title", "TEMP INTEL", [""]],
            ["_detail", "Temporary intel secured.", [""]]
        ];

        if (isNull _receiver || {_amount <= 0}) exitWith { false };

        private _current = _receiver getVariable ["MWF_carriedIntelValue", 0];
        private _newValue = (_current + _amount) max 0;
        _receiver setVariable ["MWF_carriedIntelValue", _newValue, true];
        _receiver setVariable ["MWF_carryingIntel", (_newValue > 0), true];

        [
            [_title, format ["%1 (+%2 Temp Intel | Carrying: %3)", _detail, _amount, _newValue]],
            "success"
        ] remoteExecCall ["MWF_fnc_showNotification", owner _receiver];

        true
    };

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

        private _carriedIntel = _caller getVariable ["MWF_carriedIntelValue", 0];
        if (_carriedIntel >= 150) exitWith {
            [["SEARCH COMPLETE", "You are already carrying too much temporary intel to sort anything useful here."], "info"] remoteExecCall ["MWF_fnc_showNotification", owner _caller];
            true
        };

        private _reward = switch (toUpper _searchType) do {
            case "OFFICER": { 18 + floor (random 13) };
            default { 10 + floor (random 11) };
        };

        ["ADD_CARRIED", [_caller, _reward, "TEMP INTEL", format ["Recovered %1 temporary intel from the %2.", _reward, toLower _searchType]]] call MWF_fnc_intelManager;
        true
    };

    default { false };
};
