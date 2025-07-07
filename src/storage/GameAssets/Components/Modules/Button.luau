local Button = {}
Button.__index = Button

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Modules = ReplicatedStorage.Modules
local Items = Modules.Items

local Buyables = require(Items.Buyables)

function Button.new(tycoon, instance)
	local self = setmetatable({}, Button)

	self.Tycoon = tycoon
	self.Instance = instance

	return self
end

function Button:Init()
	self.Prompt = self:CreatePrompt()

	self.Prompt.Triggered:Connect(function(...)
		self:Press(...)
	end)
end

function Button:Press(Player)
	local id = self.Instance:GetAttribute("ID")

	local item = Buyables[id]
	local cost = 0

	if item then
		cost = item.Cost
	end

	local currentMoney = _G.GetMoney(Player)

	if Player == self.Tycoon.Owner and currentMoney >= cost then
		_G.SetMoney(Player, currentMoney - cost)
		self.Tycoon:PublishTopic("Button", id)
		self:Disappear()
	end
end

function Button:Disappear()
	self.Instance:Destroy()
end

function Button:CreatePrompt()
	local Prompt = Instance.new("ProximityPrompt")
	Prompt.HoldDuration = 0.5

	local item = Buyables[self.Instance:GetAttribute("ID")]

	if item then
		Prompt.ActionText = item.Display
		Prompt.ObjectText = "$" .. item.Cost
	end

	Prompt.Parent = self.Instance
	return Prompt
end

return Button
