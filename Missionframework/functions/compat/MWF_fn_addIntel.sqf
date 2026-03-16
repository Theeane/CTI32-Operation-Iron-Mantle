params [["_amount", 0, [0]]];
if (!isServer) exitWith {
    [_amount] remoteExecCall ["MWF_fnc_addIntel", 2];
};
[_amount, "INTEL"] call MWF_fnc_addResource;
