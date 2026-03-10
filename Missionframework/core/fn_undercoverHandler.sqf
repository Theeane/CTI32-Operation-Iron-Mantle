/*
    Author: Theane using Gemini (AGS Project)
    Description: Advanced Undercover Handler - Logic Core.
    Reads data from: factions/fn_factionConfig.sqf
    Language: English
*/

if (!hasInterface) exitWith {};

// --- WAIT FOR FACTION DATA ---
waitUntil { !isNil "AGS_cfg_civUniforms" };

// Initialize UI
cutRsc ["AGS_Undercover_Eye", "PLAIN"];

[] spawn {
    private _ctrl = uiNamespace getVariable ["AGS_ctrl_eye", controlNull];
    
    while {alive player} do {
        uiSleep 2;
        if (isNull _ctrl) then { _ctrl = uiNamespace getVariable ["AGS_ctrl_eye", controlNull]; };

        // Fetch latest faction data from missionNamespace
        private _civUniforms   = missionNamespace getVariable "AGS_cfg_civUniforms";
        private _enemyUniforms = missionNamespace getVariable "AGS_cfg_enemyUniforms";
        private _enemyVests    = missionNamespace getVariable "AGS_cfg_enemyVests";
        private _enemyHeadgear = missionNamespace getVariable "AGS_cfg_enemyHeadgear";
        private _contraband    = missionNamespace getVariable "AGS_cfg_contrabandItems";
        private _contrabandCat = missionNamespace getVariable "AGS_cfg_contrabandCategories";

        private _isUndercover = true;
        private _isSuspicious = false;
        private _eyeIcon = "media\icons\eye_green.paa"; 
        
        // Check current gear
        private _hasEnemyUniform = (uniform player in _enemyUniforms);
        private _hasEnemyVest    = (vest player in _enemyVests);
        private _hasEnemyHelmet  = (headgear player in _enemyHeadgear);
        private _isCivilian      = (uniform player in _civUniforms);

        // --- 1. ENEMY INFILTRATION LOGIC ---
        if (_hasEnemyUniform) then {
            if (_hasEnemyVest && _hasEnemyHelmet) then {
                // Full Kit: Weapons allowed, Trusted status
                _isSuspicious = false;
                _eyeIcon = "media\icons\eye_green.paa";
            } else {
                // Partial Kit: Uniform only = Permanent Yellow
                if (_hasEnemyVest || _hasEnemyHelmet) then {
                    _isUndercover = false; // Immediate red if wearing vest/helmet without uniform
                } else {
                    _isSuspicious = true;
                    _eyeIcon = "media\icons\eye_yellow.paa";
                };
            };

            // Rank-Based Detection (Leader: 2.2m, Private: 1.2m)
            private _nearEnemies = allUnits select {side _x == east && _x distance player < 5};
            {
                private _dist = _x distance player;
                private _detectRange = if (rank _x in ["SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"]) then {2.2} else {1.2};
                if (_dist < _detectRange) exitWith { _isUndercover = false; };
            } forEach _nearEnemies;

            // Identity Stare Logic
            private _suspFactor = if (_hasEnemyVest && _hasEnemyHelmet) then {1} else {4};
            private _staringUnits = allUnits select {side _x == east && _x distance player < 15};
            if (count _staringUnits > 0) then {
                private _susp = player getVariable ["AGS_suspicionLevel", 0];
                player setVariable ["AGS_suspicionLevel", _susp + _suspFactor];
                if (_susp > 15) then { _isUndercover = false; };
            };
        } 
        
        // --- 2. CIVILIAN SCOUTING LOGIC ---
        else {
            if (_hasEnemyVest || _hasEnemyHelmet) then {
                _isUndercover = false; 
            } else {
                if (_isCivilian) then {
                    if (currentWeapon player != "" && {currentWeapon player != binocular}) then { _isUndercover = false; };
                    
                    private _pos = getPos player;
                    private _zones = missionNamespace getVariable ["AGS_all_mission_zones", []] select {!(_x getVariable ["AGS_isCaptured", false])};
                    {
                        if (_pos distance _x < 150) exitWith {
                            _isSuspicious = true;
                            _eyeIcon = "media\icons\eye_yellow.paa";
                            if (_pos distance _x < 50) then { _isUndercover = false; };
                        };
                    } forEach _zones;
                } else {
                    _isUndercover = false;
                };
            };
        };

        // --- 3. VEHICLE & CHECKPOINT LOGIC ---
        if (vehicle player != player && _isUndercover) then {
            private _veh = vehicle player;
            private _cargo = (weaponCargo _veh) + (magazineCargo _veh) + (itemCargo _veh);
            private _hasContraband = false;
            {
                private _item = _x;
                if (_item in _contraband || {({_item isKindOf _x} count _contrabandCat > 0)}) exitWith { _hasContraband = true; };
            } forEach _cargo;

            if (_hasContraband) then {
                _isSuspicious = true;
                _eyeIcon = "media\icons\eye_yellow.paa";
                if (count (allUnits select {side _x == east && _x distance _veh < 4}) > 0) then { _isUndercover = false; };
            };

            private _checkguards = allUnits select {side _x == east && _x distance player < 25};
            if (count _checkguards > 0) then {
                if (speed player < 2) then {
                    private _insTime = (player getVariable ["AGS_inspectTimer", 0]) + 1;
                    player setVariable ["AGS_inspectTimer", _insTime];
                    if (_insTime > 5) then { player setVariable ["AGS_suspicionLevel", -15]; player setVariable ["AGS_inspectTimer", 0]; };
                };
            };
        };

        // --- 4. APPLY STATUS ---
        if (_isUndercover) then {
            if (!captive player) then { [player, true] remoteExec ["setCaptive", 0]; };
            if (_isSuspicious) then { _eyeIcon = "media\icons\eye_yellow.paa"; };
        } else {
            if (captive player) then { [player, false] remoteExec ["setCaptive", 0]; };
            _eyeIcon = "media\icons\eye_red.paa";
            player setVariable ["AGS_suspicionLevel", 0];
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
            private _investigator = [_witnesses, _unit] call BIS_fnc_nearestPosition;
            _investigator doMove (getPos _unit);
            player setVariable ["AGS_suspicionLevel", 10]; 
        };
    };
    _damage
}];
