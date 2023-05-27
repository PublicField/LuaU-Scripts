-- DataStoreHandler module created by DevRobloxian in 2023. Easy to use and FREE!

--[[ INFO about properties in DataStoreHandler.new function that i recommend you to use.
	PLEASE provide your own replicated instance(Folder, Model, anything that supports attributes) in replicatedInstance property in DataStoreHandler.new function to replicate data between server and client.
	PLEASE provide your own data store name in dataStoreName property in DataStoreHandler.new function.
	PLEASE provide your own base data in baseData property in DataStoreHandler.new function.
]]

-- Prefix is begin of the data name in DataStore. You can use it to sort data. Example: "User_" .. Player.UserId, "User_" is prefix.

local DataStoreService = game:GetService("DataStoreService")

local Main = script.Parent
local Utility = require(Main:WaitForChild("Utility"))

local DataStoreHandler = {}
DataStoreHandler.__index = DataStoreHandler

function DataStoreHandler.new(replicatedInstance : Instance?, dataStoreName : string?, prefix : string?, baseData : {[string]: any}?) --creates a DataStoreHandler with given properties.
	local self = {}
	self._dataStore = typeof(dataStoreName) == "string" and DataStoreService:GetDataStore(dataStoreName) or DataStoreService:GetDataStore("DataStoreHandlerData")
	self._prefix = typeof(prefix) == "string" and prefix or "Prefix_"
	self._baseData = typeof(baseData) == "table" and baseData or {}
	self._replicatedInstance = typeof(replicatedInstance) == "Instance" and replicatedInstance or (function()
		local Folder = Instance.new("Folder", workspace)
		Folder.Name = "DataStoreInfo"

		return Folder
	end)()

	return setmetatable(self, DataStoreHandler)
end

function DataStoreHandler:Get(index : string) --Gets data from replicated instance. Converts JSONs to table.
	local Attribute = Utility.ConvertJSONToTable(self._replicatedInstance:GetAttribute(index))

	return Attribute
end

function DataStoreHandler:RetrieveData(convertToJSON : boolean?) : {} | string --Returns table with replicated instance data and converts JSONs to tables if possible. converts to JSON if true is passed in the arguments.
	local Attributes = self._replicatedInstance:GetAttributes()
	local RetrievedData = {} :: {any}

	for i,v in Attributes do
		RetrievedData[i] = self:Get(i)
	end

	if convertToJSON then
		RetrievedData = Utility.ConvertTableToJSON(RetrievedData)
	end

	return RetrievedData
end

function DataStoreHandler:RetrieveDataStore(data : string | number) : {any} --Returns table with data from DataStore and converts tables to JSONs.
	local Data = self:GetDataStore(data)
	local RetrieveDataStore = {}

	for i,v in Data do
		if typeof(v) == "table" then
			RetrieveDataStore[i] = Utility.ConvertTableToJSON(v) or "[]"
		else
			RetrieveDataStore[i] = v
		end
	end

	return RetrieveDataStore
end

function DataStoreHandler:GetDataStore(data : string) : {any} --Returns data from DataStore. if data doesn't exist or invalid it gets replaced with base data and returns it.
	local success, result = pcall(self._dataStore.GetAsync, self._dataStore, self._prefix .. data)

	if not success then
		return self:GetDataStore(data)
	end

	local convertedToTableValue = Utility.ConvertJSONToTable(result)

	if typeof(convertedToTableValue) ~= "table" or not next(convertedToTableValue) then
		self:SetDataStore(data, self._baseData)
		return self._baseData
	end

	return convertedToTableValue
end

function DataStoreHandler:SetDataStore(data : string, value : any) : boolean --Sets new data in DataStore. Calls itself until completes successfully.
	local success, result = pcall(self._dataStore.SetAsync, self._dataStore, self._prefix .. data, value)

	if not success then
		self:SetDataStore(data, value)
	end

	return true
end

function DataStoreHandler:UpdateData(data : string) --Retrieves DataStore and sets new values in replicated instance.
	for i,v in self:RetrieveDataStore(data) do
		self._replicatedInstance:SetAttribute(i, v)
	end
end

function DataStoreHandler:UpdateDataStore(data : string) --Retrieves replicated instance data and updates DataStore. Converts tables to JSONs.
	self:SetDataStore(data, self:RetrieveData(true))
end

function DataStoreHandler:Set(index : string, value : any) --Sets new value in replicated instance. Converts JSONs to table.
	local NewValue = typeof(value) == "table" and Utility.ConvertTableToJSON(value) or value

	self._replicatedInstance:SetAttribute(index, NewValue)
end

return DataStoreHandler
