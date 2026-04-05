/*
    Client-side Zeus UI pruning for Base Build.
    Goal: keep the create tree focused on Objects while hiding side/vehicle/marker clutter.
*/
if (!hasInterface) exitWith { false };

disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) then {
    _display = findDisplay 312;
};
if (isNull _display) exitWith { false };

private _keepRootTokens = ["object", "objects"];
private _blockedRootTokens = [
    "all", "blufor", "opfor", "independent", "civilian",
    "vehicle", "vehicles", "empty", "empty vehicles", "men", "man",
    "group", "groups", "module", "modules",
    "marker", "markers", "waypoint", "waypoints",
    "trigger", "triggers", "system", "systems"
];
private _blockedAnyTokens = ["wreck", "wrecks", "ruin", "ruins", "debris", "destroyed", "damaged"];

private _shouldDeleteNode = {
    params ["_text", "_depth", "_keepTokens", "_blockedRoots", "_blockedAny"];

    private _txt = toLower _text;
    if (_txt isEqualTo "") exitWith { false };

    if ((_blockedAny findIf { _txt find _x > -1 }) > -1) exitWith { true };

    private _hasKeep = (_keepTokens findIf { _txt find _x > -1 }) > -1;
    if (_hasKeep) exitWith { false };

    /* At root and first category level, keep only Objects and delete everything else. */
    if (_depth <= 1) exitWith { true };

    false
};

private _pruneTree = {
    params ["_ctrl", "_path", "_keepTokens", "_blockedRoots", "_blockedAny", "_shouldDeleteNode", "_pruneTree"];

    private _count = tvCount [_ctrl, _path];
    for "_i" from (_count - 1) to 0 step -1 do {
        private _childPath = +_path;
        _childPath pushBack _i;

        private _txt = tvText [_ctrl, _childPath];
        private _depth = count _childPath;

        if ([_txt, _depth, _keepTokens, _blockedRoots, _blockedAny] call _shouldDeleteNode) then {
            _ctrl tvDelete _childPath;
        } else {
            [_ctrl, _childPath, _keepTokens, _blockedRoots, _blockedAny, _shouldDeleteNode, _pruneTree] call _pruneTree;
        };
    };
};

{
    private _ctrl = _x;

    if ((ctrlType _ctrl) isEqualTo 12) then {
        [_ctrl, [], _keepRootTokens, _blockedRootTokens, _blockedAnyTokens, _shouldDeleteNode, _pruneTree] call _pruneTree;
    };

    private _label = toLower (ctrlText _ctrl);
    if !(_label isEqualTo "") then {
        private _hide = false;

        if ((_blockedAnyTokens findIf { _label find _x > -1 }) > -1) then {
            _hide = true;
        };

        if (!_hide && {(_blockedRootTokens findIf { _label find _x > -1 }) > -1} && {(_keepRootTokens findIf { _label find _x > -1 }) isEqualTo -1}) then {
            _hide = true;
        };

        if (!_hide && {(_label find "all") > -1} && {(_keepRootTokens findIf { _label find _x > -1 }) isEqualTo -1}) then {
            _hide = true;
        };

        if (_hide) then {
            _ctrl ctrlShow false;
        };
    };
} forEach (allControls _display);

true
