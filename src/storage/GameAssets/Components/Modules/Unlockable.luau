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
		local storage = tycoonStorage:FindFirstChild(self.Tycoon.Owner.Name)
		local buttonsFolder

		if storage then
			buttonsFolder = storage:FindFirstChild("Buttons")
		end

		if not buttonsFolder then return end

		for _, button in ipairs(buttonsFolder:GetChildren()) do
			local id2 = button:GetAttribute("ID")
			local item = buyables[id2]

			if item.Required == id then
				print(id2, item.Required, id, "Correct")
				self.Tycoon:PublishTopic("SetVisible", true)
			end
		end

		self.Tycoon:Unlock(self.Instance, id)
		self.Subscription:Disconnect()
	end
end

return unlockable