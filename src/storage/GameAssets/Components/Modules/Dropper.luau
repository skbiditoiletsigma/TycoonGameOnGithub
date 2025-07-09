local dropper = {}
dropper.__index = dropper

local debris = game:GetService("Debris")

local serverStorage = game:GetService("ServerStorage")
local replicatedStorage = game:GetService("ReplicatedStorage")

local modules = replicatedStorage:WaitForChild("Modules")
local items = modules:WaitForChild("Items")

local drops = serverStorage:WaitForChild("Drops")

local buyables = require(items.Buyables)

function dropper.new(tycoon, instance)
	local self = setmetatable({}, dropper)
	
	self.Tycoon = tycoon
	self.Instance = instance
	self.DropSpawn = instance:WaitForChild("DropPoint").Attachment
		
	return self
end

function dropper:Init()
	self:GetDropValues()
    task.wait()

	coroutine.wrap(function()
		while self.Instance.Parent do
			self:Drop()
			task.wait(self.DropRate)
		end
	end)()
end

function dropper:GetDropValues()
	local item = buyables[self.Instance:GetAttribute("UnlockableID")]

	if item then
		local drop = item.Drop

		if drop then
			self.DropRate = drop.TimeBetweenDrops
			self.DropTemplate = drops:FindFirstChild(drop.Name)
		end
	end
end

function dropper:Drop()
	local newDrop = self.DropTemplate:Clone()
	newDrop.Position = self.DropSpawn.WorldPosition
	newDrop.Parent = self.Instance.Drops
end

return dropper