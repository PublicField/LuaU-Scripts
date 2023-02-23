local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")

local MainModule = {}
type MoverType = "BodyPosition" | "BodyVelocity" | "BodyGyro"

function MainModule.Weld(part0 : BasePart, part1 : BasePart, c0 : CFrame?, name : string?)
	local weld = Instance.new("Weld")
	weld.Name = name or "Weld"
	weld.Part0 = part0
	weld.Part1 = part1
	if c0 then
		weld.C0 = c0
	end
	weld.Parent = part0
	return weld
end

function MainModule.CreateSound(sound : Sound, parent : Instance)
	local Sound = sound:Clone()
	Sound.Parent = parent

	if Sound.PlayOnRemove then
		return Sound:Destroy()
	end

	Sound:Play()
	Sound.Ended:Once(function()
		Sound:Destroy()
	end)

	return Sound
end

function MainModule.Lerp(start : number, goal : number, alpha : number)
	return start + (goal - start) * alpha
end

function MainModule.BlurEffect(size : number, duration : number)
	task.spawn(function()
		local Blur = Lighting:FindFirstChild("Blur") or Instance.new("BlurEffect", Lighting)
		Blur.Size = size

		for index = 1, duration do
			Blur.Size = Blur.Size - size / duration
			task.wait(0.03)
		end
	end)
end

function MainModule.CreateTween(ins: Instance, tweenInfo: {any}, properties: {[string]: any}, play: boolean?)
	local tween = TweenService:Create(ins, TweenInfo.new(unpack(tweenInfo)), properties)
	if play then
		tween:Play()
	end

	return tween
end

function MainModule.CreateBodyMover(MoverType: MoverType, Parent: Instance, MaxForce: Vector3, Force: Vector3 | CFrame, lifeTime: number?)
	local Properties = {
		BodyVelocity = {"Velocity", "MaxForce"},
		BodyPosition = {"Position", "MaxForce"},
		BodyGyro = {"CFrame", "MaxTorque"}
	}

	for _, ins in Parent:GetChildren() do
		if ins:IsA("BodyMover") then
			ins.Name = "Removing"
			ins:Destroy()
		end
	end

	local MoverProperties = Properties[MoverType]
	local Mover = Instance.new(MoverType)
	Mover.Name = "MainModuleBody" .. MoverType
	Mover[MoverProperties[1]] = Force
	Mover[MoverProperties[2]] = MaxForce
	Mover.Parent = Parent

	if lifeTime then
		task.delay(lifeTime, Mover.Destroy, Mover)
	end

	return Mover
end

function MainModule.GetAttributeWrapper(ins: Instance)
	return setmetatable({}, {
		__index = function(self, key)
			return ins:GetAttribute(key)
		end,

		__newindex = function(self, key, value)
			return ins:SetAttribute(key, value)
		end,
	})
end

function MainModule.ChangeObjectsPropertie(instance : {}, instanceType : string, modify : string, propertie : string, value : any, exception: {Instance}?)
	for i,child in instance["Get" .. modify](instance) do
		if child:IsA(instanceType) then
			if exception and table.find(exception, child) then
				continue
			end
			child[propertie] = value
		end
	end
end

function MainModule.TweenObjectsPropertie(instance : {}, instanceType : string, modify : string, tweenInfo : {any}, propertie : {[string]: any}, exception: {Instance}?)
	for i,child in instance["Get" .. modify](instance) do
		if child:IsA(instanceType) then
			if exception and table.find(exception, child) then
				continue
			end
			MainModule.CreateTween(child, tweenInfo, propertie, true)
		end
	end
end

function MainModule.PlayAnimation(character : Model, animation : Animation, ...): AnimationTrack | boolean
	local AnimationController = character:FindFirstChild("Humanoid") or character:FindFirstChild("AnimationController")
	local Animator = AnimationController and AnimationController:FindFirstChild("Animator") :: Animator

	if not Animator then
		return false
	end

	local AnimationTrack = Animator:LoadAnimation(animation)
	AnimationTrack:Play(...)

	return AnimationTrack
end

function MainModule.CheckCharacter(character : Model)
	if not character then
		return false
	end

	for _, name in {"HumanoidRootPart", "Humanoid", "Head", "Left Arm", "Right Arm", "Left Leg", "Right Leg"} do
		local inst = character:FindFirstChild(name)
		if not inst then
			return false
		end

		if name == "Humanoid" and (inst.Health <= 0 or inst.Health ~= inst.Health) then
			return false
		end
	end

	return true
end

function MainModule.AddTempAttribute(ins: Instance, attributeName: string, attributeTime: number?)
	local attributeValue = ins:GetAttribute(attributeName) or 0
	attributeValue += 1

	ins:SetAttribute(attributeName, attributeValue)

	if attributeTime then
		task.delay(attributeTime, MainModule.RemoveTempAttribute, ins, attributeName)
	end
end

function MainModule.RemoveTempAttribute(ins: Instance, attributeName: string)
	local attributeValue = ins:GetAttribute(attributeName) or 1
	attributeValue -= 1

	ins:SetAttribute(attributeName, attributeValue)
	if attributeValue <= 0 then
		ins:SetAttribute(attributeName, nil)
	end
end

function MainModule.CalculateMagnitude(firstPosition : Vector3, secondPosition : Vector3)
	return (firstPosition - secondPosition).Magnitude
end

--NOTE: Another script starts here. put it here because RoDevs requires only ONE link.

-- DataStoreHandler module created by DevRobloxian in 2023. Easy to use and FREE!

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

return {MainModule, DataStoreHandler}