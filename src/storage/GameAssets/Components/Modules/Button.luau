local Button = {}
Button.__index = Button

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

local tycoonStorage = ServerStorage:WaitForChild("TycoonStorage")

local Modules = ReplicatedStorage.Modules
local Items = Modules.Items

local Buyables = require(Items.Buyables)

local ServerScriptService = game:GetService("ServerScriptService")
local serverModules = ServerScriptService.Modules
local dataHandler = require(serverModules.DataHandler)

function Button.new(tycoon, instance)
	local self = setmetatable({}, Button)

	self.Tycoon = tycoon
	self.Instance = instance

	return self
end

function Button:Init()
	local id = self.Instance:GetAttribute("ID")	
	local item = Buyables[id]
	local visible = true

	if item and item.Required then
		local unlockedIds = dataHandler.GetUnlockedIds(self.Tycoon.Owner)
		visible = false
		for _, unlockedId in ipairs(unlockedIds) do
			if unlockedId == item.Required then
				visible = true
				break
			end
		end
	end

	self:SetVisible(visible)
	
	-- Always set up the subscription to listen for ItemUnlocked events
	self.Subscription = self.Tycoon:SubscribeTopic("ItemUnlocked", function(unlockedId)
		self:CheckVisibility(unlockedId)
	end)	

	-- Only create prompt if initially visible
	if visible then
		self.Prompt = self:CreatePrompt()
		self.Prompt.Triggered:Connect(function(...)
			self:Press(...)
		end)
	end
end

function Button:CheckVisibility(unlockedId)
	local id = self.Instance:GetAttribute("ID")
	local item = Buyables[id]
	
	if item and item.Required and item.Required == unlockedId then
		self:SetVisible(true)
		
		-- Create prompt if it doesn't exist
		if not self.Prompt then
			self.Prompt = self:CreatePrompt()
			self.Prompt.Triggered:Connect(function(...)
				self:Press(...)
			end)
		end
	end
end

function Button:Press(Player)
	local id = self.Instance:GetAttribute("ID")

	local item = Buyables[id]
	local cost = 0

	if item then
		cost = item.Cost
	end

	local currentMoney = _G.GetMoney(Player)

	-- Prerequisite check
	local canUnlock = true
	if item and item.Required then
		local unlockedIds = dataHandler.GetUnlockedIds(Player)
		canUnlock = false
		for _, unlockedId in ipairs(unlockedIds) do
			if unlockedId == item.Required then
				canUnlock = true
				break
			end
		end
	end

	if Player == self.Tycoon.Owner and currentMoney >= cost and canUnlock then
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

function Button:SetVisible(visible)
	if not self.Instance or not self.Instance:IsDescendantOf(game) then return end

	-- Set the button's visibility
	self.Instance.Transparency = visible and 0 or 1
	
	-- Also handle the prompt visibility if it exists
	if self.Prompt then
		self.Prompt.Enabled = visible
	end
end

return Button
			