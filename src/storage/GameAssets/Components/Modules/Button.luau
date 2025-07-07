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
	self.Tycoon:PublishTopic("Button", id)
	
	self:Disappear()
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
		Prompt.ObjectText = "$"..item.Cost
	end
	
	Prompt.Parent = self.Instance
	return Prompt
end

return Button