local collector = {}
collector.__index = collector

local players = game:GetService("Players")

function collector.new(tycoon, instance)
    local self = setmetatable({}, collector)

    self.Tycoon = tycoon
    self.Instance = instance

    self.CurrentCollection = 0

    return self
end

function collector:Init()
    self.Instance.Touch.Touched:Connect(function(...)
        self:Touch(...)
    end)

    self.Tycoon:SubscribeTopic("ChangeCurrentCollection", function(...)
        self:ChangeCurrentCollection(...)
    end)
end

function collector:UpdateDisplay()
    local display = self.Instance.Display
    if not display then return end

    local surfaceGui = display:FindFirstChild("SurfaceGui")
    if not surfaceGui then return end

    local textLabel = surfaceGui:FindFirstChild("TextLabel")

    if textLabel then
        textLabel.Text = "$" .. self.CurrentCollection
    end
end

function collector:Touch(hit)
    if hit.Parent:IsA("Model") then
        if hit.Parent.Name == self.Tycoon.Owner.Name then
            local player = players:GetPlayerFromCharacter(hit.Parent)

            if player then
                _G.SetMoney(player, _G.GetMoney(player) + self.CurrentCollection) 
                self.CurrentCollection = 0

                self:UpdateDisplay()
            end
        end
    end
end

function collector:ChangeCurrentCollection(drop)
    self.CurrentCollection += drop
    self:UpdateDisplay()
end

return collector