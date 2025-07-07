local instances = {}

function instances.MakeLeaderstats(Player : Player)
	local Leaderstats = Player:FindFirstChild("leaderstats")
	
	if not Leaderstats then 
		Leaderstats = Instance.new("Folder", Player)
		Leaderstats.Name = "leaderstats"

		local CoinsValue = Instance.new("IntValue", Leaderstats)
		CoinsValue.Name = "Coins"
		CoinsValue.Value = 5

		local RebirthsValue = Instance.new("IntValue", Leaderstats)
		RebirthsValue.Name = "Rebirths"
		RebirthsValue.Value = 0

        --instances.ConnectCoins(StatsTable, CoinsValue)
	    --instances.ConnectRebirths(StatsTable, RebirthsValue)
	end
end

function instances.ConnectCoins(StatsTable, Value : IntValue)
	Value.Changed:Connect(function()
		StatsTable.Coins = Value.Value
	end)
end

function instances.ConnectRebirths(StatsTable, Value : IntValue)
	Value.Changed:Connect(function()
		StatsTable.Rebirths = Value.Value
	end)
end

function instances.MakeFolders(Player : Player)
	
end

return instances