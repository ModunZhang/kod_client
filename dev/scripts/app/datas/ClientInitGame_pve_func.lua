local pve_func = GameDatas.ClientInitGame.pve_func

pve_func["soldiers"] = {
	["type"] = "soldiers",
	["countFunc"] = function(floor,count,C,D,E) return math.ceil(count * floor ^ 2.6) end
}
pve_func["rewards"] = {
	["type"] = "rewards",
	["countFunc"] = function(floor,count,C,D,E) return math.ceil(count * floor ^ 2) end
}
