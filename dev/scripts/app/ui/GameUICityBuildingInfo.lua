--
-- Author: Kenny Dai
-- Date: 2015-05-14 17:47:43
--
local WidgetPopDialog = import("..widget.WidgetPopDialog")
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local Localize = import("..utils.Localize")
local UIListView = import(".UIListView")
local GameUICityBuildingInfo = class("GameUICityBuildingInfo", WidgetPopDialog)

local AllianceBuilding = GameDatas.AllianceBuilding

-- 每个建筑详情列数和宽度
local building_details_map = {
    ["keep"] = {
        {130,  		130, 		130, 		130			   },
        {"level",  	"power", 	"unlock", "beHelpedCount"},
        {_("等级"), _("力量"),_("可解锁地块"),_("可协助加速") }
    },
    ["watchTower"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("瞭望塔效果")},
    },
    ["warehouse"] = {
        {90,		100,		200,			130		  },
        {_("等级"), _("力量"),_("资源存储上限"),_("暗仓保护") }
    },
    ["dragonEyrie"] = {
        {90,		130,			300				},
        {_("等级"), _("力量"),_("巨龙生命值恢复每小时")},
    },
    ["toolShop"] = {
        {90,			130,			300},
        {_("等级"), _("力量"),_("制造工具数量")},
    },
    ["materialDepot"] = {
        {90,			130,			300},
        {_("等级"), _("力量"),_("材料存储上限")},
    },
    ["barracks"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("最大招募"),_("新解锁士兵") }
    },
    ["blackSmith"] = {
        {90,130,300},
        {_("等级"), _("力量"),_("提升炼制速度")},
    },
    ["foundry"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("增加矿工小屋"),_("增加铁矿保护") }
    },
    ["stoneMason"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("增加石匠小屋"),_("增加石料保护") }
    },
    ["lumbermill"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("增加木工小屋"),_("增加木材保护") }
    },
    ["mill"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("增加农夫小屋"),_("增加粮食保护") }
    },
    ["hospital"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("容纳伤兵上限")},
    },
    ["townHall"] = {
        {90,			100,		200,		130},
        {_("等级"), _("力量"),_("增加住宅"),_("提升任务奖励") }
    },
    ["tradeGuild"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("运输车总量"),_("运输车生产") }
    },
    ["academy"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("提升科技研发速度")},
    },
    ["hunterHall"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("提升弓手招募速度")},
    },
    ["trainingGround"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("提升步兵招募速度")},
    },
    ["stable"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("提升骑兵招募速度")},
    },
    ["workshop"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("提升攻城机械招募速度")},
    },
    ["tower"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("城墙攻击"),_("城墙防御") }
    },
    ["wall"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("耐久度"),_("耐久度恢复每小时") }
    },
    ["dwelling"] = {
        {90,			100,		200,			130},
        {_("等级"), _("力量"),_("城民上限"),_("银币产出每小时") }
    },
    ["woodcutter"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("木材产出每小时")},
    },
    ["quarrier"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("石料产出每小时")},
    },
    ["miner"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("铁矿产出每小时")},
    },
    ["farmer"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("粮食产出每小时")},
    },

    ["orderHall"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("村落定期生成数量")},
    },
    ["palace"] = {
        {90,			130,		300},
        {_("等级"), _("力量"),_("联盟成员")},
    },
    ["shop"] = {
        {90,		130,			300},
        {_("等级"), _("力量"),_("可进货道具")},
    },
    ["shrine"] = {
        {90,		100,		200,			130},
        {_("等级"), _("力量"),_("资源存储上限"),_("感知力恢复每小时") }
    },
}

function GameUICityBuildingInfo:ctor(building)
    GameUICityBuildingInfo.super.ctor(self,674,Localize.building_name[building:GetType()])
    self.building = building
end

function GameUICityBuildingInfo:onEnter()
    GameUICityBuildingInfo.super.onEnter(self)
    local building = self.building
    local body = self:GetBody()
    local b_size = body:getContentSize()
    -- 总览介绍
    local total_title_bg = WidgetUIBackGround.new({width = 556 , height = 106},WidgetUIBackGround.STYLE_TYPE.STYLE_5)
        :align(display.TOP_CENTER, b_size.width/2, b_size.height - 30)
        :addTo(body)
    UIKit:ttfLabel({
        text = Localize.building_description[building:GetType()],
        size = 20,
        color = 0x615b44,
        dimensions = cc.size(540,0)
    }):align(display.CENTER, total_title_bg:getContentSize().width/2, total_title_bg:getContentSize().height/2)
        :addTo(total_title_bg)

    -- 详细信息

    local list_node = WidgetUIBackGround.new({width = 540,height = 490},WidgetUIBackGround.STYLE_TYPE.STYLE_6)

    list_node:addTo(body):align(display.TOP_CENTER, b_size.width/2, total_title_bg:getPositionY() - total_title_bg:getContentSize().height - 20)


    -- 建筑配置文件
    local config , building_name
    if string.find(building.__cname,"UpgradeBuilding") then
        config = building:GetFunctionConfig()
        building_name = building:GetType()
    else
        building_name = building.name
        config = AllianceBuilding[building_name]
    end
    if building_name then
        local flag = true
        local item_width = 520
        local list_info = building_details_map[building_name]
        local gap = list_info[1]
        local titles = list_info[2]
        local line_x = 0
        -- 标题
        local bg_image = flag and "upgrade_resources_background_2.png" or "upgrade_resources_background_3.png"
        local temp_labels = {} -- 创建出所有label，找出高度最高的
        local max_height = 0
        local list_width = 0
        for i = 1,#gap do
            list_width = list_width + gap[i]
            local x = list_width - gap[i]/2
            -- 每个label居中，宽度小于设定列宽 10
            local label = UIKit:ttfLabel({
                text = titles[i],
                size = 20,
                color = 0x615b44,
                dimensions = cc.size(gap[i],0),
                align = cc.TEXT_ALIGNMENT_CENTER,
            }):align(display.CENTER)
            label:setPositionX(x)
            max_height = math.max(label:getContentSize().height,max_height)
            table.insert(temp_labels, label)
        end
        max_height = max_height + 20
        local title_bg = display.newScale9Sprite(bg_image,0,0,cc.size(item_width,max_height),cc.rect(10,10,500,26))
            :align(display.TOP_CENTER, list_node:getContentSize().width/2, list_node:getContentSize().height-10)
            :addTo(list_node)
        for i,v in ipairs(temp_labels) do
            v:addTo(title_bg)
            v:setPositionY(max_height/2)
        end
        local list = UIListView.new({
            direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
            viewRect = cc.rect(0, 0,item_width,468 - max_height),
        -- bgColor = UIKit:hex2c4b(0x7a002200),
        }):addTo(list_node):pos(10,12)

        for i,v in ipairs(config) do
            local temp_labels = {} -- 创建出所有label，找出高度最高的
            local max_height = 0
            local list_width = 0
            for i = 1,#gap do
                list_width = list_width + gap[i]
                local x = list_width - gap[i]/2
                -- 每个label居中，宽度小于设定列宽 10
                local label = UIKit:ttfLabel({
                    text = titles[i],
                    size = 20,
                    color = 0x615b44,
                    dimensions = cc.size(gap[i],0),
                    align = cc.TEXT_ALIGNMENT_CENTER,
                }):align(display.CENTER)
                label:setPositionX(x)
                max_height = math.max(label:getContentSize().height,max_height)
                table.insert(temp_labels, label)
            end
        end

        for i=1,#gap do
            -- 分割线
            if i < #gap then
                line_x = line_x + gap[i]
                display.newSprite("line_1x473.png",10+line_x,list_node:getContentSize().height/2)
                    :addTo(list_node)
            end
        end
    end
end

function GameUICityBuildingInfo:onExit()
    GameUICityBuildingInfo.super.onExit(self)
end

return GameUICityBuildingInfo














