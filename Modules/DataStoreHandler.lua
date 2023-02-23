-- DataStoreHandler module created by DevRobloxian in 2023. Easy to use and FREE!
-- "Enable Studio Access to API Services" must be enabled to use module. Enable it in GameSettings -> Security -> "Enable Studio Access to API Services".


--[[ INFO about properties in DataStoreHandler.new function that i recommend you to use.
	PLEASE provide your own replicated instance(Folder, Model, anything that supports attributes) in replicatedInstance property in DataStoreHandler.new function to replicate data between server and client.
	PLEASE provide your own data store name in dataStoreName property in DataStoreHandler.new function.
	PLEASE provide your own base data in baseData property in DataStoreHandler.new function.
]]

-- Prefix is begin of the data name in DataStore. You can use it to sort data. Example: "User_" .. Player.UserId, "User_" is prefix.


local HttpService = game:GetService("HttpService") --Uses for Encoding and Decoding JSONs.
local DataStoreService = game:GetService("DataStoreService")

local DataStoreHandler = {}

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
	
	function self:RetrieveData(convertToJSON : boolean?) : {} | string --Returns table with replicated instance data and converts JSONs to tables if possible. converts to JSON if true is passed in the arguments.
		local Attributes = self._replicatedInstance:GetAttributes()
		local RetrievedData = {}

		for i,v in Attributes do
			if typeof(v) == "string" then
				RetrievedData[i] = self:ConvertJSONToTable(v) or v
			else
				RetrievedData[i] = v
			end
		end

		if convertToJSON then
			RetrievedData = self:ConvertTableToJSON(RetrievedData)
		end

		return RetrievedData
	end

	function self:RetrieveDataStore(data : string | number) : {any} --Returns table with data from DataStore and converts tables to JSONs.
		local Data = self:GetDataStore(data)
		local RetrieveDataStore = {}

		for i,v in Data do
			if typeof(v) == "table" then
				RetrieveDataStore[i] = self:ConvertTableToJSON(v) or "[]"
			else
				RetrieveDataStore[i] = v
			end
		end

		return RetrieveDataStore
	end
	
	function self:GetDataStore(data : string | number) : {any} --Returns data from DataStore. if data doesn't exist or invalid it gets replaced with base data and returns it.
		local success, result = pcall(self._dataStore.GetAsync, self._dataStore, self._prefix .. data)
		
		if not success then
			return self:GetDataStore(data)
		end

		local convertedToTableValue = self:ConvertJSONToTable(result)
		
		if typeof(convertedToTableValue) ~= "table" or not next(convertedToTableValue) then
			self:SetDataStore(data, self._baseData)
			return self._baseData
		end
		
		return convertedToTableValue
	end
	
	function self:SetDataStore(data : string | number, value : any) : boolean --Sets new data in DataStore. Calls itself until completes successfully.
		local success, result = pcall(self._dataStore.SetAsync, self._dataStore, self._prefix .. data, value)

		if not success then
			self:SetDataStore(data, value)
		end

		return true
	end
	
	function self:UpdateData(data : string | number) --Retrieves DataStore and sets new values in replicated instance.
		for i,v in self:RetrieveDataStore(data) do
			self._replicatedInstance:SetAttribute(i, v)
		end
	end
	
	function self:UpdateDataStore(data : string | number) --Retrieves replicated instance data and updates DataStore. Converts tables to JSONs.
		self:SetDataStore(data, self:RetrieveData(true))
	end
	
	function self:Set(index : string | number, value : any) --Sets new value in replicated instance. Converts JSONs to table.
		local NewValue = typeof(value) == "table" and self:ConvertTableToJSON(value) or value
		
		self._replicatedInstance:SetAttribute(index, NewValue)
	end
	
	function self:Get(index : string | number) --Gets data from replicated instance. Converts JSONs to table.
		local Attribute = self:ConvertJSONToTable(self._replicatedInstace:GetAttribute(index))
		
		return Attribute
	end

	return self
end

return DataStoreHandler
