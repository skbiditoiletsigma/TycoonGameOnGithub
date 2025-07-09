local conveyor = {}
conveyor.__index = conveyor

local replicatedStorage = game:GetService("ReplicatedStorage")

local modules = replicatedStorage:WaitForChild("Modules")

local buyables = require(modules.Items.Buyables)
local drops = buyables.Drops

function conveyor.new(tycoon, instance)
    local self = setmetatable({}, conveyor)

    self.Tycoon = tycoon
    self.Instance = instance

    return self
end

function conveyor:Init()
   local conveyor = self.Instance:WaitForChild("ConveyorBelt")
   conveyor.AssemblyLinearVelocity = conveyor.CFrame.LookVector * 5

   local conveyorEnd = self.Instance:WaitForChild("ConveyorEnd")
   conveyorEnd.Touched:Connect(function(hit)
        self:EndTouched(hit, self.Tycoon.Owner)
   end)
end

function conveyor:EndTouched(hit)
    if hit:IsA("Part") then
        local drop = drops[hit.Name]

        if drop then
            self.Tycoon:PublishTopic("ChangeCurrentCollection", drop)
			hit:Destroy()
        end
    end
end

return conveyor