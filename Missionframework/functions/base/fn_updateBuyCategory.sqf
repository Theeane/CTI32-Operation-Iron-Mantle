/* Author: Theane
    Project: Operation Iron Mantle
    Description: Populates the listbox with items from the selected category.
    Language: English
*/

params ["_category"];
disableSerialization;

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

private _listBox = _display displayCtrl 9002;
private _supplyText = _display displayCtrl 9001;

// 1. Update the supply display from the correct KPIN variable
private _currentSupplies = missionNamespace getVariable ["KPIN_Supplies", 0];
_supplyText ctrlSetText format["Supplies: %1", _currentSupplies];

lbClear _listBox;

// 2. Get data from the KPIN config hashmap
private _items = missionNamespace getVariable ["KPIN_BuyMenu_Data", createHashMap] getOrDefault [_category, []];

{
    _x params ["_name", "_classname", "_cost", "_icon"];
    
    // Add to list: "Name [Cost Supplies]"
    private _index = _listBox lbAdd format["%1 [%2 S]", _name, _cost];
    _listBox lbSetPicture [_index, _icon];
    _listBox lbSetData [_index, _classname]; 
    _listBox lbSetValue [_index, _cost];     
    
    // 3. Visual feedback: Color red if too expensive
    if (_currentSupplies < _cost) then {
        _listBox lbSetColor [_index, [1, 0, 0, 0.5]];
    };
} forEach _items;

if (lbSize _listBox > 0) then {
    _listBox lbSetCurSel 0; 
};
