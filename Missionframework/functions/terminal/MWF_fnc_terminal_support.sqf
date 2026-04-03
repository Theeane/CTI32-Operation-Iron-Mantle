/*
    Data-backed support terminal helper.
*/
params [["_mode", "OPEN", [""]],["_payload", nil],["_buyer", player, [objNull]]];
private _modeUpper = toUpper _mode;
private _defaults = [["MWF_Support_Group1", "Recon Squad"],["MWF_Support_Group2", "Rifle Squad"],["MWF_Support_Group3", "AT Team"],["MWF_Support_Group4", "Mechanized Squad"],["MWF_Support_Group5", "Air Assault Team"]];
private _meta = missionNamespace getVariable ["MWF_Support_GroupMeta", _defaults];
if !(_meta isEqualType []) then { _meta = _defaults; };
switch (_modeUpper) do {
    case "GET_ENTRIES": {
        private _entries = [];
        {
            private _varName = _x param [0, "", [""]];
            private _name = _x param [1, _varName, [""]];
            private _template = missionNamespace getVariable [_varName, []];
            if !(_template isEqualTo []) then {
                _template params [["_vehicleClass","",[""]],["_unitClasses",[],[[]]],["_price",0,[0]],["_minTier",1,[0]]];
                _entries pushBack [_forEachIndex + 1, _varName, _name, _vehicleClass, _unitClasses, _price, _minTier];
            };
        } forEach _meta;
        _entries
    };
    case "BUILD_GROUP": { [_payload, _buyer] call MWF_fnc_spawnSupportGroup };
    case "BUILD_UNIT": { [_payload, _buyer] call MWF_fnc_spawnSupportUnit };
    default { [] };
};
