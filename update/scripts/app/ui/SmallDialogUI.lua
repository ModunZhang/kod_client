-- dialog 箭头朝向
local DIRECTION = {
    UP = 0,
    DOWN = 1
}

local SmallDialogUI = class("SmallDialogUI", function ()
    -- return display.newColorLayer(cc.c4b(255,0,0,50))
    return display.newLayer()
end)

function SmallDialogUI:ctor(parms)
    self.dialog = cc.ui.UIGroup.new():align(display.CENTER):addTo(self):enableTouch(true)
    -- self.dialog:setBackgroundImage("resource_icon_background.png",{scale9=true})
    -- self.dialog:setLayoutSize(display.width,display.height)
    --设置缩放九宫格
    -- local origin_x = 20
    -- local origin_y = 10
    -- local rect = cc.rect(origin_x, origin_y, 104 - origin_x * 2, 104 - origin_y * 2)
    self.center_part = cc.ui.UIImage.new("smaleDialogUI/centerDialog.png"):align(display.CENTER, 0, 0):addTo(self.dialog)
    self.left_part = cc.ui.UIImage.new("smaleDialogUI/broadsideDialog.png"):align(display.RIGHT_CENTER, -50, 0):addTo(self.dialog)
    self.right_part = cc.ui.UIImage.new("smaleDialogUI/broadsideDialog.png"):align(display.LEFT_CENTER, 50, 0):addTo(self.dialog)
    self.dialogDividing = display.newScale9Sprite("smaleDialogUI/dialogDividing.png", 0, -10, cc.size(292,5)):addTo(self.dialog)
    self.right_part:setFlippedX(true)
    -- tips 两条
    self.tips1 = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = parms.tips1,
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, 0, 15)
        :addTo(self.dialog)
    self.tips2 = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = parms.tips2,
        font = UIKit:getFontFilePath(),
        size = 22,
        color = UIKit:hex2c3b(0x403c2f)
    }):align(display.CENTER, 0, -35)
        :addTo(self.dialog)

    -- self.left_part:setCapInsets(cc.rect(origin_x, origin_y, self.left_part:getContentSize().width - origin_x * 2, self.left_part:getContentSize().height - origin_y * 2))
    -- self.right_part:setCapInsets(cc.rect(origin_x, origin_y, self.right_part:getContentSize().width - origin_x * 2, self.right_part:getContentSize().height - origin_y * 2))
    local dialog_width,dialog_height = self.dialog:getCascadeBoundingBox().size.width,self.dialog:getCascadeBoundingBox().size.height
    self.dialog:pos(parms.x, parms.y-dialog_height/2)
    -- 设置dialog箭头朝向
    if parms.direction == DIRECTION.DOWN then
        self.center_part:setFlippedY(true)
        self.left_part:setFlippedY(true)
        self.right_part:setFlippedY(true)
        self.dialog:pos(parms.x, parms.y+dialog_height/2)
        self.dialogDividing:pos(0, 0)
        self.tips1:pos(0,25)
        self.tips2:pos(0,-25)
    end
    -- 超出屏幕 改变dialog适配位置
        local left_part_width,left_part_height = self.left_part:getContentSize().width,self.left_part:getContentSize().height
        local right_part_width,right_part_height = self.right_part:getContentSize().width,self.right_part:getContentSize().height
    if parms.x-dialog_width/2<0 then
        -- print("超出左边屏幕.............")
        -- x方向缩放dialog 左边部分
        local over_width = dialog_width/2-parms.x --超出的长度
        self.left_part:setLayoutSize(left_part_width-over_width,self.left_part:getContentSize().height)
        -- x方向同样比例增加右边部分长度
        self.right_part:setLayoutSize(right_part_width+over_width,right_part_height)
        -- 移动 分割线位置
        self.dialogDividing:pos(over_width-5, self.dialogDividing:getPositionY())
        -- 移动 tips位置
        self.tips1:pos(over_width-5,self.tips1:getPositionY())
        self.tips2:pos(over_width-5,self.tips2:getPositionY())

    elseif parms.x+dialog_width/2>display.width then
        -- print("超出右边屏幕.............")
        -- x方向缩放dialog 右边边部分
        local over_width = parms.x+dialog_width/2-display.width --超出的长度
        self.right_part:setLayoutSize(right_part_width-over_width,right_part_height)
        -- x方向同样比例增加右边部分长度
        self.left_part:setLayoutSize(left_part_width+over_width,left_part_height)
        -- 移动 分割线位置
        self.dialogDividing:pos(-over_width+5, self.dialogDividing:getPositionY())
        -- 移动 tips位置
        self.tips1:pos(-over_width+5,self.tips1:getPositionY())
        self.tips2:pos(-over_width+5,self.tips2:getPositionY())
    end


    self:setTouchSwallowEnabled(false)
    self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function ( event )
        if event.name == "began" then
            self.dialog:setVisible(false)
        end
        if event.name == "ended" then
            print( "移除了  smalldialog")
            self:removeFromParent(true)
            if parms.listener then
                parms.listener()
            end
        end
        return true
    end, 1)
end


return SmallDialogUI



