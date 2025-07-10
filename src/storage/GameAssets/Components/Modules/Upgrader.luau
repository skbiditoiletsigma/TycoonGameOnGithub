local upgrader = {}
upgrader.__index = upgrader

local replicatedStorage = game:GetService("ReplicatedStorage")
local serverStorage = game:GetService("ServerStorage")

local drops = serverStorage.Drops

local modules = replicatedStorage.Modules
local items = modules.Items

local buyables = require(items.Buyables)

function upgrader.new(tycoon, instance)
	local self = setmetatable({}, upgrader)
	self.Instance = instance
	
	return self
end

function upgrader:Init()
	self.Instance.Collider.Touched:Connect(function(...)
        self:OnTouch(...)
	end)
end

function upgrader:OnTouch(hit)
	if drops:FindFirstChild(hit.Name) then
		local item = buyables[self.Instance:GetAttribute("UnlockableID")]

		if item then
			local worth = hit:GetAttribute("Worth")
			local multiplier = item.Multiplier

			local newWorth = worth * multiplier
			hit:SetAttribute("Worth", math.round(newWorth, 0))
		end
	end
end

return upgrader