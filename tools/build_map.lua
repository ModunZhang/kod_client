local args = {...}

local map = dofile(args[1])


local buildings_map = {
	"palace",
	"orderHall",
	"shrine",
	"shop",
	"moonGate",
	"decorate_mountain_1",
	"decorate_mountain_2",
	"decorate_lake_1",
	"decorate_lake_2",
	"decorate_tree_1",
	"decorate_tree_2",
	"decorate_tree_3",
	"decorate_tree_4",
    "decorate_tree_5",
    "decorate_tree_6",
    "decorate_tree_7",
    "decorate_tree_8",
    "decorate_tree_9",
}


for i,layer in ipairs(map.layers) do
    -- if layer.name == "buildings" then
        -- local min = 999
        -- for i,v in ipairs(layer.data) do
        --     if v ~= 0 and v < min then
        --     	min = v
        --     end
        -- end
        -- for i = 1, #layer.data do
        -- 	layer.data[i] = layer.data[i] - min + 1
        -- end
        for i,v in ipairs(layer.data) do
        	if v > 0 and #buildings_map >= v then
        		local index = (i-1)
        		print(buildings_map[v], index % layer.width, math.floor(index / layer.width))
        	end
        end
    -- end
    break
end
