/* Adding the 5-second circular UI interaction 
    to an informant or object.
*/

[
    _unit,											// Object the action is attached to
    "Negotiate / Trade Intel",						// Title of the action
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa",	// Idle icon
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_search_ca.paa",	// Progress icon
    "_this distance _target < 3",					// Condition for the action to be shown
    "_caller distance _target < 3",					// Condition for the action to progress
    {},												// Code executed when action starts
    {},												// Code executed on every tick
    { 
        // SUCCESS: Code executed when the 5-second circle is full
        [_target, _caller] spawn CTI_fnc_handleInteractionResult; 
    },
    { 
        // INTERRUPTED: Code executed if player lets go or moves away
        ["TaskFailed", ["", "Interaction interrupted!"]] call BIS_fnc_showNotification;
    },
    [],												// Arguments passed to the scripts
    5,												// DURATION in seconds (Your 5s circle)
    0,												// Priority
    true,											// Remove on completion
    false											// Show in unconscious state
] call BIS_fnc_holdActionAdd;
