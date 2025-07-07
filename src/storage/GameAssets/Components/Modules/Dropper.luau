local dropper = {}
dropper.__index = dropper

function dropper.new(tycoon, instance)
	local self = setmetatable({}, dropper)
	
	self.Tycoon = tycoon
	self.Instance = instance
		
	return self
end

function dropper:Init()
	print("sigma nigger boy sigma good girl")
end

return dropper