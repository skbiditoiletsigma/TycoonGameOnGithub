local gun = {}
gun.__index = gun

local serverStorage = game:GetService("ServerStorage")

local gunModels = serverStorage:FindFirstChild("GunModels")
local gunModules = script.Parent.Guns

function gun.new(gunName)
    local self = setmetatable({}, gun)
    self.GunName = gunName

    return self
end

function gun:Init()
    local gunModule = gunModules:FindFirstChild(self.GunName)
    local gunModel = gunModels:FindFirstChild(self.GunName)

    if gunModule and gunModel then
        self.Gun = require(gunModule)
        self.GunModel = gunModel
    end
end



return gun