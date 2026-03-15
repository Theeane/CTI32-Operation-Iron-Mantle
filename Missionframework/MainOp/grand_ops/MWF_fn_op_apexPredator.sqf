// Structure: Start -> Mid 1 -> Mid 2 -> Mid 3 -> End | Stealth: Until End
params [["_state", "START"]];
if (_state == "END") then {
    if (!missionNamespace getVariable ["MWF_Op_Detected", false]) then { [400, "SUPPLIES"] call MWF_fnc_addResource; [200, "INTEL"] call MWF_fnc_addResource; };
    missionNamespace setVariable ["MWF_Unlock_Tier5", true, true];
};
