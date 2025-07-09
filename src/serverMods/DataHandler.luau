local dataHandler = {}
dataHandler.Instances = require(script.Parent.Data.Instances)

local players = game:GetService("Players")
local serverStorage = game:GetService("ServerStorage")
local marketplace = game:GetService("MarketplaceService")

local tycoonStorage = serverStorage:WaitForChild("TycoonStorage")

local frameworks = serverStorage.Frameworks
local gameplay = frameworks.Gameplay

local data = gameplay.Data

function dataHandler.PlayerAdded(Player: Player)
	if Player.Parent == players then
		dataHandler.Instances.MakeFolders(Player)
	end

	local assetId = 125304905004418
	local currencyType = Enum.CurrencyType.Default

	marketplace:PromptPurchase(Player, assetId, false, currencyType)
	print(Player.Name, "has bought the tycoon")
end

function dataHandler.PlayerRemoving(Player: Player)
	local folder = tycoonStorage:FindFirstChild(Player.Name)

	if folder then
		folder:Destroy()
	end
end

function dataHandler.Start()
	players.PlayerAdded:Connect(dataHandler.PlayerAdded)
	players.PlayerRemoving:Connect(dataHandler.PlayerRemoving)

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
end

dataHandler.Start()

return dataHandler
