/*
    Author: Theane (AGS Project)
    Logic: Garrison Baseline Capture System.
    - RED: Initial enemy strength > 50%.
    - YELLOW: Enemy strength dropped below 50% of baseline (excluding reinforcements).
    - BLUE: 100% Captured (All enemies neutralized).
    Language: English (Code), Swedish (Comments)
*/

if (!isServer) exitWith {};

params ["_marker"];

private _pos = getMarkerPos _marker;
private _size = (getMarkerSize _marker) select 0;

[_marker, _pos, _size] spawn {
    params ["_marker", "_pos", "_size"];

    // 1. Fastställ en "Baseline" för garnisonen vid start
    // Vi räknar hur många fiender som finns i zonen precis när anfallet börjar
    private _initialEnemies = allUnits select { side _x == east && _x distance _pos < _size && alive _x };
    private _baselineCount = count _initialEnemies;
    
    // Säkerhetskoll om zonen råkar vara tom vid start
    if (_baselineCount == 0) then { _baselineCount = 5; }; 

    while {true} do {
        uiSleep 5;

        private _isCaptured = _marker getVariable ["AGS_isCaptured", false];
        private _currentOpfor = allUnits select { 
            side _x == east && 
            _x distance _pos < _size && 
            alive _x && 
            !(_x getVariable ["AGS_isQRF", false]) // EXKLUDERA BACKUP/QRF
        };
        
        private _currentCount = count _currentOpfor;
        private _bluforPresent = { _x distance _pos < _size && alive _x } count allPlayers;

        // --- ANFALLS-FASER ---
        if (!_isCaptured && _bluforPresent > 0) then {
            
            // FAS 1: RÖD -> GUL (Fienden har förlorat mer än 50% av sin ursprungliga styrka)
            if (_currentCount <= (_baselineCount * 0.5) && _currentCount > 0) then {
                if (getMarkerColor _marker != "ColorYellow") then {
                    _marker setMarkerColor "ColorYellow";
                    [format ["%1 defense is crumbling! Sector is now contested.", text _marker]] remoteExec ["systemChat", 0];
                };
            };

            // FAS 2: GUL -> BLÅ (Alla ursprungliga fiender döda)
            if (_currentCount == 0) then {
                _marker setVariable ["AGS_isCaptured", true, true];
                _marker setVariable ["AGS_lastCapTime", serverTime, true]; 
                _marker setMarkerColor "ColorBLUFOR";
                
                [format ["%1 has been fully liberated!", text _marker]] remoteExec ["systemChat", 0];
                [] call AGS_fnc_saveGame;
            };
        };

        // --- MOTANFALLS-FASER (10 min grace, 20 min timer) ---
        if (_isCaptured) then {
            private _lastCap = _marker getVariable ["AGS_lastCapTime", 0];
            
            if (serverTime > (_lastCap + 600)) then {
                private _totalOpfor = { side _x == east && _x distance _pos < _size && alive _x } count allUnits;
                
                if (_totalOpfor > _bluforPresent && _totalOpfor > 0) then {
                    if !(_marker getVariable ["AGS_underAttack", false]) then {
                        _marker setVariable ["AGS_underAttack", true, true];
                        _marker setVariable ["AGS_attackTimer", serverTime + 1200, true];
                        _marker setMarkerColor "ColorYellow"; // GUL under contested
                        [format ["RE-TAKE ATTEMPT: %1 is contested!", text _marker]] remoteExec ["systemChat", 0];
                    };

                    if (serverTime > (_marker getVariable ["AGS_attackTimer", 0])) then {
                        _marker setVariable ["AGS_isCaptured", false, true];
                        _marker setVariable ["AGS_underAttack", false, true];
                        _marker setMarkerColor "ColorOPFOR";
                        [] call AGS_fnc_saveGame;
                    };
                } else {
                    if (_marker getVariable ["AGS_underAttack", false] && _totalOpfor == 0) then {
                        _marker setVariable ["AGS_underAttack", false, true];
                        _marker setMarkerColor "ColorBLUFOR";
                    };
                };
            };
        };
    };
};
