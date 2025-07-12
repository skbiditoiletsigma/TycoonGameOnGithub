local unlockable = {}
unlockable.__index = unlockable

local ServerStorage = game:GetService("ServerStorage")
local tycoonStorage = ServerStorage:WaitForChild("TycoonStorage")

local replicatedStorage = game:GetService("ReplicatedStorage")

local modules = replicatedStorage.Modules
local items = modules.Items
local buyables = require(items.Buyables)

function unlockable.new(tycoon, instance)
	local self = setmetatable({}, unlockable)
	
	self.Tycoon = tycoon
	self.Instance = instance
	
	return self
end

function unlockable:Init()
	self.Subscription = self.Tycoon:SubscribeTopic("Button", function(...)
		self:OnButtonPressed(...)
	end)
end

function unlockable:OnButtonPressed(id)
	if id == self.Instance:GetAttribute("UnlockableID") then
		-- Publish the item ID that was unlocked so buttons can check if they should become visible
		self.Tycoon:PublishTopic("ItemUnlocked", id)
		
		-- Unlock this instance
		self.Tycoon:Unlock(self.Instance, id)
		self.Subscription:Disconnect()
	end
end

return unlockable