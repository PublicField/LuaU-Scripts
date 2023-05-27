local HttpService = game:GetService("HttpService")

local Utility = {}

function Utility.ConvertTableToJSON(T : {any}) : string | nil --Returns table converted to JSON as a string.
	local success, value = pcall(HttpService.JSONEncode, HttpService, T)

	if not success then
		return nil
	end

	return value
end

function Utility.ConvertJSONToTable(json : string) : {any} | any --Returns JSON converted to table.
	local success, value = pcall(HttpService.JSONDecode, HttpService, json)

	if not success then
		return json
	end

	return value
end

return Utility
