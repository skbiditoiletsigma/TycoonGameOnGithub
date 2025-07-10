local ownerDoor = {}
ownerDoor.__index = ownerDoor

local players = game:GetService("Players")

function ownerDoor.new(tycoon, instance)
	local self = setmetatable({}, ownerDoor)
	
	self.Tycoon = tycoon
	self.Instance = instance
	
	return self
end

function ownerDoor:Init()
	self.Active = true

	self.Instance.DoorPart.Touched:Connect(function(...)
        self:OnTouch(...)
	end)
end

function ownerDoor:OnTouch(hit)
    if hit.Parent:IsA("Model") then
        local player = players:GetPlayerFromCharacter(hit.Parent)

        if player then
            if player ~= self.Tycoon.Owner and self.Active == true then
                local hum = hit.Parent:FindFirstChildOfClass("Humanoid")

                if hum then
                    hum.Health = 0
                end
            end
        end
    end
end

return ownerDoor