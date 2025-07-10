local serverScriptService = game:GetService("ServerScriptService")
local serverStorage = game:GetService("ServerStorage")
local players = game:GetService("Players")

local spawns = workspace:WaitForChild("Spawns")

local frameworks = serverStorage.Frameworks
local gameplay = frameworks.Gameplay

local tycoon = require(gameplay.TycoonService)

local tycoons = {}

local modules = serverScriptService.Modules
local dataHandler = require(modules.DataHandler)

local function FindSpawn()
	for _, spawn in pairs(spawns:GetChildren()) do
		if not spawn:GetAttribute("Occupied") then
			return spawn
		end
	end

	return nil
end

local function Init()	
	dataHandler.PlayerAdded:Connect(function(player)
		local PlayerTycoon = tycoon.new(player, FindSpawn())
		PlayerTycoon:Init()

		tycoons[player.UserId.."-"..player.Name] = PlayerTycoon
	end)
	
	dataHandler.Start()
	
	for _, module in pairs(modules:GetChildren()) do
		if module:IsA("ModuleScript") then
			require(module)
		end
	end
end

Init()
