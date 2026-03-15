/*
    Author: Gemini (Production Pass 3.0)
    Purpose: Reveal hidden infrastructure. Fixed broadcast and data validation.
*/
params [
    ["_unit", objNull, [objNull]],
    ["_serverCommit", false, [true]]
];

if (_serverCommit) exitWith {
    if (!isServer || isNull _unit) exitWith {};

    private _intel = missionNamespace getVariable ["MWF_Intel", 0];
    if (_intel < 150) exitWith {
        [["INSUFFICIENT INTEL", "Encryption crack requires 150 Intel."], "warning"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    private _hqs = missionNamespace getVariable ["MWF_HQs", []];
    private _rbs = missionNamespace getVariable ["MWF_Roadblocks", []];
    private _pool = _hqs + _rbs;
    private _revealed = missionNamespace getVariable ["MWF_RevealedInfrastructure", []];
    
    // Validation pass for object-based infrastructure
    private _candidates = _pool - _revealed;
    _candidates = _candidates select { !isNull _x }; 

    if (count _candidates == 0) exitWith {
        [["DATABASE DEPLETED", "No unknown infrastructure located."], "info"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    };

    private _target = selectRandom _candidates;
    private _type = if (_target in _hqs) then { "Enemy HQ" } else { "Roadblock" };
    
    [-150, "INTEL"] call MWF_fnc_addResource;
    _revealed pushBackUnique _target;
    missionNamespace setVariable ["MWF_RevealedInfrastructure", _revealed, true];

    private _m = createMarker [format ["MWF_Revealed_%1", floor(random 99999)], getPosWorld _target];
    _m setMarkerType "mil_warning";
    _m setMarkerColor "ColorOPFOR";
    _m setMarkerText format ["Detected %1", _type];

    // Fixed Broadcast: Purchaser gets success, others get an info update
    [["TARGET LOCATED", format ["Position marked: %1.", _type]], "success"] remoteExecCall ["MWF_fnc_showNotification", owner _unit];
    [["INTEL UPDATE", "New enemy infrastructure revealed on map."], "info"] remoteExecCall ["MWF_fnc_showNotification", [0, -1] select isDedicated]; 
};

if (!hasInterface || _unit != player) exitWith {};
[_unit, true] remoteExecCall ["MWF_fnc_terminal_disrupt", 2];