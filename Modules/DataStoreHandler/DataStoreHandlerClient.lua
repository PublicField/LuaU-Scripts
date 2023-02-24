--This module is created to get data from replicated instance. you must know your replicated instance to use.

local HttpService = game:GetService("HttpService")

local ClientDataStoreHandler = {}

function ClientDataStoreHandler:Init(replicatedInstance : Instance)
	if not replicatedInstance or typeof(replicatedInstance) ~= "Instance" then
		error("Replicated instance is invalid and cannot be used.")
		return false
	end
	
	local self = {}
	
	function self:ConvertTableToJSON(T : {any}) : string | nil --Returns table converted to JSON as a string.
		local success, value = pcall(HttpService.JSONEncode, HttpService, T)

		if not success then
			return nil
		end

		return value
	end

	function self:ConvertJSONToTable(json : string) : {any} | any --Returns JSON converted to table.
		local success, value = pcall(HttpService.JSONDecode, HttpService, json)

		if not success then
			return json
		end

		return value
	end
	
	function self:Get(index : string) --Gets data from replicated instance. Converts JSONs to table.
		local Attribute = self:ConvertJSONToTable(replicatedInstance:GetAttribute(index))

		return Attribute
	end
	
	function self:RetrieveData() : {any} --Returns table with replicated instance data and converts JSONs to tables if possible.
		local Attributes = replicatedInstance:GetAttributes()
		local RetrievedData = {}

		for i,v in Attributes do
			RetrievedData[i] = self:Get(i)
		end

		return RetrievedData
	end
	
	return self
end

return ClientDataStoreHandler
