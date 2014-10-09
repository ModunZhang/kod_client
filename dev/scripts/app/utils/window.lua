print("window")
local window = {}

window.width 					= 640
window.height 				= 960

local width_diff = (display.width - window.width)
local half_width_diff = width_diff / 2
window.left 					= display.left + half_width_diff
window.right 					= display.right - half_width_diff

local height_diff = (display.height - window.height)
local half_height_diff = height_diff / 2
window.top 					= display.top
window.bottom 				= display.bottom + height_diff

window.cx 					= window.left + window.width / 2
window.cy                 	= window.bottom + window.height / 2
window.betweenHeaderAndTab = window.height - 34*2 - 101
return window