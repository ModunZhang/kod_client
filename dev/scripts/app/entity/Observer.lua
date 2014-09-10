local Observer = class("Observer")


function Observer.extend(target, ...)
	local t = tolua.getpeer(target)
    if not t then
        t = {}
        tolua.setpeer(target, t)
    end
    setmetatable(t, Observer)
    target:ctor(...)
    return target
end
function Observer:ctor(...)
	self.observer = {}
end
function Observer:AddObserver(observer)
	table.insert(self.observer, observer)
	return observer
end
function Observer:RemoveAllObserver()
	self.observer = {}
end
function Observer:RemoveObserver(observer)
	for i, v in ipairs(self.observer) do
		if v == observer then
			table.remove(self.observer, i)
			return
		end
	end
end
function Observer:NotifyObservers(func)
	for i, v in ipairs(self.observer) do
		func(v)
	end
end


return Observer