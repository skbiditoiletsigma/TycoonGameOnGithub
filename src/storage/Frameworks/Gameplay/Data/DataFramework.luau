local DataStoreService = game:GetService("DataStoreService")
local Players = game:GetService("Players")

local DataFramework = {}
DataFramework.__index = DataFramework

DataFramework.playerProfiles = {}

local function deepCopy(tbl)
	local copy = {}
	for k, v in pairs(tbl) do
		if type(v) == "table" then
			copy[k] = deepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

function DataFramework.new(datastoreName, defaultTemplate, autoSaveInterval)
	local self = setmetatable({}, DataFramework)
	self.datastoreName = datastoreName or "PlayerData"
	self.defaultTemplate = defaultTemplate or { Cash = 0, Level = 1, Inventory = {} }
	self.autoSaveInterval = autoSaveInterval or 60
	self.dataStore = DataStoreService:GetDataStore("Pickle_"..self.datastoreName)
	self._initialized = false
	return self
end

function DataFramework:init(player)
	if not self._initialized then
		self._initialized = true
		self:_initAutoSave()
		self:_initPlayerHooks()
	end
	if player then
		return self:LoadProfile(player)
	end
end

function DataFramework:_initAutoSave()
	task.spawn(function()
		while true do
			task.wait(self.autoSaveInterval)
			for _, player in ipairs(Players:GetPlayers()) do
				self:SaveProfile(player)
			end
		end
	end)
end

function DataFramework:_initPlayerHooks()
	Players.PlayerRemoving:Connect(function(player)
		self:SaveProfile(player)
		self:Release(player)
	end)
end

function DataFramework:LoadProfile(player)
	local userId = player.UserId
	local profile = self.playerProfiles[userId]
	if profile and profile.loaded then
		profile.loadCount += 1
		self:_updateSessionAndClientDetails(profile, player)
		return profile
	end
	
	local data, loadCount = nil, 1
	local success, stored = self:Get(tostring(userId))

	if success and type(stored) == "table" then
		data = stored.data or stored
		loadCount = stored.loadCount or 1
		for k, v in pairs(self.defaultTemplate) do
			if data[k] == nil then
				data[k] = deepCopy(v)
			end
		end
	else
		data = deepCopy(self.defaultTemplate)
	end
	local newProfile = {
		data = data,
		sessionDetails = {},
		clientDetails = {},
		loadCount = loadCount,
		loaded = true,
	}
	newProfile.loadCount += 1
	self:_updateSessionAndClientDetails(newProfile, player)
	DataFramework.playerProfiles[userId] = newProfile
	return newProfile
end

function DataFramework:_updateSessionAndClientDetails(profile, player)
	profile.sessionDetails = {
		gameId = game.GameId,
		placeId = game.PlaceId,
		jobId = game.JobId,
	}
	profile.clientDetails = {
		userId = player.UserId,
		accountAge = player.AccountAge,
		name = player.Name,
		displayName = player.DisplayName,
	}
end

function DataFramework:SaveProfile(player)
	local userId = player.UserId
	local profile = self.playerProfiles[userId]
	if not profile or not profile.loaded then
		return
	end
	local saveData = {
		data = profile.data,
		loadCount = profile.loadCount,
	}
	local success, err = self:Set(tostring(userId), saveData)
	if not success then
		warn("[DataFramework] Failed to save data for", player, err)
	end
end

function DataFramework:Release(player)
	local userId = player.UserId
	self.playerProfiles[userId] = nil
end

function DataFramework:Get(key)
	local success, result = self.dataStore:GetAsync(key)				
	return success, result
end

function DataFramework:Set(key, value)
	local success, result = pcall(function()
		return self.dataStore:SetAsync(key, value)
	end)
	return success, result
end

return DataFramework
