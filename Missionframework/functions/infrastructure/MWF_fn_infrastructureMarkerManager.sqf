/*
    Author: OpenAI / ChatGPT
    Function: MWF_fnc_infrastructureMarkerManager
    Project: Military War Framework

    Description:
    Client-local marker manager for HQ and roadblock discovery.
    Proximity discovery is local-only within 500m. Intelligence-driven reveals are
    synchronized through the authoritative revealed-id registry and still render as
    ordinary map/GPS markers only.
*/

if (!hasInterface) exitWith { false };
if (uiNamespace getVariable ["MWF_InfrastructureMarkerManagerStarted", false]) exitWith { true };
uiNamespace setVariable ["MWF_InfrastructureMarkerManagerStarted", true];
uiNamespace setVariable ["MWF_LocalInfrastructureMarkers", createHashMap];

[] spawn {
    while {true} do {
        private _player = player;
        private _markerRegistry = uiNamespace getVariable ["MWF_LocalInfrastructureMarkers", createHashMap];

        if (!isNull _player && {alive _player}) then {
            private _registry = +(missionNamespace getVariable ["MWF_InfrastructureRegistry", []]);
            private _revealedIds = +(missionNamespace getVariable ["MWF_RevealedInfrastructureIDs", []]);
            private _knownIds = keys _markerRegistry;
            private _seenThisPass = [];

            {
                if (_x isEqualType [] && {count _x >= 4}) then {
                    _x params [
                        ["_infraId", "", [""]],
                        ["_infraType", "ROADBLOCK", [""]],
                        ["_object", objNull, [objNull]],
                        ["_storedPos", [0,0,0], [[]]]
                    ];

                    if (_infraId isEqualTo "") then { continue; };

                    private _pos = if (!isNull _object) then { getPosATL _object } else { _storedPos };
                    if !(_pos isEqualType [] && {count _pos >= 2}) then { continue; };

                    private _isGloballyRevealed = _infraId in _revealedIds;
                    private _distance = _player distance2D _pos;
                    private _isProximityRevealed = _distance <= 500;
                    private _shouldShow = _isGloballyRevealed || _isProximityRevealed;

                    if (_shouldShow) then {
                        _seenThisPass pushBackUnique _infraId;

                        private _markerName = _markerRegistry getOrDefault [_infraId, ""];
                        if (_markerName isEqualTo "") then {
                            _markerName = format ["MWF_LocalInfra_%1_%2", _infraId, floor random 100000];
                            private _marker = createMarkerLocal [_markerName, _pos];
                            _marker setMarkerShapeLocal "ICON";
                            switch (toUpper _infraType) do {
                                case "HQ": {
                                    _marker setMarkerTypeLocal "o_hq";
                                    _marker setMarkerColorLocal "ColorOPFOR";
                                    _marker setMarkerTextLocal "Enemy HQ";
                                };
                                default {
                                    _marker setMarkerTypeLocal "mil_warning";
                                    _marker setMarkerColorLocal "ColorOPFOR";
                                    _marker setMarkerTextLocal "Roadblock";
                                };
                            };
                            _markerRegistry set [_infraId, _markerName];
                        } else {
                            _markerName setMarkerPosLocal _pos;
                        };
                    };
                };
            } forEach _registry;

            {
                private _infraId = _x;
                if !(_infraId in _seenThisPass) then {
                    private _markerName = _markerRegistry getOrDefault [_infraId, ""];
                    if (_markerName isNotEqualTo "") then {
                        deleteMarkerLocal _markerName;
                    };
                    _markerRegistry deleteAt _infraId;
                };
            } forEach _knownIds;
        } else {
            {
                deleteMarkerLocal _x;
            } forEach (values _markerRegistry);
            _markerRegistry = createHashMap;
        };

        uiNamespace setVariable ["MWF_LocalInfrastructureMarkers", _markerRegistry];
        uiSleep 3;
    };
};

true
