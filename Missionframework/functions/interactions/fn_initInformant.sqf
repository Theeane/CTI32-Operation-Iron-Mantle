/* Author: Theeane
    Description: Adds the 5-second circular UI interaction to an informant.
    Handles different rewards based on player gear (Civilian, Military Undercover, NATO).
*/

params ["_unit"];

[
    _unit,
    "Talk to Informant",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_talk_ca.paa",
    "\a3\ui_f\data\IGUI\Cfg\HoldActions\holdAction_talk_ca.paa",
    "_this distance _target < 3",
    "_caller distance _target < 3",
    { player playActionNow "GestureHi"; }, // Start animation
    { if (diag_tickTime % 2 < 0.1) then { player playActionNow "GestureHi"; }; }, // Loop animation
    {
        // --- SUCCESS LOGIC ---
        params ["_target", "_caller"];
        
        // 1. Check Player Gear
        private _isUndercoverCivilian = _caller getVariable ["GVAR_isUndercover", false];
        private _isMilUndercover = _caller getVariable ["GVAR_isMilUndercover", false]; // Din specifika mil-undercover variabel

        // 2. Determine Reward
        if (_isUndercoverCivilian) then {
            // CIVILIAN UNDERCOVER: Open Trade Menu / Special Quests
            [_target, _caller] spawn CTI_fnc_undercoverTrade;
            ["TaskSucceeded", ["", "Deal established. Check trade options."]] call BIS_fnc_showNotification;
        } else {
            if (_isMilUndercover) then {
                // MILITARY UNDERCOVER: Tactical Leaks / Codes
                [GVAR_Economy_Intel_CivilianTalk * 3] call CTI_fnc_addIntel;
                ["TaskSucceeded", ["", "Tactical data received from 'ally'."]] call BIS_fnc_showNotification;
            } else {
                // NATO GEAR: Basic +5 Intel only
                [5] call CTI_fnc_addIntel;
                ["TaskSucceeded", ["", "Basic intel gathered. Soldier remains hostile."]] call BIS_fnc_showNotification;
                _target sideChat "I've told you what I know. Now leave before my squad sees us!";
            };
        };

        // 3. Cleanup
        _target setVariable ["GVAR_isQuestioned", true, true];
    },
    { player playActionNow "GestureNo"; }, // Fail animation
    [],
    5, // 5 SECONDS DURATION
    10,
    true,
    false
] call BIS_fnc_holdActionAdd;
