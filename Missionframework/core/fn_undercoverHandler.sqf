/*
    Author: Theane using Gemini (AGS Project)
    Description: Ultimate Undercover & Contraband System.
    Features: 
    - Hidden Small Arms in vehicles.
    - Visible Heavy Weapons (RPG/Launchers) and Explosives (Contraband).
    - Checkpoint Inspections & AI Investigation.
    - Trespassing & Proximity "Stare" logic.
*/

if (!hasInterface) exitWith {};

// Initialize the UI (The Eye)
cutRsc ["AGS_Undercover_Eye", "PLAIN"];

[] spawn {
    private _ctrl = uiNamespace getVariable ["AGS_ctrl_eye", controlNull];
    
    // Config: Gear that reveals you immediately if worn
    private _illegalItems = ["NVGoggles", "NVGoggles_OPFOR", "Rangefinder", "B_UavTerminal"];
    private _illegalVests = ["V_PlateCarrier1_rgr", "V_PlateCarrier2_rgr", "V_HarnessO_brn"];
    private _illegalHeadgear = ["H_HelmetB", "H_HelmetO_ocamo", "H_PASGT_basic_blue_press_F"];
    
    // Config: Contraband (Hard to hide in a civilian vehicle)
    // We will expand this list later with specific classnames
    private _contrabandCategories = ["Launcher_Base_F", "StaticWeapon"];
    private _contrabandItems = [
        "SatchelCharge_Remote_Mag", "DemoCharge_Remote_Mag", 
        "ATMine_Range_Mag", "APERSMine_Range_Mag"
    ];

    while {alive player} do {
        uiSleep 2;

        if (isNull _ctrl) then { _ctrl = uiNamespace getVariable ["AGS_ctrl_eye", controlNull]; };

        private _isUndercover = true;
        private _isSuspicious = false;
        private _eyeIcon = "media\icons\eye_green.paa"; 

        // --- 1. GEAR & WEAPON CHECK (ON PERSON) ---
        if (currentWeapon player != "" && {currentWeapon player != binocular}) then {
            _isUndercover = false;
            _eyeIcon = "media\icons\eye_red.paa";
        };

        if (vest player in _illegalVests || headgear player in _illegalHeadgear || hmd player in _illegalItems) then {
            _isUndercover = false;
            _eyeIcon = "media\icons\eye_red.paa";
        };

        // --- 2. VEHICLE CARGO CHECK (CONTRABAND) ---
        if (vehicle player != player && _isUndercover) then {
            private _veh = vehicle player;
            private _cargo = (weaponCargo _veh) + (magazineCargo _veh) + (itemCargo _veh);
            
            private _foundContraband = false;
            {
                private _item = _x;
                // Check against specific items (mines/explosives)
                if (_item in _contrabandItems) exitWith { _foundContraband = true; };
                // Check against categories (Launchers/RPGs)
                if ({_item isKindOf _x} count _contrabandCategories > 0) exitWith { _foundContraband = true; };
            } forEach _cargo;

            if (_foundContraband) then {
                _isSuspicious = true;
                _eyeIcon = "media\icons\eye_yellow.paa";
                
                // If a guard is inspecting (closer than 4m), you are REVEALED
                private _nearGuards = allUnits select {side _x == east && _x distance _veh < 4};
                if (count _nearGuards > 0) then {
                    _isUndercover = false;
                    _eyeIcon = "media\icons\eye_red.paa";
                };
            };
        };

        // --- 3. PROXIMITY & CHECKPOINT LOGIC ---
        if (_isUndercover) then {
            private _pos = getPos player;
            
            // A. Trespassing in Enemy Zones (150m radius)
            private _activeZones = missionNamespace getVariable ["AGS_all_mission_zones", []];
            {
                if !(_x getVariable ["AGS_isCaptured", false]) then {
                    if (_pos distance _x < 150) exitWith {
                        _isSuspicious = true;
                        _eyeIcon = "media\icons\eye_yellow.paa";
                    };
                };
            } forEach _activeZones;

            // B. The "Stare" & Checkpoint Inspection
            private _nearSoldiers = allUnits select {side _x == east && _x distance player < 15};
            if (count _nearSoldiers > 0) then {
                if (speed player < 2) then {
                    // Checkpoint Inspection Timer
                    private _inspectTime = player getVariable ["AGS_inspectTimer", 0];
                    player setVariable ["AGS_inspectTimer", _inspectTime + 1];
                    
                    if (_inspectTime > 5) then { // Pass after ~10 seconds
                        player setVariable ["AGS_suspicionLevel", -15]; // Grace period
                        player setVariable ["AGS_inspectTimer", 0];
                    };
                } else {
                    // Normal Stare Logic
                    private _suspicion = player getVariable ["AGS_suspicionLevel", 0];
                    player setVariable ["AGS_suspicionLevel", _suspicion + 1];
                    _isSuspicious = true;
                    _eyeIcon = "media\icons\eye_yellow.paa";

                    if (_suspicion > 6) then { _isUndercover = false; _eyeIcon = "media\icons\eye_red.paa"; };
                };
            } else {
                player setVariable ["AGS_suspicionLevel", 0];
                player setVariable ["AGS_inspectTimer", 0];
            };
        };

        // --- 4. APPLY STATUS ---
        if (_isUndercover) then {
            if (!captive player) then { [player, true] remoteExec ["setCaptive", 0]; };
        } else {
            if (captive player) then { [player, false] remoteExec ["setCaptive", 0]; };
        };

        if (!isNull _ctrl) then { _ctrl ctrlSetText _eyeIcon; };
    };
};

// --- EVENT HANDLERS ---
player addEventHandler ["Fired", {
    params ["_unit"];
    _unit setVariable ["AGS_firedRecently", true, true];
    [_unit] spawn { uiSleep 45; (_this select 0) setVariable ["AGS_firedRecently", false, true]; };
}];

player addEventHandler ["HandleDamage", {
    params ["_unit", "_selection", "_damage", "_source", "_projectile", "_hitIndex", "_instigator"];
    if (vehicle _unit != _unit && _damage > 0.01) then {
        private _witnesses = allUnits select {side _x == east && {_x distance _unit < 100} && {([_x, "VIEW"] checkVisibility [getPosASL _x, getPosASL _unit]) > 0.6}};
        if (count _witnesses > 0) then {
            _unit setVariable ["AGS_isSuspicious_Collision", true, true];
            private _investigator = [_witnesses, _unit] call BIS_fnc_nearestPosition;
            _investigator doMove (getPos _unit);
            [_unit] spawn { uiSleep 120; (_this select 0) setVariable ["AGS_isSuspicious_Collision", false, true]; };
        };
    };
    _damage
}];
