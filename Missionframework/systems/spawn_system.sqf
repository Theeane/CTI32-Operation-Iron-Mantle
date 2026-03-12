/*
    Author: Theane using gemini
    Function: Proximity Spawning Logic
    Description: Monitors player distance to Roadblocks, HQ, and Missions. 
    Spawns units based on the Lobby Parameter "CTI32_SpawnDistance".
*/

if (!isServer) exitWith {};

// Fetch settings from Lobby Params (set in initServer.sqf)
private _spawnDist = missionNamespace getVariable ["CTI32_SpawnDistance", 1500];
private _unitCap = missionNamespace getVariable ["CTI32_UnitCap", 140];

diag_log format ["[CTI32 SPAWN] System initialized. Range: %1m, UnitCap: %2", _spawnDist, _unitCap];

while {true} do {
    private _allPlayers = allPlayers select {alive _x};
    
    // 1. HANDLE ROADBLOCKS
    {
        private _data = _x;
        private _pos = _data select 0;
        private _isSpawned = _data select 3;
        
        private _nearPlayer = [_pos, _allPlayers, _spawnDist] call {
            params ["_p", "_players", "_dist"];
            private _found = false;
            { if ((_x distance _p) < _dist) exitWith { _found = true; }; } forEach _players;
            _found
        };

        if (_nearPlayer && !_isSpawned) then {
            if (count allUnits < _unitCap) then {
                _data set [3, true]; 
                [_data] spawn CTI32_fnc_createRoadblock; 
            };
        };
    } forEach CTI32_ActiveRoadblocks;

    // 2. HANDLE HQ
    {
        private _data = _x;
        private _pos = _data select 0;
        private _isSpawned = _data select 3;

        private _nearPlayer = [_pos, _allPlayers, _spawnDist] call {
            params ["_p", "_players", "_dist"];
            private _found = false;
            { if ((_x distance _p) < _dist) exitWith { _found = true; }; } forEach _players;
            _found
        };

        if (_nearPlayer && !_isSpawned) then {
            if (count allUnits < _unitCap) then {
                _data set [3, true];
                [_data] spawn CTI32_fnc_createHQ; 
            };
        };
    } forEach CTI32_ActiveHQ;

    // 3. HANDLE MISSIONS (Side Quests & Main Ops)
    {
        private _mission = _x;
        private _pos = getPos (_mission select 0);
        private _isSpawned = _mission select 1;
        private _isFinal = _mission select 2; 

        private _nearPlayer = [_pos, _allPlayers, _spawnDist] call {
            params ["_p", "_players", "_dist"];
            private _found = false;
            { if ((_x distance _p) < _dist) exitWith { _found = true; }; } forEach _players;
            _found
        };

        if ((_nearPlayer || _isFinal) && !_isSpawned) then {
            if (count allUnits < _unitCap || _isFinal) then {
                _mission set [1, true];
                [_mission] spawn CTI32_fnc_createMissionUnits;
            };
        };
    } forEach CTI32_ActiveMissions;

    sleep 5; 
};
