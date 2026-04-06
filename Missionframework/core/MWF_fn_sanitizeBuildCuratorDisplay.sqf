/*
    Client-side Zeus UI pruning for Base Build.
    Goal: keep the create tree focused on Objects and hide faction / vehicle / marker clutter.
    Ruins and wrecks are intentionally left alone.
*/
if (!hasInterface) exitWith { false };

disableSerialization;
params [["_display", displayNull, [displayNull]]];

if (isNull _display) then {
    _display = findDisplay 312;
};
if (isNull _display) exitWith { false };

private _keepRootTokens = ["object", "objects", "favorite", "favorites", "favourite", "favourites"];
private _blockedTokens = [
    "all", "blufor", "opfor", "independent", "civilian",
    "vehicle", "vehicles", "empty", "empty vehicles",
    "men", "man", "group", "groups",
    "module", "modules", "marker", "markers",
    "waypoint", "waypoints", "trigger", "triggers",
    "system", "systems"
];

private _pruneTree = {
    params ["_ctrl", "_path", "_keepRootTokens", "_blockedTokens", "_pruneTree"];

    private _count = tvCount [_ctrl, _path];
    for "_i" from (_count - 1) to 0 step -1 do {
        private _childPath = +_path;
        _childPath pushBack _i;

        private _txt = toLower (tvText [_ctrl, _childPath]);
        private _depth = count _childPath;
        private _deleteNode = false;

        if (_depth <= 1) then {
            _deleteNode = ((_keepRootTokens findIf { _txt find _x > -1 }) isEqualTo -1);
        } else {
            _deleteNode = ((_blockedTokens findIf { _txt find _x > -1 }) > -1);
        };

        if (_deleteNode) then {
            _ctrl tvDelete _childPath;
        } else {
            [_ctrl, _childPath, _keepRootTokens, _blockedTokens, _pruneTree] call _pruneTree;
        };
    };
};

{
    private _ctrl = _x;

    if ((ctrlType _ctrl) isEqualTo 12) then {
        [_ctrl, [], _keepRootTokens, _blockedTokens, _pruneTree] call _pruneTree;
    };

    private _label = toLower (ctrlText _ctrl);
    if !(_label isEqualTo "") then {
        private _hide = false;

        if ((_blockedTokens findIf { _label find _x > -1 }) > -1) then {
            _hide = true;
        };

        if (_hide) then {
            _ctrl ctrlShow false;
        };
    };
} forEach (allControls _display);

true
