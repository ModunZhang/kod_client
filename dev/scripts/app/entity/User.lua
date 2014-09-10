local MultiObserver = import(".MultiObserver")
local User = class("User", MultiObserver)

User.LISTEN_TYPE = {
    GEM_CHANGED = 1,
}
function User:ctor()
	User.super.ctor(self)
	self.gem = 0
end
function User:GetGem()
	return self.gem
end
function User:SetGem(gem)
	if self.gem ~= gem then
		local old_gem = self.gem
		self.gem = gem
		self:NotifyListeneOnType(self.LISTEN_TYPE.GEM_CHANGED, function(listener)
            listener:OnGemChanged(old_gem, gem)
        end)
	end
end




return User