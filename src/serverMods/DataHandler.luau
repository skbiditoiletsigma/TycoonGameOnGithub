local dataHandler = {}
dataHandler.SessionData = {}

dataHandler.Instances = require(script.Parent.Data.Instances)
dataHandler.Template = require(script.Parent.Data.Template)

local players = game:GetService("Players")
local serverStorage = game:GetService("ServerStorage")
local dataStoreService = game:GetService("DataStoreService")

local tycoonStorage = serverStorage:WaitForChild("TycoonStorage")

local playerAdded = Instance.new("BindableEvent")
local playerRemoving = Instance.new("BindableEvent")

dataHandler.PlayerAdded = playerAdded.Event
dataHandler.PlayerRemoving = playerRemoving.Event

local dataStore = dataStoreService:GetDataStore("Pickle_TycoonData4")

function dataHandler.LoadData(Player: Player)
	local sucess, result = pcall(function()
		return dataStore:GetAsync("Pickle_" .. tostring(Player.UserId))
	end)

	if not sucess then
		warn("Failed to load data for " .. Player.Name, result)
	end

	return sucess, result
end

function dataHandler.SaveData(Player: Player, data)
	local sucess, result = pcall(function()
		return dataStore:SetAsync("Pickle_" .. tostring(Player.UserId), data)
	end)

	if not sucess then
		warn("Failed to save data for " .. Player.Name, result)
	end

	return sucess
end

function dataHandler.OnPlayerAdded(Player: Player)
	if Player.Parent == players then
		print("Player added", Player.Name)
		Player.CharacterAdded:Connect(function(Character)
			dataHandler.OnCharacterAdded(Player, Character)
		end)

		local success, data = dataHandler.LoadData(Player)
		dataHandler.SessionData[Player.UserId] = success and data or dataHandler.Template

		playerAdded:Fire(Player)
		dataHandler.Instances.MakeFolders(Player, dataHandler.SessionData[Player.UserId])
	end
end

function dataHandler.OnCharacterAdded(Player, Character)
	local hum = Character:FindFirstChildOfClass("Humanoid")
	if not hum then return end

	hum.Died:Connect(function()
		task.wait(3)
		Player:LoadCharacter()
	end)
end

function dataHandler.AddUnlockableId(Player: Player, id)
	local data = dataHandler.SessionData[Player.UserId]

	if not table.find(data.TycoonData.UnlockedIds, id) then
		table.insert(data.TycoonData.UnlockedIds, id)
	end
end

function dataHandler.GetUnlockedIds(Player: Player)
	local data = dataHandler.SessionData[Player.UserId]
	return data.TycoonData.UnlockedIds
end

function dataHandler.OnPlayerRemoving(Player: Player)
	local folder = tycoonStorage:FindFirstChild(Player.Name)

	if folder then
		folder:Destroy()
	end

	if not game:GetService("RunService"):IsStudio() then
		dataHandler.SaveData(Player, dataHandler.SessionData[Player.UserId])
	end

	playerRemoving:Fire(Player)
end

function dataHandler.OnClose()
	for _, Player in ipairs(players:GetPlayers()) do
		dataHandler.OnPlayerRemoving(Player)
	end
end

function dataHandler.Start()
	for _, Player in ipairs(players:GetPlayers()) do
		dataHandler.OnPlayerAdded(Player)
	end

	players.PlayerAdded:Connect(dataHandler.OnPlayerAdded)
	players.PlayerRemoving:Connect(dataHandler.OnPlayerRemoving)

	task.wait(0.5)

	function _G.GetMoney(Player: Player)
		local leaderstats = Player:FindFirstChild("leaderstats")
		if not leaderstats then
			dataHandler.PlayerAdded(Player)
		end

		local coins = leaderstats:FindFirstChild("Coins")

		if coins then
			return coins.Value
		end

		return 0
	end

	function _G.SetMoney(Player: Player, value)
		local leaderstats = Player:FindFirstChild("leaderstats")
		if not leaderstats then
			dataHandler.PlayerAdded(Player)
		end

		local coins = leaderstats:FindFirstChild("Coins")

		if coins then
			coins.Value = value
		end
	end

	game:BindToClose(dataHandler.OnClose)
end

return dataHandler
