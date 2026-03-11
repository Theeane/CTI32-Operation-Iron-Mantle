/* Author: Theeane
    Description: Populates the listbox with items from the selected category.
*/
params ["_category"];
disableSerialization;

private _display = findDisplay 9000;
private _listBox = _display displayCtrl 9002;
private _supplyText = _display displayCtrl 9001;

// Update the supply display first
_supplyText ctrlSetText format["Supplies: %1", GVAR_Economy_Supplies];

lbClear _listBox;

// Get data from our global config hashmap
private _items = GVAR_BuyMenu_Data getOrDefault [_category, []];

{
    _x params ["_name", "_classname", "_cost", "_icon"];
    
    // Add to list: "Name [Cost Supplies]"
    private _index = _listBox lbAdd format["%1 [%2 S]", _name, _cost];
    _listBox lbSetPicture [_index, _icon];
    _listBox lbSetData [_index, _classname]; // Store classname for spawning
    _listBox lbSetValue [_index, _cost];     // Store cost for the check
    
    // Color red if too expensive
    if (GVAR_Economy_Supplies < _cost) then {
        _listBox lbSetColor [_index, [1, 0, 0, 0.5]];
    };
} forEach _items;

_listBox lbSetCurSel 0; // Select first item automatically
