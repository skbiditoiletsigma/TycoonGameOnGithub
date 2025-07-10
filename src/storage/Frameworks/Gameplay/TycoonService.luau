local serverStorage = game:GetService("ServerStorage")
local serverScriptService = game:GetService("ServerScriptService")
local collectionService = game:GetService("CollectionService")

local serverModules = serverScriptService.Modules

local gameAssets = serverStorage.GameAssets
local components = gameAssets.Components

local modules = components.Modules
local models = components.Models

local dataHandler = require(serverModules.DataHandler)

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

function Tycoon.new(Player : Player, Spawn : Part)
	local self = setmetatable({}, Tycoon)
	self.Owner = Player
	
	self._TopicEvent = Instance.new("BindableEvent")
	self._Spawn = Spawn
		
	return self
end

function Tycoon:Init()
	self.Tycoon = LocalFunctions.CreateTycoon(template, self._Spawn.CFrame, self.Owner)
	self._Spawn:SetAttribute("Occupied", true)

	self.Owner.RespawnLocation = self.Tycoon.OwnerSpawn
	
	self:LockAll()
	self:LoadUnlocked()
	self:WaitForExit()
end

function Tycoon:Lock(instance)
	instance.Parent = tycoonStorage:FindFirstChild(self.Owner.Name)
	self:CreateInstance(instance, modules.Unlockable)
end

function Tycoon:Unlock(instance	, id)
	dataHandler.AddUnlockableId(self.Owner, id)
	collectionService:RemoveTag(instance, "Unlockable")
	
	self:AddInstances(instance)
	instance.Parent = self.Tycoon.Assets
end

function Tycoon:LoadUnlocked()
	local unlockedIds = dataHandler.GetUnlockedIds(self.Owner)

	for _, id in pairs(unlockedIds) do
		self:PublishTopic("Button", id)
	end
end

function Tycoon:LockAll()
	for _, instance in ipairs(self.Tycoon.Assets:GetDescendants()) do
		if collectionService:HasTag(instance, "Unlockable") then
			self:Lock(instance)
		else
			self:AddInstances(instance)
		end
	end

	for _, instance in ipairs(self.Tycoon.Walls:GetDescendants()) do
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

function Tycoon:WaitForExit()
	dataHandler.PlayerRemoving:Connect(function(player)
		if self.Owner == player then
			self:Destroy()
		end
	end)
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
	self._Spawn:SetAttribute("Occupied", false)
	self._TopicEvent:Destroy()
end

return Tycoon