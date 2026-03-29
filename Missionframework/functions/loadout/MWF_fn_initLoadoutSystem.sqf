/*
    Author: Theeane / Gemini
    Function: MWF_fnc_initLoadoutSystem
    Project: Military War Framework

    Description:
    Client-side monitor that manages:
    1. Interactive actions (Arsenal / Save Loadout) when inside registered zones.
    2. HUD display on the right side (Supplies, Intel, Threat, CivRep, Opfor Tier).
*/

if (!hasInterface) exitWith {};

// Prevent multiple instances of the monitor
if (missionNamespace getVariable ["MWF_LoadoutSystemInitialized", false]) exitWith {};
missionNamespace setVariable ["MWF_LoadoutSystemInitialized", true];

// Initialize item caches (filters for OPFOR uniforms)
[] call MWF_fnc_buildLoadoutCaches;

// Load the player's saved respawn profile from the profileNamespace
private _savedProfile = profileNamespace getVariable ["MWF_SavedRespawnProfile", []];
missionNamespace setVariable ["MWF_SavedRespawnProfile", _savedProfile];

[] spawn {
    private _boundPlayer = objNull;
    
    // --- HUD RENDERER ---
    // Displays vital mission stats on the right side of the screen
    private _fnc_displayHUD = {
        private _supplies = missionNamespace getVariable ["MWF_Economy_Supplies", 0];
        private _intel    = missionNamespace getVariable ["MWF_res_intel", 0];
        private _threat   = missionNamespace getVariable ["MWF_ThreatLevel", 0];
        private _civRep   = missionNamespace getVariable ["MWF_CivRep", 0];
        private _tier     = missionNamespace getVariable ["MWF_OPFOR_Tier", 1];

        private _hudText = format [
            "<t align='right' size='0.85' font='EtelkaMonospaceProBold'>" +
            "<t color='#ffffff'>SUPPLIES: %1</t><br/>" +
            "<t color='#00d7ff'>INTEL: %2</t><br/>" +
            "<t color='#ff4444'>THREAT: %3%6</t><br/>" +
            "<t color='#44ff44'>CIV REP: %4%6</t><br/>" +
            "<t color='#ffff00'>OPFOR TIER: %5</t></t>",
            _supplies, _intel, _threat, _civRep, _tier, "%"
        ];
        
        // Render text on Layer 789 to avoid conflicts with other UI elements
        [parseText _hudText, [0.85, 0.2, 0.4, 0.2], nil, 1, 0, 0, 789] spawn BIS_fnc_dynamicText;
    };

    // --- MAIN MONITOR LOOP ---
    while {true} do {
        waitUntil { !isNull player };

        // Handle player object changes (respawns/rebinds)
        if (_boundPlayer != player) then {
            private _oldIds = missionNamespace getVariable ["MWF_LoadoutActionIds", []];
            if (!isNull _boundPlayer) then {
                { _boundPlayer removeAction _x; } forEach _oldIds;
            };
            missionNamespace setVariable ["MWF_LoadoutActionIds", []];
            _boundPlayer = player;
        };

        // Identify active loadout zones (MOB and deployed FOBs)
        private _zones = missionNamespace getVariable ["MWF_LoadoutZones", []];
        private _insideZone = false;
        
        {
            if (player inArea _x) exitWith { _insideZone = true; };
        } forEach (_zones select { !isNull _x });

        // Logic for HUD and Scroll Menus
        if (_insideZone) then {
            // Update the resource display while in base
            [] call _fnc_displayHUD;

            // Check if actions need to be added
            private _hasActions = !((missionNamespace getVariable ["MWF_LoadoutActionIds", []]) isEqualTo []);
            if (!_hasActions) then {
                private _actionIds = [];
                
                // Action 1: Virtual Arsenal
                _actionIds pushBack (player addAction [
                    "<t color='#00d7ff'>Open Virtual Arsenal</t>",
                    { [] call MWF_fnc_openLoadoutArsenal; },
                    nil, 1.5, false, true, "", "alive _target"
                ]);

                // Action 2: Save Respawn Loadout
                _actionIds pushBack (player addAction [
                    "<t color='#ffaa00'>Save Respawn Loadout</t>",
                    { [] call MWF_fnc_saveRespawnLoadout; },
                    nil, 1.4, false, true, "", "alive _target"
                ]);

                missionNamespace setVariable ["MWF_LoadoutActionIds", _actionIds];
            };
        } else {
            // Remove actions when leaving the zone
            private _currentActionIds = missionNamespace getVariable ["MWF_LoadoutActionIds", []];
            if (_currentActionIds isNotEqualTo []) then {
                { player removeAction _x; } forEach _currentActionIds;
                missionNamespace setVariable ["MWF_LoadoutActionIds", []];
            };
        };

        missionNamespace setVariable ["MWF_InLoadoutZone", _insideZone];
        uiSleep 1; // Sleep for performance
    };
};

diag_log "[MWF] Loadout System Monitor: Initialized with HUD and Tier tracking.";