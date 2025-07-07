local unlockable = {}
unlockable.__index = unlockable

function unlockable.new(tycoon, instance)
	local self = setmetatable({}, unlockable)
	
	self.Tycoon = tycoon
	self.Instance = instance
	
	return self
end

function unlockable:Init()
	self.Subscription = self.Tycoon:SubscribeTopic("Button", function(...)
		self:OnButtonPressed(...)
	end)
end

function unlockable:OnButtonPressed(id)
	if id == self.Instance:GetAttribute("UnlockableID") then
		self.Tycoon:Unlock(self.Instance, id)
		self.Subscription:Disconnect()
	end
end

return unlockable