local serverStorage = game:GetService("ServerStorage")
local collectionService = game:GetService("CollectionService")

local gameAssets = serverStorage.GameAssets
local components = gameAssets.Components

local modules = components.Modules
local models = components.Models

local template = serverStorage.Template

local tycoonStorage = serverStorage.TycoonStorage

local Tycoon = {}
local LocalFunctions = {}

function LocalFunctions.CreateTycoon(Template : Model, CFrameValue, Player : Player)
	local NewTemplate = Template:Clone()
	
	NewTemplate:SetPrimaryPartCFrame(CFrameValue)
	NewTemplate.Parent = workspace.Tycoons
	NewTemplate.Name = "Tycoon_"..Player.UserId

	return NewTemplate
end

Tycoon.__index = Tycoon

function Tycoon.new(Player : Player)
	local self = setmetatable({}, Tycoon)
	self.Owner = Player
	
	self._TopicEvent = Instance.new("BindableEvent")
		
	return self
end

function Tycoon:Init()
	self.Tycoon = LocalFunctions.CreateTycoon(template, CFrame.new(0,1,0), self.Owner)
	self:LockAll()
end

function Tycoon:Lock(instance)
	instance.Parent = tycoonStorage
	self:CreateInstance(instance, modules.Unlockable)
end

function Tycoon:Unlock(instance	, id)
	collectionService:RemoveTag(instance, "Unlockable")
	
	self:AddInstances(instance)
	instance.Parent = self.Tycoon.Assets
end

function Tycoon:LockAll()
	for _, instance in ipairs(self.Tycoon.Assets:GetDescendants()) do
		if collectionService:HasTag(instance, "Unlockable") then
			self:Lock(instance)
		else
			self:AddInstances(instance)
		end
	end
	
	for _, instance in ipairs(self.Tycoon.Buttons:GetDescendants()) do
		if collectionService:HasTag(instance, "Unlockable") then
			self:Lock(instance)
		else
			self:AddInstances(instance)
		end
	end
end

function Tycoon:AddInstances(instance)
	for _, tag in ipairs(collectionService:GetTags(instance)) do
		local component = modules:FindFirstChild(tag)
		
		if component then
			self:CreateInstance(instance, component)
		end
	end
end

function Tycoon:CreateInstance(instance, componentScript)
	local compModule = require(componentScript)
	local newComponent = compModule.new(self, instance)
	
	newComponent:Init()
end

function Tycoon:SubscribeTopic(topicName, callback)
	local connection = self._TopicEvent.Event:Connect(function(name, ...)
		if name == topicName then
			callback(...)
		end
	end)
	
	return connection
end

function Tycoon:PublishTopic(topicName, ...)
	self._TopicEvent:Fire(topicName, ...)
end

function Tycoon:Destroy()
	self.Tycoon:Destroy()
	self._TopicEvent:Destroy()
end

return Tycoon