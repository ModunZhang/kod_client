--
-- Author: Kenny Dai
-- Date: 2015-06-02 11:22:39
--
local UILib = import(".UILib")
local Localize = import("..utils.Localize")
local Localize_item = import("..utils.Localize_item")
local window = import("..utils.window")
local GameUIChest = UIKit:createUIClass("GameUIChest")

function GameUIChest:ctor(item,awards,tips,ani)
    GameUIChest.super.ctor(self)
    self.item = item
    self.awards = awards
    self.tips = tips
    self.ani = ani
end

function GameUIChest:onEnter()
    GameUIChest.super.onEnter(self)
    print("self.ani =",self.ani)
    local box = ccs.Armature:create(self.ani):addTo(self):align(display.CENTER, display.cx-50, display.cy)
        :scale(0.5)
    box:getAnimation():setMovementEventCallFunc(function (armatureBack, movementType, movementID)
        if movementType == ccs.MovementEventType.start then
        elseif movementType == ccs.MovementEventType.complete then
            self:ShowAwards()
            self:LeftButtonClicked()
        elseif movementType == ccs.MovementEventType.loopComplete then
        end
    end)

    box:getAnimation():play("Animation1", -1, 0)
end

function GameUIChest:onExit()
    GameUIChest.super.onExit(self)
end

function GameUIChest:ShowAwards()
    local dialog = UIKit:newWidgetUI("WidgetPopDialog", 544,_("获得物品"),window.top-230):AddToCurrentScene(true)
    dialog:DisableAutoClose()
    local body = dialog:GetBody():scale(0.2)
    local size = body:getContentSize()
    local list,list_node = UIKit:commonListView_1({
        direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
        viewRect = cc.rect(0, 0,546,3 * 130),
    })
    list_node:addTo(body):align(display.BOTTOM_CENTER, size.width/2,100)
    local which_bg = true
    for i,v in ipairs(self.awards) do
        local list_item = list:newItem()
        list_item:setItemSize(546,130)
        local body_image = which_bg and "back_ground_548x40_1.png" or "back_ground_548x40_2.png"
        local item_bg = display.newScale9Sprite(body_image,0,0,cc.size(548,130),cc.rect(10,10,528,20))
        local b_size = item_bg:getContentSize()
        local icon_bg = display.newSprite("box_118x118.png"):align(display.CENTER,70,b_size.height/2):addTo(item_bg)
        local icon = display.newSprite(UILib.item[v.name] or UILib.dragon_material_pic_map[v.name]):align(display.CENTER,icon_bg:getContentSize().width/2,icon_bg:getContentSize().height/2):addTo(icon_bg)
        icon:scale(100/math.max(icon:getContentSize().width,icon:getContentSize().height))

        UIKit:ttfLabel({
            text = Localize.equip_material[v.name] or Localize_item.item_name[v.name],
            size = 22,
            color = 0x403c2f
        }):align(display.LEFT_CENTER, 140, 106)
            :addTo(item_bg)
        UIKit:ttfLabel({
            text = string.format(_("数量 X %d"),v.count),
            size = 22,
            color = 0x615b44
        }):align(display.LEFT_CENTER, 140, 50)
            :addTo(item_bg)

        list_item:addContent(item_bg)
        list:addItem(list_item)
        which_bg = not which_bg
    end
    list:reload()

    local btn_bg = UIKit:commonButtonWithBG(
        {
            w=185,
            h=65,
            style = UIKit.BTN_COLOR.YELLOW,
            labelParams = {text = _("确定")},
            listener = function ()
                dialog:LeftButtonClicked()
            end,
        }
    ):pos(size.width/2, 50)
        :addTo(body)


    body:runAction(cc.ScaleTo:create(0.15,1))
end

return GameUIChest





