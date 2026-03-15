// Structure: Start -> Mid 1 -> Mid 2 -> Mid 3 -> End | Stealth: Until Mid 2
params [["_state", "START"]];
if (_state == "MID_2" && !missionNamespace getVariable ["MWF_Op_Detected", false]) then {
    [400, "SUPPLIES"] call MWF_fnc_addResource; [200, "INTEL"] call MWF_fnc_addResource;
};
if (_state == "END") then { missionNamespace setVariable ["MWF_Unlock_Jets", true, true]; };
