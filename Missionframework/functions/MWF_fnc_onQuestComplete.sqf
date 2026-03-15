// Author: Theane / ChatGPT
// Project: Military War Framework

params ["_player", "_missionType"];

// Base rewards
private _baseReward = 0;
private _bonusReward = 0;

// Check undercover
private _currentUniform = uniform _player;
private _isUndercover = !(_currentUniform in MWF_Undercover_Blacklist);

switch (_missionType) do {

    case "supply": {

        _baseReward = random [100,300];
        _bonusReward = _isUndercover ? random [50,100] : 0;

    };

    case "intel": {

        _baseReward = random [50,100];
        _bonusReward = _isUndercover ? random [100,300] : 0;

    };

    case "disrupt": {

        _baseReward = selectRandom [100,50];
        _bonusReward = selectRandom [0,1];

        if (_bonusReward == 1) then {

            private _randomReveal = selectRandom ["roadblock","HQ"];
            systemChat format ["Disrupt mission: Random reveal - %1", _randomReveal];

        };

        [] spawn { ["disrupt"] call MWF_fnc_globalStateManager };

    };

};

// Apply rewards
if (_baseReward > 0) then {

    if (_missionType == "supply" || _missionType == "disrupt") then {
        MWF_S_Currency = MWF_S_Currency + _baseReward;
    } else {
        MWF_Intel_Points = MWF_Intel_Points + _baseReward;
    };

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
