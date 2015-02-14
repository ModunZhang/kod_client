local Resource = import(".Resource")
local AutomaticUpdateResource = class("AutomaticUpdateResource", Resource)
function AutomaticUpdateResource:ctor()
    AutomaticUpdateResource.super.ctor(self)
    self.last_update_time = 0
    self.resource_production_per_hour = 0
    self.is_over_limit = false
end
function AutomaticUpdateResource:GetProductionPerHour()
    return self.resource_production_per_hour
end
function AutomaticUpdateResource:SetProductionPerHour(current_time, resource_production_per_hour)
    if self.resource_production_per_hour ~= resource_production_per_hour then
        self:UpdateResource(current_time, self:GetResourceValueByCurrentTime(current_time))
        self.resource_production_per_hour = resource_production_per_hour
    end
end
function AutomaticUpdateResource:AddResourceByCurrentTime(current_time, value)
    assert(value >= 0)
    self:UpdateResource(current_time, self:GetResourceValueByCurrentTime(current_time) + value)
end
function AutomaticUpdateResource:ReduceResourceByCurrentTime(current_time, value)
    assert(value >= 0)
    local left_resource = self:GetResourceValueByCurrentTime(current_time) - value
    if left_resource >= 0 then
        self:UpdateResource(current_time, left_resource)
    else
        assert(false, "扣除值错误")
    end
end
function AutomaticUpdateResource:UpdateResource(current_time, value)
    self.last_update_time = current_time
    self:SetValue(value)
end
function AutomaticUpdateResource:GetResourceValueByCurrentTime(current_time)
    local total_resource_value = self:GetResourceValueByCurrentTimeWithoutLimit(current_time)
    local resource_value
    if self.resource_production_per_hour >= 0 then
        resource_value = total_resource_value > self:GetValueLimit() and self:GetValue() or total_resource_value
    else
        resource_value = total_resource_value
    end
    return resource_value < 0 and 0 or resource_value
end
--
function AutomaticUpdateResource:OnTimer(current_time)
    local current_value = self:GetValue()
    local limit_value = self:GetValueLimit()
    local is_producted_over_limit = self:GetResourceValueByCurrentTimeWithoutLimit(current_time) >= limit_value
    if is_producted_over_limit then
        if not self:IsOverLimit() then
            self:SetOverLimit(true)
            local current_resource = current_value > limit_value and current_value or limit_value
            self:UpdateResource(current_time, current_resource)
        end
    else
        self:SetOverLimit(false)
    end
end
function AutomaticUpdateResource:SetOverLimit(is_over_limit)
    self.is_over_limit = is_over_limit
end
function AutomaticUpdateResource:IsOverLimit()
    return self.is_over_limit
end
local floor = math.floor
function AutomaticUpdateResource:GetResourceValueByCurrentTimeWithoutLimit(current_time)
    local elapse_time = current_time - self.last_update_time
    local has_been_producted_from_last_update_time = elapse_time * self.resource_production_per_hour / 3600
    local total_resource_value = self:GetValue() + has_been_producted_from_last_update_time
    self.really_total_resource_value = total_resource_value
    return floor(total_resource_value)
end

return AutomaticUpdateResource



