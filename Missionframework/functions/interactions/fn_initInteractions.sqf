/* Author: Theeane
    Description: 
    Initializes interactions for units based on their side and status.
    All code in English.
*/

params ["_unit"];

if (isNull _unit) exitWith {};

// 1. CIVILIAN INTERACTIONS
if (side _unit == civilian) exitWith {
    // Add the Talk option (From our economy module)
    [_unit] call CTI_fnc_initCivilianActions; 
};

// 2. ENEMY INTERACTIONS (OPFOR / RESISTANCE)
if (side _unit == east || side _unit == resistance) exitWith {
    // Add Search Body, Undercover Trade, and NATO Signal
    [_unit] call CTI_fnc_initEnemyActions;
    
    // Start the background check for "The Signal" (if they are informants)
    if (_unit getVariable ["GVAR_isInformant", false]) then {
        [_unit] spawn CTI_fnc_signalPlayer;
    };
};
