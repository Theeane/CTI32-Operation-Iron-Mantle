/*
    Author: Theane / ChatGPT
    Function: fn_buyIntel
    Project: Military War Framework

    Description:
    Handles buy intel for the economy system.
*/

private _cost = 50; // Cost to reveal a zone or group
private _currentIntel = missionNamespace getVariable ["MWF_CurrentIntel", 0];

// 1. Check if the team can afford it
if (_currentIntel < _cost) exitWith {
    ["TaskFailed", ["", format["Not enough Intel! Need %1.", _cost]]] call BIS_fnc_showNotification;
};

// 2. Deduct the cost
MWF_CurrentIntel = MWF_CurrentIntel - _cost;
publicVariable "MWF_CurrentIntel";

// 3. The Reward: Reveal a random enemy group
// (This is a placeholder logic until we have our spawn system tomorrow)
private _allEnemyGroups = allGroups select { side _x == east || side _x == resistance };

if (count _allEnemyGroups > 0) then {
    private _targetGroup = selectRandom _allEnemyGroups;
    private _pos = getPos (leader _targetGroup);
    
    // Create a temporary marker for the players
    private _mkrName = format ["intel_reveal_%1", tickTime];
    private _mkr = createMarker [_mkrName, _pos];
    _mkr setMarkerType "hd_warning";
    _mkr setMarkerColor "ColorRed";
    _mkr setMarkerText "Estimated Enemy Position";
    
    ["TaskSucceeded", ["", "Enemy movements revealed on map!"]] call BIS_fnc_showNotification;
    
    // Remove marker after 5 minutes
    [_mkr] spawn {
        params ["_mkr"];
        sleep 300;
        deleteMarker _mkr;
    };
} else {
    ["TaskFailed", ["", "No enemy activity detected in the area."]] call BIS_fnc_showNotification;
};
