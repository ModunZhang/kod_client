local Sprite = import(".Sprite")
local SpriteConfig = import(".SpriteConfig")
local CitySprite = class("CitySprite", Sprite)
function CitySprite:ctor(city_layer, entity)
    local x, y = city_layer:GetLogicMap():ConvertToMapPosition(entity:GetLogicPosition())
    CitySprite.super.ctor(self, city_layer, entity, x, y)

    local bg = display.newSprite("can_not_level_up.png"):addTo(self):align(display.TOP_CENTER, 30, -10)
    self.keepLevel = UIKit:ttfLabel({
        text = entity:GetAllianceMemberInfo():KeepLevel(),
        size = 22,
        color = 0xfff1cc,
    }):addTo(bg):align(display.CENTER, 10, 20)
    self.info = bg

    -- local bg = display.newSprite("back_ground_284x128.png")
    -- :addTo(self):align(display.TOP_CENTER, 0, -50)

    -- local size = bg:getContentSize()
    -- local startx = size.width/8
    -- local gap = size.height/4
    -- self.name = UIKit:ttfLabel({
    --     text = _("名字: ")..entity:GetAllianceMemberInfo():Name(),
    --     size = 22,
    --     color = 0x403c2f,
    -- }):addTo(bg):align(display.LEFT_CENTER, startx, gap * 3.5)
    
    -- self.keepLevel = UIKit:ttfLabel({
    --     text = _("城堡等级: ")..entity:GetAllianceMemberInfo():KeepLevel(),
    --     size = 22,
    --     color = 0x403c2f,
    -- }):addTo(bg):align(display.LEFT_CENTER, startx, gap * 2.5)
    
    -- self.isProtected = UIKit:ttfLabel({
    --     text = _("保护状态: ")..(entity:GetAllianceMemberInfo():IsProtected() and "是" or "否"),
    --     size = 22,
    --     color = 0x403c2f,
    -- }):addTo(bg):align(display.LEFT_CENTER, startx, gap * 1.5)

    -- self.wallHp = UIKit:ttfLabel({
    --     text = _("城墙血量: ")..entity:GetAllianceMemberInfo():WallHp(),
    --     size = 22,
    --     color = 0x403c2f,
    -- }):addTo(bg):align(display.LEFT_CENTER, startx, gap * 0.5)

    -- self.info = bg

    -- self:CreateBase()
end
function CitySprite:GetSpriteFile()
    return SpriteConfig["keep"]:GetConfigByLevel(1).png, 0.2
end
function CitySprite:GetSpriteOffset()
	return self:GetLogicMap():ConvertToLocalPosition(0, 0)
end
function CitySprite:OnSceneScale(s)
    self.info:setScale(2 - s)
end




---
function CitySprite:CreateBase()
    self:GenerateBaseTiles(1, 1)
end
function CitySprite:newBatchNode(w, h)
    local start_x, end_x, start_y, end_y = self:GetLocalRegion(w, h)
    local base_node = display.newBatchNode("grass_80x80_.png", 10)
    local map = self:GetLogicMap()
    for ix = start_x, end_x do
        for iy = start_y, end_y do
			display.newSprite(base_node:getTexture()):addTo(base_node):pos(map:ConvertToLocalPosition(ix, iy))
        end
    end
    return base_node
end
return CitySprite



