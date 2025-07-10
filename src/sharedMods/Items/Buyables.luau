return {
	["Dropper"] = {
		Display = "Dropper 1",
		Cost = 5,
		Required = nil,

		Drop = {
			Name = "BlackDrop",
			TimeBetweenDrops = 1,
		},
	},

	["Upgrader"] = {
		Display = "Upgrader 1",
		Cost = 25,
		Required = "Dropper",

		Multiplier = 1.5,
	},

	["OwnerDoor"] = {
		Display = "Owner Door",
		Cost = 75,
		Required = "Upgrader",
	},

	["Wall1"] = {
		Display = "Wall 1",
		Cost = 15,
		Required = nil,
	},

	["Wall2"] = {
		Display = "Wall 2",
		Cost = 30,
		Required = "Wall1",
	},

	["Wall3"] = {
		Display = "Wall 3",
		Cost = 50,	
		Required = "Wall2",
	},

	["Wall4"] = {
		Display = "Wall 4",
		Cost = 100,	
		Required = "Wall3",
	},

	["Wall5"] = {
		Display = "Wall 5",	
		Cost = 175,
		Required = "Wall4",
	},

	["Drops"] = {
		["BlackDrop"] = 2,
	}
}
