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

return MainModule
