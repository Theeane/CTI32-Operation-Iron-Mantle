/* Author: Theane / Gemini
    Project: Operation Iron Mantle
    Description: Populates the listbox and handles Tech/Tier requirements.
    Language: English
*/

params ["_category"];
disableSerialization;

private _display = findDisplay 9000;
if (isNull _display) exitWith {};

private _listBox = _display displayCtrl 9002;
private _currencyText = _display displayCtrl 9001;

// 1. Update the Currency display (S)
private _currentCurrency = missionNamespace getVariable ["KPIN_Currency", 0];
_currencyText ctrlSetText format["Digital Currency: %1 S", _currentCurrency];

lbClear _listBox;

// 2. Fetch Tech & Tier status for filtering
private _hasMobileTech = missionNamespace getVariable ["KPIN_Upgrade_MobileRespawn", false];
private _currentTier = missionNamespace getVariable ["KPIN_CurrentTier", 1];

// 3. Get data from the KPIN config hashmap
private _items = missionNamespace getVariable ["KPIN_BuyMenu_Data", createHashMap] getOrDefault [_category, []];

{
    _x params ["_name", "_classname", "_cost", "_icon", ["_reqTech", false], ["_reqTier", 1]];
    
    // --- TECH & TIER CHECK ---
    // Om föremålet kräver Mobile Tech men vi inte har det, eller om Tier är för lågt:
    private _canSee = true;
    if (_reqTech && !_hasMobileTech) then { _canSee = false; };
    if (_currentTier < _reqTier) then { _canSee = false; };

    if (_canSee) then {
        // Add to list: "Name [Cost S]"
        private _index = _listBox lbAdd format["%1 [%2 S]", _name, _cost];
        _listBox lbSetPicture [_index, _icon];
        _listBox lbSetData [_index, _classname]; 
        _listBox lbSetValue [_index, _cost];     
        
        // Visual feedback: Color red if too expensive
        if (_currentCurrency < _cost) then {
            _listBox lbSetColor [_index, [1, 0, 0, 0.5]];
        };
    };
} forEach _items;

if (lbSize _listBox > 0) then {
    _listBox lbSetCurSel 0; 
};
