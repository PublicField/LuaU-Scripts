--This module is created to get data from replicated instance. you must know your replicated instance to use.

local Main = script.Parent
local Utility = require(Main:WaitForChild("Utility"))

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
	local Attribute = Utility.ConvertJSONToTable(self._replicatedInstance:GetAttribute(index))

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
