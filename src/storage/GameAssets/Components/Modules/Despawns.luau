local despawns = {}
despawns.__index = despawns

function despawns.new(tycoon, instance)
	local self = setmetatable({}, despawns)
	
	self.Tycoon = tycoon
	self.Instance = instance
	
	return self
end 

function despawns:Init()
	self.Subscription = self.Tycoon:SubscribeTopic("Button", function(id)
		if id == self.Instance:GetAttribute("ID") then
            self.Instance:Destroy()
        end
	end)
end

return despawns