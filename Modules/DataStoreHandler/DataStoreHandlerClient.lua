--This module is created to get data from replicated instance. you must know your replicated instance to use.

local HttpService = game:GetService("HttpService")

local function ConvertTableToJSON(T : {any}) : string | nil --Returns table converted to JSON as a string.
	local success, value = pcall(HttpService.JSONEncode, HttpService, T)

	if not success then
		return nil
	end

	return value
end

local function ConvertJSONToTable(json : string) : {any} | any --Returns JSON converted to table.
	local success, value = pcall(HttpService.JSONDecode, HttpService, json)

	if not success then
		return json
	end

	return value
end

local ClientDataStoreHandler = {}
ClientDataStoreHandler.__index = ClientDataStoreHandler

function ClientDataStoreHandler.new(replicatedInstance : Instance)
	if typeof(replicatedInstance) ~= "Instance" then
		error("Replicated instance is invalid and cannot be used.")
	end

	local self = {}
	self._replicatedInstance = replicatedInstance

	return setmetatable(self, ClientDataStoreHandler)
end

function ClientDataStoreHandler:Get(index : string) --Gets data from replicated instance. Converts JSONs to table.
	local Attribute = ConvertJSONToTable(self._replicatedInstance:GetAttribute(index))

	return Attribute
end

function ClientDataStoreHandler:RetrieveData() : {any} --Returns table with replicated instance data and converts JSONs to tables if possible.
	local Attributes = self._replicatedInstance:GetAttributes()
	local RetrievedData = {}

	for i,v in Attributes do
		RetrievedData[i] = self:Get(i)
	end

	return RetrievedData
end

return ClientDataStoreHandler
