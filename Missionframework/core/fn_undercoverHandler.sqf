/*
    Author: Theane using Gemini (AGS Project)
    Description: Advanced Undercover & Rank-Based Infiltration System.
    Rules: 
    - Full Gear (Uniform+Vest+Helmet) = Green Eye (Trusted).
    - Detection distance based on AI Rank (Leader: 2m, Private: 1m).
    - Uniform Only = Yellow Eye (Permanent Suspicion).
    - Missing Uniform = Red Eye (Immediate Reveal).
*/

if (!hasInterface) exitWith {};

cutRsc ["AGS_Undercover_Eye", "PLAIN"];

[] spawn {
    private _ctrl = uiNamespace getVariable ["AGS_ctrl_eye", controlNull];
    
    // --- CONFIGURATION ---
    private _civilianUniforms = ["U_C_Poloshirt_blue", "U_C_Poloshirt_burgundy", "U_C_HunterBody_grn"]; 
    private _enemyUniforms    = ["U_O_CombatUniform_ocamo", "U_O_T_Soldier_F"];
    private _enemyVests       = ["V_HarnessO_brn", "V_TacVest_khk"];
    private _enemyHeadgear    = ["H_HelmetO_ocamo", "H_HelmetLeaderO_ocamo"];

    while {alive player} do {
        uiSleep 2;
        if (isNull _ctrl) then { _ctrl = uiNamespace getVariable ["AGS_ctrl_eye", controlNull]; };

        private _isUndercover = true;
        private _isSuspicious = false;
        private _eyeIcon = "media\icons\eye_green.paa";
        
        // Gear Status Checks
        private _hasEnemyUniform = (uniform player in _enemyUniforms);
        private _hasEnemyVest    = (vest player in _enemyVests);
        private _hasEnemyHelmet  = (headgear player in _enemyHeadgear);
        private _isCivilian      = (uniform player in _civilianUniforms);

        // --- LOGIC A: ENEMY INFILTRATION ---
        if (_hasEnemyUniform) then {
            if (_hasEnemyVest && _hasEnemyHelmet) then {
                // FULL GEAR: Green Eye, Weapons Allowed
                _isSuspicious = false; 
                _eyeIcon = "media\icons\eye_green.paa";
            } else {
                // PARTIAL GEAR: Uniform only = Permanent Yellow
                if (_hasEnemyVest || _hasEnemyHelmet) then {
                   _isUndercover = false; // Immediate Red if wearing vest/helmet without uniform
                } else {
                   _isSuspicious = true;
                   _eyeIcon = "media\icons\eye_yellow.paa";
                };
            };

            // RANK-BASED PROXIMITY DETECTION
            private _nearEnemies = allUnits select {side _x == east && _x distance player < 5};
            {
                private _dist = _x distance player;
                private _rank = rank _x;
                // Leaders/Officers spot you at 2m, others at 1m
                private _detectRange = if (_rank in ["SERGEANT", "LIEUTENANT", "CAPTAIN", "MAJOR", "COLONEL"]) then {2.2} else {1.2};
                
                if (_dist < _detectRange) exitWith { _isUndercover = false; };
            } forEach _nearEnemies;

            // Identity Stare Logic
            private _suspFactor = if (_hasEnemyVest && _hasEnemyHelmet) then {1} else {4}; // Faster if missing gear
            private _staringUnits = allUnits select {side _x == east && _x distance player < 15};
            if (count _staringUnits > 0) then {
                private _susp = player getVariable ["AGS_suspicionLevel", 0];
                player setVariable ["AGS_suspicionLevel", _susp + _suspFactor];
                if (_susp > 15) then { _isUndercover = false; };
            };
        } 
        // --- LOGIC B: CIVILIAN SCOUTING ---
        else {
            if (_hasEnemyVest || _hasEnemyHelmet) then {
                _isUndercover = false; // Illegal gear on civilian
            } else {
                if (_isCivilian) then {
                    if (currentWeapon player != "" && {currentWeapon player != binocular}) then { _isUndercover = false; };
                    
                    private _pos = getPos player;
                    private _zones = missionNamespace getVariable ["AGS_all_mission_zones", []] select {!(_x getVariable ["AGS_isCaptured", false])};
                    {
                        if (_pos distance _x < 150) exitWith {
                            _isSuspicious = true;
                            if (_pos distance _x < 50) then { _isUndercover = false; };
                        };
                    } forEach _zones;
                } else {
                    _isUndercover = false;
                };
            };
        };

        // Final State Sync
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
