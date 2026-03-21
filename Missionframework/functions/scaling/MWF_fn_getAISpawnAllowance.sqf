/*
    Author: Theane / ChatGPT
    Function: MWF_fn_getAISpawnAllowance
    Project: Military War Framework

    Description:
    Returns how many additional AI units may be spawned without exceeding the
    current session Dynamic Unit Cap.
*/

params [
    ["_desired", 0, [0]],
    ["_reserve", 0, [0]],
    ["_forceMinimum", false, [false]]
];

private _cap = missionNamespace getVariable ["MWF_DynamicUnitCap", 100];
private _currentAI = count (allUnits select {
    alive _x &&
    {!isPlayer _x} &&
    {side _x != sideLogic}
});

private _remaining = (_cap - _currentAI - (_reserve max 0)) max 0;
private _allowed = (_desired max 0) min _remaining;

if (_forceMinimum && {_desired > 0} && {_remaining > 0}) then {
    _allowed = _allowed max 1;
};

_allowed
