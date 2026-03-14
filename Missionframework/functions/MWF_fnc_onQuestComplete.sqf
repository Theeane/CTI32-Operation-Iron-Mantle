sqf
// Author: Theane / ChatGPT
// Project: Mission War Framework

MWF_fnc_onQuestComplete = {
    params ["_player", "_missionType"];
    
    // Base rewards (digital currency/intel)
    private _baseReward = 0;
    private _bonusReward = 0;
    
    // Check if player is wearing a blacklisted uniform
    private _currentUniform = uniform _player;
    private _isUndercover = !(_currentUniform in MWF_Undercover_Blacklist);
    
    // Handle rewards for different mission types
    switch (_missionType) do {
        case "supply": {
            _baseReward = random [100, 300];
            _bonusReward = _isUndercover ? random [50, 100] : 0;
            // Reward Logic: Supply mission
        };
        case "intel": {
            _baseReward = random [50, 100];
            _bonusReward = _isUndercover ? random [100, 300] : 0;
            // Reward Logic: Intel mission
        };
        case "disrupt": {
            _baseReward = selectRandom [100, 50]; // Either 100 S or 50 Intel
            _bonusReward = selectRandom [0, 1]; // 50% chance of a random reveal
            if (_bonusReward == 1) then {
                // Apply random reveal logic
                _randomReveal = selectRandom ["roadblock", "HQ"];
                systemChat format ["Disrupt mission: Random reveal - %1", _randomReveal];
            };
            // Trigger the global disrupt effects
            [] spawn {["disrupt"] call MWF_fnc_globalStateManager;};
        };
    };
    
    // Apply the base and bonus rewards
    if (_baseReward > 0) then {
        // Add base reward to player inventory (S or Intel)
        if (_missionType == "supply" || _missionType == "disrupt") then {
            MWF_S_Currency = MWF_S_Currency + _baseReward;
        } else {
            MWF_Intel_Points = MWF_Intel_Points + _baseReward;
        };
        // Apply the bonus reward
        if (_bonusReward > 0) then {
            if (_missionType == "supply") then {
                MWF_Intel_Points = MWF_Intel_Points + _bonusReward;
            } else {
                MWF_S_Currency = MWF_S_Currency + _bonusReward;
            };
        };
    };
    
    // Broadcast updates
    publicVariable "MWF_S_Currency";
    publicVariable "MWF_Intel_Points";
};
