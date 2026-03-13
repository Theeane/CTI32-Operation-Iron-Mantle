/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Folder: functions/base
    Description: Initializes an object as a Mobile Respawn point with Digital Vault.
    Language: English
*/

params [["_object", objNull, [objNull]]];

if (isNull _object) exitWith {};

// 1. SET VARIABLES
_object setVariable ["KPIN_isMobileRespawn", true, true];
_object setVariable ["KPIN_isUnderAttack", false, true];
_object setVariable ["KPIN_vaultCurrency", 0, true]; // Initialize digital vault

// 2. CREATE MARKER (Prefix 'mobile_respawn_' is used by the HUD sensor)
private _mkrName = format["mobile_respawn_%1", round(random 9999)];
private _mkr = createMarker [_mkrName, getPosATL _object];
_mkr setMarkerType "b_motor_inf";
_mkr setMarkerColor "ColorGreen";
_mkr setMarkerText "Mobile Respawn";

// 3. ADD VAULT ACTIONS (Manual Store/Get)
// Store Intel (Player -> Vehicle)
_object addAction [
    "<t color='#00FFFF'>[ STORE DIGITAL INTEL ]</t>", 
    {
        params ["_target", "_caller"];
        private _playerIntel = _caller getVariable ["KPIN_carriedIntelValue", 0];
        private _currentVault = _target getVariable ["KPIN_vaultCurrency", 0];
        _target setVariable ["KPIN_vaultCurrency", _currentVault + _playerIntel, true];
        _caller setVariable ["KPIN_carriedIntelValue", 0, true];
        _caller setVariable ["KPIN_carryingIntel", false, true];
        hint format ["Intel Stored.\nVehicle Vault: %1 S", _currentVault + _playerIntel];
    },
    nil, 6, true, true, "", 
    "(speed _target < 1) && (_this distance _target < 5) && (_this getVariable ['KPIN_carriedIntelValue', 0] > 0)"
];

// Get Intel (Vehicle -> Player)
_object addAction [
    "<t color='#FFFF00'>[ EXTRACT INTEL FROM VAULT ]</t>", 
    {
        params ["_target", "_caller"];
        private _vaultIntel = _target getVariable ["KPIN_vaultCurrency", 0];
        private _currentPlayerIntel = _caller getVariable ["KPIN_carriedIntelValue", 0];
        _caller setVariable ["KPIN_carriedIntelValue", _currentPlayerIntel + _vaultIntel, true];
        _caller setVariable ["KPIN_carryingIntel", true, true];
        _target setVariable ["KPIN_vaultCurrency", 0, true];
        hint format ["Intel Extracted.\nYou are now carrying: %1 S", _currentPlayerIntel + _vaultIntel];
    },
    nil, 5, true, true, "", 
    "(speed _target < 1) && (_this distance _target < 5) && (_target getVariable ['KPIN_vaultCurrency', 0] > 0)"
];

// 4. MONITOR LOOP
[_object, _mkr] spawn {
    params ["_obj", "_mkr"];
    
    while {alive _obj} do {
        _mkr setMarkerPos (getPosATL _obj);
        
        private _isStationary = (speed _obj < 2);
        _obj setVariable ["KPIN_respawnAvailable", _isStationary, true];

        if (_isStationary) then {
            _mkr setMarkerAlpha 1;
            _mkr setMarkerText "Mobile Respawn (READY)";
        } else {
            _mkr setMarkerAlpha 0.5;
            _mkr setMarkerText "Mobile Respawn (MOVING...)";
        };

        sleep 2; 
    };
    
    // Notify players if vault contents are lost upon destruction
    private _lostS = _obj getVariable ["KPIN_vaultCurrency", 0];
    if (_lostS > 0) then {
        ["TaskFailed", ["", format["Vault Destroyed: %1 S lost!", _lostS]]] remoteExec ["BIS_fnc_showNotification", 0];
    };
    
    deleteMarker _mkr;
};
