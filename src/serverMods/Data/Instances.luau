local instances = {}

local serverStorage = game:GetService("ServerStorage")
local tycoonStorage = serverStorage:WaitForChild("TycoonStorage")

function instances.MakeLeaderstats(Player : Player, data)
	local Leaderstats = Player:FindFirstChild("leaderstats")
	
	if not Leaderstats then 
		Leaderstats = Instance.new("Folder", Player)
		Leaderstats.Name = "leaderstats"

		local CoinsValue = Instance.new("IntValue", Leaderstats)
		CoinsValue.Name = "Coins"
		CoinsValue.Value = data.Coins

		local RebirthsValue = Instance.new("IntValue", Leaderstats)
		RebirthsValue.Name = "Rebirths"
		RebirthsValue.Value = data.Rebirths

        instances.ConnectCoins(data, CoinsValue)
	    instances.ConnectRebirths(data, RebirthsValue)
	end
end

function instances.ConnectCoins(data, Value : IntValue)
	Value.Changed:Connect(function()
		data.Coins = Value.Value
	end)
end

function instances.ConnectRebirths(data, Value : IntValue)
	Value.Changed:Connect(function()
		data.Rebirths = Value.Value
	end)
end

function instances.MakeFolders(Player : Player, data)
	instances.MakeLeaderstats(Player, data)

	local folder = Instance.new("Folder", tycoonStorage)
	folder.Name = Player.Name
end

return instances