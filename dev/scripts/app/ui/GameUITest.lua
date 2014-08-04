--
-- Author: dannyhe
-- Date: 2014-08-01 18:14:32
-- 用来测试GameUIBASE的文件
local UIKitHelper = UIKitHelper
local GameUITest  = UIKitHelper:inheritUIBase('GameUITest')

function GameUITest:ctor(arg)
	-- return the root widget(panel)
	local rootWidget = self.super.ctor(self,{
			ui = 'UpgradeProcessBar_1.json',
			title = 'GameUITest'
		}
	)
	if not rootWidget then
		printError('Init GameUITest Failed!')
	end
	printInfo('arg is %s',arg)
end


function GameUITest:leftButtonClicked(sender)
	printInfo('overwrite leftButtonClicked')
	self.super.leftButtonClicked(self,sender)
end


function GameUITest:rightButtonClicked(sender)
	printInfo('overwrite rightButtonClicked')
	self.super.rightButtonClicked(self,sender)

end

function GameUITest:onAddToScene()
	self.super.onAddToScene(self)
	printInfo('%s', 'Hello GameUITest')
	self:InitUI()	
end

function GameUITest:onEraseFromScene()
	printInfo('%s', 'Bye GameUITest')
	self.super.onEraseFromScene(self)
end

function GameUITest:InitUI()
	local tableview,tableview2 = self:seekPanel2Table('Panel_Table','Panel_Table_0')

	printInfo('tableview is %s,tableview2 is %s', tolua.type(tableview),tolua.type(tableview2))

	tableview:registerScriptHandler(function(table, cell)
        print("cell touched at index: " .. cell:getIdx())
    end, CCTableView.kTableCellTouched)
    tableview:registerScriptHandler(function(table, idx)
        return 640, 80
    end, CCTableView.kTableCellSizeForIndex)
    tableview:registerScriptHandler(function(tableView, idx) --range of idx is: (cout - 1) ~ 0
        local cell = tableview:dequeueCell()
        if not cell then
            cell = CCTableViewCell:new()
            local label = ui.newTTFLabel({
                text = string.format("World_%d",idx),
                font = "Arial",
                size = 32,
                color = ccc3(255, 0, 0), -- red
                align = ui.TEXT_ALIGN_CENTER,
                valign = ui.TEXT_VALIGN_CENTER,
                dimensions = CCSize(200, 50)
            }):center()
            label:setTag(1000)
            cell:addChild(label)
        else
            local label = cell:getChildByTag(1000)
            label:setString(string.format("World_%d",idx))
            
        end
        return cell
    end, CCTableView.kTableCellSizeAtIndex)
    tableview:registerScriptHandler(function(table)
        return 200
    end, CCTableView.kNumberOfCellsInTableView)

    tableview:reloadData()

    tableview2:registerScriptHandler(function(table, cell)
        print("cell touched at index: " .. cell:getIdx())
    end, CCTableView.kTableCellTouched)
    tableview2:registerScriptHandler(function(table, idx)
        return 640, 80
    end, CCTableView.kTableCellSizeForIndex)
    tableview2:registerScriptHandler(function(tableView, idx) --range of idx is: (cout - 1) ~ 0
        local cell = tableview:dequeueCell()
        if not cell then
            cell = CCTableViewCell:new()
            local label = ui.newTTFLabel({
                text = string.format("World_%d",idx),
                font = "Arial",
                size = 32,
                color = ccc3(255, 0, 0), -- red
                align = ui.TEXT_ALIGN_CENTER,
                valign = ui.TEXT_VALIGN_CENTER,
                dimensions = CCSize(200, 50)
            }):center()
            label:setTag(1000)
            cell:addChild(label)
        else
            local label = cell:getChildByTag(1000)
            label:setString(string.format("World_%d",idx))
            
        end
        return cell
    end, CCTableView.kTableCellSizeAtIndex)
    tableview2:registerScriptHandler(function(table)
        return 200
    end, CCTableView.kNumberOfCellsInTableView)

    tableview2:reloadData()
end

return GameUITest
