/*
    Author: Theane / ChatGPT
    Function: fn_rebelManager
    Project: Military War Framework

    Description:
    Handles rebel manager for the rebel system.
*/

if (!isServer) exitWith {};

params [["_mode", "MIGRATE"]];

// --- MODE: REFRESH_ZONES (The 10-second Clean Slate) ---
// Triggered when a bribe is paid or reputation is reset
if (_mode == "REFRESH_ZONES") exitWith {
    diag_log "[KPIN REBEL]: Clean Slate initiated. Despawning leader...";
    
    // 1. Remove the leader
    private _oldLeader = missionNamespace getVariable ["MWF_ActiveRebelLeader", objNull];
    if (!isNull _oldLeader) then { deleteVehicle _oldLeader; };
    
    // 2. The Void (10 second cooldown as per project rules)
    sleep 10;
    
    // 3. Restart migration to place leader at a safe location
    ["MIGRATE"] spawn MWF_fnc_rebelManager;
};

// --- MODE: MIGRATE ---
// Finds the best location (MOB or FOB) for the rebel leader based on player proximity
if (_mode == "MIGRATE") exitWith {
    private _locations = [getMarkerPos "respawn_west"]; // Start with MOB
    
    // Add active FOBs to potential locations
    {
        private _pos = _x select 0;
        if (_pos distance [0,0,0] > 10) then { _locations pushBack _pos; };
    } forEach (missionNamespace getVariable ["MWF_FOB_Positions", []]);

    // Determine nearest location to the active player group
    private _avgPos = [0,0,0];
    private _players = allPlayers select {alive _x};
    if (count _players > 0) then {
        { _avgPos = _avgPos vectorAdd (getPos _x) } forEach _players;
        _avgPos = _avgPos vectorMultiply (1 / (count _players));
    } else {
        _avgPos = getMarkerPos "respawn_west";
    };

    private _targetPos = [_locations, _avgPos] call BIS_fnc_nearestPosition;

    // 1. Spawn the leader at the chosen base
    [_targetPos] call MWF_fnc_rebelSpawn; // This will handle addActions for Quests/Bribes

    // 2. IMPORTANT SYNC: Tell the spawn system to refresh "Fixed Infrastructure"
    // This ensures discovered HQs/Roadblocks stay on the map even after a reset.
    ["REFRESH_FIXED_BASES"] call MWF_fnc_spawnManager;

    diag_log format ["[KPIN REBEL]: Migration complete. Leader positioned at %1.", _targetPos];
};
