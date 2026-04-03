/*
    Author: OpenAI
    Function: MWF_fnc_openRedeploy
    Description: Opens the dedicated redeploy shell using the DataHub terminal frame.
*/

if (!hasInterface) exitWith { false };
params [["_terminal", objNull, [objNull]], ["_caller", objNull, [objNull]]];

if (!isNull _terminal) then { missionNamespace setVariable ["MWF_CommandTerminal_Object", _terminal]; uiNamespace setVariable ["MWF_DataHub_ContextTerminal", _terminal]; };
if (!isNull _caller) then { missionNamespace setVariable ["MWF_CommandTerminal_User", _caller]; };

private _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
if (isNull _display) then {
    ["OPEN"] call MWF_fnc_dataHub;
    _display = uiNamespace getVariable ["MWF_DataHub_Display", displayNull];
};
if (isNull _display) exitWith { false };

uiNamespace setVariable ["MWF_Redeploy_Active", true];
uiNamespace setVariable ["MWF_Redeploy_Selected", []];
uiNamespace setVariable ["MWF_Redeploy_ReturnMode", "UPGRADES"];

[] call MWF_fnc_redeployRefresh;
true
