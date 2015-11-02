--
-- Author: Kenny Dai
-- Date: 2015-10-29 11:51:54
--
local WidgetPopDialog = import(".WidgetPopDialog")
local WidgetInfo = import(".WidgetInfo")
local WidgetPages = import(".WidgetPages")
local Localize = import("..utils.Localize")

local aliance_buff = GameDatas.AllianceMap.buff

local WidgetAllianceMapBuff = class("WidgetAllianceMapBuff", WidgetPopDialog)


function WidgetAllianceMapBuff:ctor(mapIndex)
    WidgetAllianceMapBuff.super.ctor(self,464,_("联盟地图BUFF"))
    local body = self:GetBody()
    local rb_size = body:getContentSize()

    local info_buff = WidgetInfo.new({
        h = 340
    }):align(display.BOTTOM_CENTER, rb_size.width/2 , 30)
        :addTo(body)

    local titles = {}
    for i=1,18 do
        table.insert(titles, string.format(_("第%d圈"),i))
    end
    WidgetPages.new({
        page = 18, -- 页数
        current_page = (DataUtils:getMapRoundByMapIndex(mapIndex) + 1) or 1,
        titles =  titles, -- 标题 type -> table
        cb = function (page)
            info_buff:SetInfo(
                self:GetAllianceMapBuffByRound(page)
            )
        end -- 回调
    }):align(display.CENTER, rb_size.width/2,rb_size.height-50)
        :addTo(body)


end

function WidgetAllianceMapBuff:GetAllianceMapBuffByRound( round )
    local buff = aliance_buff[round-1]
    local buff_info = {}

    for i,v in ipairs({"monsterLevel","villageAddPercent","dragonExpAddPercent","bloodAddPercent","marchSpeedAddPercent","dragonStrengthAddPercent","loyaltyAddPercent","honourAddPercent"}) do
        if v =="monsterLevel" then
            local levels = string.split(buff[v],"_")
            table.insert(buff_info, {
                Localize.alliance_buff[v],
                {string.format("Lv%s~Lv%s",levels[1],levels[2]),0x288400}
            })
        else
            table.insert(buff_info, {
                Localize.alliance_buff[v],
                {"+"..buff[v].."%",0x288400}
            })
        end
    end
    return buff_info
end

return WidgetAllianceMapBuff

