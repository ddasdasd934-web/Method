---@module Features.Visuals.Objects.EntityESP
local EntityESP = require("Features/Visuals/Objects/EntityESP")

---@module Utility.Configuration
local Configuration = require("Utility/Configuration")

---@class MobESP: EntityESP
local MobESP = setmetatable({}, {
    __index = EntityESP
})
MobESP.__index = MobESP
MobESP.__type = "MobESP"

-- Formats.
local ESP_HEALTH = "[%i/%i]"
local ESP_BLOOD_POISON = "[Poison %i]"

---Update MobESP.
---@param self MobESP
MobESP.update = LPH_NO_VIRTUALIZE(function(self)
    local humanoid = self.entity:FindFirstChildOfClass("Humanoid")
    if not humanoid then
        return self:visible(false)
    end

    local tags = {ESP_HEALTH:format(humanoid.Health, humanoid.MaxHealth)}

    local bloodPoisonValue = 0
    if Configuration.expectToggleValue("ShowMobBloodPoison") or Configuration.idToggleValue("Mob", "PoisonBar") then
        -- Try to find BloodPoison as a direct child first
        local bloodPoison = self.entity:FindFirstChild("BloodPoison")

        -- If not found as direct child, search recursively
        if not bloodPoison then
            bloodPoison = self.entity:FindFirstDescendant("BloodPoison")
        end

        -- If found and it's a value object, read it
        if bloodPoison and (bloodPoison:IsA("IntValue") or bloodPoison:IsA("NumberValue")) then
            bloodPoisonValue = math.floor(bloodPoison.Value)
        elseif bloodPoison then
            -- If it's something else, try to convert it
            local value = bloodPoison.Value
            if value then
                bloodPoisonValue = math.floor(tonumber(value) or 0)
            end
        else
            -- Try to find it as an attribute on the character
            local attr = self.entity:GetAttribute("BloodPoison")
            if attr then
                bloodPoisonValue = math.floor(tonumber(attr) or 0)
            else
                -- Try to find it as an attribute on the humanoid
                local humanoidAttr = humanoid:GetAttribute("BloodPoison")
                if humanoidAttr then
                    bloodPoisonValue = math.floor(tonumber(humanoidAttr) or 0)
                end
            end
        end
    end

    if Configuration.expectToggleValue("ShowMobBloodPoison") then
        table.insert(tags, ESP_BLOOD_POISON:format(bloodPoisonValue))
    end

    -- Store poison value for bar updating
    self.lastPoisonValue = bloodPoisonValue

    EntityESP.update(self, tags)
end)

---Add extra elements (poison bar).
MobESP.extra = LPH_NO_VIRTUALIZE(function(self)
    if Configuration.idToggleValue("Mob", "PoisonBar") then
        self.pbar = self:add("PoisonBar", "left", 6, function(container)
            self:cgb(container, true, true, Color3.new(0.5, 1, 0))
        end)
    end
end)

---Create new MobESP object.
---@param identifier string
---@param model Model
---@param label string
function MobESP.new(identifier, model, label)
    local self = setmetatable(EntityESP.new(model, identifier, label), MobESP)
    self:setup()
    self:build()
    self:update()
    return self
end

-- Return MobESP module.
return MobESP
