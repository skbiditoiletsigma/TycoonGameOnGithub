local serverScriptService = game:GetService("ServerScriptService")
local serverStorage = game:GetService("ServerStorage")
local players = game:GetService("Players")

local frameworks = serverStorage.Frameworks
local gameplay = frameworks.Gameplay

local tycoon = require(gameplay.TycoonService)

local tycoons = {}

local modules = serverScriptService.Modules

local function PlayerAdded(player : Player)
	local PlayerTycoon = tycoon.new(player)
	PlayerTycoon:Init()
	
	tycoons[player.UserId.."-"..player.Name] = PlayerTycoon
end

local function Init()	
	players.PlayerAdded:Connect(PlayerAdded)
	
	for _, module in pairs(modules:GetChildren()) do
		if module:IsA("ModuleScript") then
			require(module)
		end
	end
end

Init()
