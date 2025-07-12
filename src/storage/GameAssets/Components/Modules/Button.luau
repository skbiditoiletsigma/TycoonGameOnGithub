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
	if not visible then return end

	self.Prompt = self:CreatePrompt()

	self.Subscription = self.Tycoon:SubscribeTopic("SetVisible", function(...)
		self:SetVisible(...)
	end)	

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
	if visible then
		self.Instance.Parent = self.Tycoon.Tycoon.Buttons
		print("please fix this daddy")
	else
		local storage = tycoonStorage:FindFirstChild(self.Tycoon.Owner.Name)
		if storage then
			local buttonsFolder = storage:FindFirstChild("Buttons")

			if buttonsFolder then
				self.Instance.Parent = buttonsFolder
			else
				buttonsFolder = Instance.new("Folder")
				buttonsFolder.Name = "Buttons"
				buttonsFolder.Parent = storage

				self.Instance.Parent = buttonsFolder
			end
		end
	end
end

return Button
