/*
    Author: Theeane / Gemini (AGS Project)
    Logic: Garrison Baseline Capture System with Economy Integration.
    - RED: Initial enemy strength > 50%.
    - YELLOW: Enemy strength dropped below 50% or Contested.
    - BLUE: 100% Captured (Income Active).
    Language: English
*/

if (!isServer) exitWith {};

params ["_marker"];

private _pos = getMarkerPos _marker;
private _size = (getMarkerSize _marker) select 0;

[_marker, _pos, _size] spawn {
    params ["_marker", "_pos", "_size"];

    // 1. Establish baseline garrison strength
    private _initialEnemies = allUnits select { side _x == east && _x distance _pos < _size && alive _x };
    private _baselineCount = count _initialEnemies;
    if (_baselineCount == 0) then { _baselineCount = 5; }; 

    while {true} do {
        uiSleep 5;

        private _isCaptured = _marker getVariable ["AGS_isCaptured", false];
        private _currentOpfor = allUnits select { 
            side _x == east && 
            _x distance _pos < _size && 
            alive _x && 
            !(_x getVariable ["AGS_isQRF", false]) 
        };
        
        private _currentCount = count _currentOpfor;
        private _bluforPresent = { _x distance _pos < _size && alive _x } count allPlayers;

        // --- CAPTURE PHASES ---
        if (!_isCaptured && _bluforPresent > 0) then {
            
            // PHASE 1: RED -> YELLOW (Enemies < 50%)
            if (_currentCount <= (_baselineCount * 0.5) && _currentCount > 0) then {
                if (getMarkerColor _marker != "ColorYellow") then {
                    _marker setMarkerColor "ColorYellow";
                    [format ["%1 defense is crumbling! Sector is now contested.", (markerText _marker)]] remoteExec ["systemChat", 0];
                };
            };

            // PHASE 2: YELLOW -> BLUE (Fully Liberated)
            if (_currentCount == 0) then {
                _marker setVariable ["AGS_isCaptured", true, true];
                _marker setVariable ["AGS_lastCapTime", serverTime, true]; 
                _marker setMarkerColor "ColorBLUFOR";
                
                // --- NEW: ECONOMY INTEGRATION ---
                // Give immediate reward for liberation
                [100, "SUPPLIES"] call AGS_fnc_addResource; 
                [5, "INTEL"] call AGS_fnc_addResource;

                [format ["%1 has been liberated! +100 Supplies bonus received.", (markerText _marker)]] remoteExec ["systemChat", 0];
                
                if (!isNil "AGS_fnc_saveGame") then { [] call AGS_fnc_saveGame; };
            };
        };

        // --- COUNTER-ATTACK LOGIC (10 min grace, 20 min timer) ---
        if (_isCaptured) then {
            private _lastCap = _marker getVariable ["AGS_lastCapTime", 0];
            
            if (serverTime > (_lastCap + 600)) then {
                private _totalOpfor = { side _x == east && _x distance _pos < _size && alive _x } count allUnits;
                
                if (_totalOpfor > _bluforPresent && _totalOpfor > 0) then {
                    // Start retake attempt
                    if !(_marker getVariable ["AGS_underAttack", false]) then {
                        _marker setVariable ["AGS_underAttack", true, true]; // THIS PAUSES PASSIVE INCOME
                        _marker setVariable ["AGS_attackTimer", serverTime + 1200, true];
                        _marker setMarkerColor "ColorYellow";
                        [format ["RE-TAKE ATTEMPT: Supply lines to %1 are interrupted!", (markerText _marker)]] remoteExec ["systemChat", 0];
                    };

                    // Check if time ran out (Zone lost)
                    if (serverTime > (_marker getVariable ["AGS_attackTimer", 0])) then {
                        _marker setVariable ["AGS_isCaptured", false, true];
                        _marker setVariable ["AGS_underAttack", false, true];
                        _marker setMarkerColor "ColorOPFOR";
                        if (!isNil "AGS_fnc_saveGame") then { [] call AGS_fnc_saveGame; };
                    };
                } else {
                    // Attack repelled
                    if (_marker getVariable ["AGS_underAttack", false] && _totalOpfor == 0) then {
                        _marker setVariable ["AGS_underAttack", false, true]; // INCOME RESTORED
                        _marker setMarkerColor "ColorBLUFOR";
                        [format ["Attack on %1 repelled. Supply lines restored.", (markerText _marker)]] remoteExec ["systemChat", 0];
                    };
                };
            };
        };
    };
};
