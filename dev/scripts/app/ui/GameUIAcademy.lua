--
-- Author: Danny He
-- Date: 2014-12-17 10:01:36
--
--TreeNode
------------------------------------------------------------------------------------------------
local TreeNode = class("TreeNode")
local property = import("app.utils.property")
function TreeNode:ctor(child_id,pos,data)
	property(self,"child",child_id) -- one child
	property(self,"pos",pos or {x = 0,y = 0})
	property(self,"data",data or {})
end

function TreeNode:hasChild()
	return self:Child()
end
function TreeNode:OnPropertyChange()
end
-- 1 同横向 2 同竖向
function TreeNode:CheckDirection(treeNode)
	if treeNode:Pos().x == self:Pos().x then return 2 end
	if treeNode:Pos().y == self:Pos().y then return 1 end
end

------------------------------------------------------------------------------------------------
local GameUIAcademy = UIKit:createUIClass("GameUIAcademy","GameUIUpgradeBuilding")
local window = import("..utils.window")
local UIScrollView = import(".UIScrollView")
local WidgetPushButton = import("..widget.WidgetPushButton")

function GameUIAcademy:GetTempData()
	local temp = {
		{key = "1",data = {name = "1",enable = true,need = nil}},
		{key = "2",data = {name = "2",enable = false,need = "3"}},
		{key = "3",data = {name = "3",enable = false,need = nil}},
		{key = "4",data = {name = "4",enable = false,need = "1"}},
		{key = "5",data = {name = "5",enable = false,need = "2"}},
		{key = "6",data = {name = "6",enable = false,need = "5"}},
		{key = "7",data = {name = "7",enable = false,need = "4"}},
		{key = "8",data = {name = "8",enable = false,need = "7"}},
		{key = "9",data = {name = "9",enable = false,need = "6"}},
		{key = "10",data = {name = "10",enable = false,need = "7"}},
		{key = "11",data = {name = "11",enable = false,need = "8"}},
		{key = "12",data = {name = "12",enable = false,need = "9"}},
		{key = "13",data = {name = "13",enable = false,need = "10"}},
		{key = "14",data = {name = "14",enable = false,need = "15"}},
		{key = "15",data = {name = "15",enable = false,need = "12"}},
		{key = "16",data = {name = "16",enable = false,need = "13"}},
		{key = "17",data = {name = "17",enable = false,need = "14"}},
		{key = "18",data = {name = "18",enable = false,need = "17"}},
	}
	return temp
end

function GameUIAcademy:ctor(city,building)
	GameUIAcademy.super.ctor(self,city,_("学院"),building)
	local tree_data = self:GetTempData()
	local max_y = (math.ceil(#tree_data/3) - 1) * (142+46) + 71
	local techNodes = {}
	local x,y = 0,max_y
	for i,data in ipairs(tree_data) do
		if i % 3 == 0 then
			x = 2 * (142+46) + 71 + 20 
		else
			x = (i % 3 - 1) * (142+46) + 71 + 20
		end
		local treeNode = TreeNode.new(data.data.need,{x = x,y = y},{name = data.data.name ,enable = data.data.enable})
		techNodes[data.key] = treeNode
		if i % 3 == 0 then
			y = y - (142+46)
		end
	end
	dump(techNodes,"testData-->")
	self.techNodes = techNodes
end

function GameUIAcademy:GetNodeForKey(key)
	return self.techNodes[tostring(key)]
end

function GameUIAcademy:onEnter()
	GameUIAcademy.super.onEnter(self)
	self:CreateTabButtons({
        {
            label = _("科技"),
            tag = "technology",
        },
    },function(tag)
        if tag == 'technology' then
            self.technology_node:show()
        else
            self.technology_node:hide()
        end
    end):pos(window.cx, window.bottom + 34)
end

function GameUIAcademy:CreateBetweenBgAndTitle()
    GameUIAcademy.super.CreateBetweenBgAndTitle(self)
	self.technology_node = self:BuildTechnologyUI():addTo(self):pos(window.left,window.bottom_top)

end

function GameUIAcademy:BuildTipsUI(technology_node,y)
	local tips_bg = display.newSprite("box_panel_556x106.png")
		:addTo(technology_node):align(display.LEFT_TOP,40,y)
	if true then
		UIKit:ttfLabel({
			text = _("研发队列空闲"),
			size = 22,
			color= 0x403c2f
		}):align(display.TOP_CENTER,278,90):addTo(tips_bg)
		UIKit:ttfLabel({
			text = _("选择一个技能进行研发"),
			size = 20,
			color= 0x797154
		}):align(display.BOTTOM_CENTER,278,30):addTo(tips_bg)
	end
end

function GameUIAcademy:BuildTechnologyUI(height)
	height = height or window.betweenHeaderAndTab
	local technology_node = display.newNode():size(window.width,height)
	self:BuildTipsUI(technology_node,height)
	display.newSprite("technology_magic_549x538.png"):align(display.LEFT_CENTER,40, height/2):addTo(technology_node)
	self.scrollView = UIScrollView.new({
        viewRect = cc.rect(40,0,window.width - 80, height - 116), -- 116 = 106 + 10
    })
        :addScrollNode(self:CreateScrollNode():pos(40, 0))
        :setDirection(UIScrollView.DIRECTION_VERTICAL)
        :addTo(technology_node)
    self.scrollView:fixResetPostion(-30)
	return technology_node
end

function GameUIAcademy:CreateScrollNode()
	local node = display.newNode():size(window.width - 80,(math.ceil(LuaUtils:table_size(self.techNodes)/3) - 1) *(142+46) + 142)
	for _,v in pairs(self.techNodes) do
		local item = self:GetItem(v:Data()):align(display.CENTER,v:Pos().x,v:Pos().y):addTo(node)
		if v:hasChild() then
			if v:CheckDirection(self:GetNodeForKey(v:Child())) == 1 then
				local line = display.newSprite("technology_line_normal_72x12.png")
				if self:GetNodeForKey(v:Child()):Pos().x > v:Pos().x then
					line:align(display.LEFT_CENTER,v:Pos().x+71 - 13,v:Pos().y):addTo(node):zorder(2)
				else
					line:align(display.RIGHT_CENTER,v:Pos().x-71 + 13,v:Pos().y ):addTo(node):zorder(2)
				end
			else
				local line = display.newSprite("technology_line_normal_72x12.png"):align(display.RIGHT_CENTER, 0,0)
				line:setRotation(90)
				line:addTo(node):pos(v:Pos().x ,v:Pos().y - 13+71):zorder(2)
			end
		end
	end
	return node
end


function GameUIAcademy:GetItem(data)
	local item = WidgetPushButton.new({normal = "technology_bg_normal_142x142.png"})
	if data.enable then
		display.newSprite("technology_icon_123x123.png"):addTo(item):scale(0.8)
	else
		display.newFilteredSprite("technology_icon_123x123.png","GRAY", {0.2,0.5,0.1,0.1}):addTo(item):scale(0.8)
	end
	local lv_bg = display.newSprite("technology_lv_bg_117x40.png"):align(display.BOTTOM_CENTER, 0, -51):addTo(item)
	if data.enable then
		UIKit:ttfLabel({text = "LV 0",size = 22,color = 0xfff3c7}):align(display.CENTER_BOTTOM, 58, 0):addTo(lv_bg)
	else
		display.newSprite("technology_lock_40x54.png"):align(display.BOTTOM_CENTER, 0, -55):addTo(item)
	end
	item:onButtonClicked(function(event)
        UIKit:newGameUI("GameUIUpgradeTechnology"):addToCurrentScene(true)
	end)
	return item
end

return GameUIAcademy