/*
    Author: Theeane / Gemini Guide
    Function: MWF_fnc_onQuestComplete
    Project: Military War Framework
    Description: 
    Handles rewards and state changes when a side quest is finished.
    Integrates with the digital economy and global state manager.
*/

params [
    ["_player", objNull, [objNull]],
    ["_missionType", "", [""]]
];

if (isNull _player) exitWith {};

// Base rewards
private _baseReward = 0;
private _bonusReward = 0;

// Undercover Check (Uses the logic from checkUndercover)
private _currentUniform = uniform _player;
private _isUndercover = !(_currentUniform in (missionNamespace getVariable ["MWF_Undercover_Blacklist", []]));

switch (_missionType) do {
    case "supply": {
        _baseReward = random [100, 200, 300];
        _bonusReward = if (_isUndercover) then { random [50, 75, 100] } else { 0 };
    };

    case "intel": {
        _baseReward = random [50, 75, 100];
        _bonusReward = if (_isUndercover) then { random [100, 200, 300] } else { 0 };
    };

    case "disrupt": {
        _baseReward = selectRandom [50, 100];
        _bonusReward = selectRandom [0, 1];

        if (_bonusReward == 1) then {
            private _randomReveal = selectRandom ["roadblock", "HQ"];
            [format ["Disrupt mission: Fixed infrastructure revealed - %1", _randomReveal]] remoteExec ["systemChat", 0];
            // Logic for revealing infrastructure would go here
        };

        // Trigger global state change (cooldown handled inside the manager)
        ["disrupt"] spawn MWF_fnc_globalStateManager;
    };
};

// Apply rewards via the central Digital Economy system
if (_baseReward > 0) then {
    private _resourceType = if (_missionType == "intel") then { "INTEL" } else { "SUPPLIES" };
    
    // Add base reward
    [_baseReward, _resourceType] call MWF_fnc_addResource;

    // Add bonus reward if applicable
    if (_bonusReward > 0) then {
        [_bonusReward, _resourceType] call MWF_fnc_addResource;
        [format ["Bonus received for professional conduct: +%1 %2", _bonusReward, _resourceType]] remoteExec ["systemChat", _player];
    };

    diag_log format ["[MWF] Quest Complete: %1 received %2 %3 (Bonus: %4)", name _player, _baseReward, _resourceType, _bonusReward];
};

true