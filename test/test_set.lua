local Game = require("Game")
local Set = import("app.utils.Set")
local KeySet = import("app.utils.KeySet")

-- s1 = Set.new{1, 10, 20, 30, 50}
-- s2 = Set.new{30}
-- print()
-- print("s1", s1)
-- print("s2", s2)
-- print("s1 + s2", s1 + s2)
-- print("s1 - s2", s1 - s2)
-- print("s2 - s1", s2 - s1)
-- print("s1 * s2", s1 * s2)
-- print(getmetatable(s1))


s1 = KeySet.new{
	a = 1,
	b = 2,
	c = 3,
	d = 4,
}
s2 = KeySet.new{
	a = 0
}
print()
print("s1", s1)
print("s2", s2)
-- print("s1 + s2", s1 + s2)
-- print("s1 - s2", s1 - s2)
-- print("s2 - s1", s2 - s1)
-- print("s1 * s2", s1 * s2)







