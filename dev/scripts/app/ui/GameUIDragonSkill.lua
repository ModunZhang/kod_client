--
-- Author: Danny He
-- Date: 2014-09-24 22:37:58
--
local WidgetUIBackGround = import("..widget.WidgetUIBackGround")
local GameUIDragonSkill = UIKit:createUIClass("GameUIDragonSkill")
local config_dragonSkill = GameDatas.DragonEyrie.dragonSkill
local BODY_HEIGHT = 450
local LISTVIEW_WIDTH = 547
local UIListView = import(".UIListView")
local Localize = import("..utils.Localize")
local WidgetPushButton = import("..widget.WidgetPushButton")
local DragonManager = import("..entity.DragonManager") 

function GameUIDragonSkill:ctor(building,skill)
	GameUIDragonSkill.super.ctor(self)
	self.skill = skill
  self.dragon_manager = building:GetDragonManager()
  self.dragon_manager:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
end

function GameUIDragonSkill:onEnter()
	GameUIDragonSkill.super.onEnter(self)
	self.backgroundImage = WidgetUIBackGround.new({height=BODY_HEIGHT}):addTo(self)
	self.backgroundImage:pos((display.width-self.backgroundImage:getContentSize().width)/2,display.height - self.backgroundImage:getContentSize().height - 280)
	local titleBar = display.newSprite("alliance_blue_title_600x42.png")
		:align(display.BOTTOM_LEFT, 2,self.backgroundImage:getContentSize().height - 15)
		:addTo(self.backgroundImage)

  self.mainTitleLabel = UIKit:ttfLabel({
       text = _("技能升级"),
       color = 0xffedae,
       align = cc.TEXT_ALIGNMENT_CENTER,
       size  = 24
    })
    :addTo(titleBar)
    :align(display.CENTER, 300, 22)
    self.titleBar = titleBar
  	local closeButton = cc.ui.UIPushButton.new({normal = "X_1.png",pressed = "X_2.png"}, {scale9 = false})
	   	:addTo(titleBar)
      :align(display.BOTTOM_RIGHT,titleBar:getContentSize().width+20, 0)
	   	:onButtonClicked(function ()
        self:leftButtonClicked()
	   	end)
	  display.newSprite("X_3.png")
	   	:addTo(closeButton)
	   	:pos(-32,30)

  local skillBg = display.newSprite("dragon_skill_box_84x84.png")
        :addTo(self.backgroundImage):align(display.LEFT_TOP,30,titleBar:getPositionY() - 20)
    display.newSprite("dragon_skill_70x70.png"):addTo(skillBg):pos(skillBg:getContentSize().width/2,skillBg:getContentSize().height/2)

  local titleLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = Localize.dragon_skill[self.skill:Name()] .. " (LV" .. self.skill:Level() .. ")",
        font = UIKit:getFontFilePath(),
        size = 24,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
	}):addTo(self.backgroundImage):align(display.LEFT_TOP,skillBg:getPositionX()+skillBg:getContentSize().width+20,skillBg:getPositionY()-10)
  self.titleLabel = titleLabel
	local descLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = self:GetSkillEffection(),
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x403c2f)
	}):addTo(self.backgroundImage):align(display.LEFT_TOP, skillBg:getPositionX()+skillBg:getContentSize().width+20, titleLabel:getPositionY()- titleLabel:getContentSize().height - 10)
  self.descLabel = descLabel
	local upgradeButton = WidgetPushButton.new({
    normal = "dragon_yellow_button.png",
    pressed = "dragon_yellow_button_h.png"}, {scale9 = false},{disabled = {name = "GRAY", params = {0.2, 0.3, 0.5, 0.1}}})
      :setButtonLabel("normal",cc.ui.UILabel.new({
          UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
          text = _("升级"),
          font = UIKit:getFontFilePath(),
          size = 24,
          align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
          color = UIKit:hex2c3b(0xfff3c7)
      }))
      :addTo(self.backgroundImage)
      :align(display.LEFT_BOTTOM,skillBg:getPositionX()+skillBg:getContentSize().width+260,skillBg:getPositionY()-skillBg:getContentSize().height)
      :onButtonClicked(function(event)
      		self:UpgradeButtonClicked()
      end)
    upgradeButton:setButtonEnabled(self:CanUpgrade())
    self.upgradeButton = upgradeButton
  local list_bg = UIKit:commonTitleBox(250):pos((self.backgroundImage:getContentSize().width-LISTVIEW_WIDTH)/2, 50):addTo(self.backgroundImage)

  UIKit:ttfLabel({
       text = _("升级条件"),
       size = 22,
       color = 0x403c2f
    }):align(display.CENTER_TOP,270,240):addTo(list_bg)
	self.listView = UIListView.new {
      viewRect = cc.rect(0, 10, LISTVIEW_WIDTH, 188),
      direction = cc.ui.UIScrollView.DIRECTION_VERTICAL,
  	}
  	:addTo(list_bg)
  	self:RefreshUI()
end

function GameUIDragonSkill:GetDragon()
  return self.dragon_manager:GetDragon(self.skill:Type())
end

function GameUIDragonSkill:RefreshUI()
  self.titleLabel:setString(Localize.dragon_skill[self.skill:Name()] .. " (LV" .. self.skill:Level() .. ")")
  self.descLabel:setString(self:GetSkillEffection())
	local requires = self:GetUpgradeSkillCost(self.skill.name,self.skill.level)
  self.listView:removeAllItems()
	for i,v in ipairs(requires) do
		local newItem = self.listView:newItem()
  		local content = self:GetListItem(i,v[1],v[2])
  		newItem:addContent(content)
  		newItem:setItemSize(content:getContentSize().width,45)
  		self.listView:addItem(newItem)
	end
  self.listView:reload()
  self.upgradeButton:setButtonEnabled(self:CanUpgrade())
end

function GameUIDragonSkill:onMoveOutStage()
  self.dragon_manager:RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnBasicChanged)
  GameUIDragonSkill.super.onMoveOutStage(self)
end

function GameUIDragonSkill:UpgradeButtonClicked()
  NetManager:getUpgradeDragonDragonSkillPromise(self.skill:Type(),self.skill:Key()):catch(function(err)
    dump(err:reason())
  end)
end

function GameUIDragonSkill:GetListItem(index,key,val)
	local bg = display.newSprite(string.format("box_bg_item_520x48_%d.png",index%2))
	local imageIcon = "dragon_energy_45x38.png"
	local title = _("能量")
	if key == "blood" then
		title = _("英雄之血")
		imageIcon = "dragonskill_blood_51x63.png"
	elseif key == "dragonLevel" then
		title = _("龙的等级")
		imageIcon = "dragonskill_xp_51x63.png"
	end
	local icon = display.newSprite(imageIcon):addTo(bg):pos(30,bg:getContentSize().height/2)
	icon:setScale(0.5)
	local titleLable = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = title,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_LEFT, 
        color = UIKit:hex2c3b(0x615b44)
	}):addTo(bg):pos(icon:getPositionX()+30,bg:getContentSize().height/2)

	local valLabel = cc.ui.UILabel.new({
        UILabelType = cc.ui.UILabel.LABEL_TYPE_TTF,
        text = val,
        font = UIKit:getFontFilePath(),
        size = 20,
        align = cc.ui.UILabel.TEXT_ALIGN_RIGHT, 
        color = UIKit:hex2c3b(0x403c2f)
	}):pos(bg:getContentSize().width - 50,bg:getContentSize().height/2):addTo(bg)
	return bg
end

function GameUIDragonSkill:GetUpgradeSkillCost()
    local config = self.skill:GetSkillConfig()
    local r = {
        {"energy",config.energyCostPerLevel},
        {"blood",math.pow(self.skill:Level()+1,2) * config.heroBloodCostPerLevel},
        {"dragonLevel",1}, --TODO: 配置表未配置暂时写死
    }
    return r
end

function GameUIDragonSkill:CanUpgrade()
  local requires = self:GetUpgradeSkillCost()
  local flag = City:GetResourceManager():GetEnergyResource():GetResourceValueByCurrentTime(app.timer:GetServerTime()) >= requires[1][2]
    and City:GetResourceManager():GetBloodResource():GetValue() >= requires[2][2]
    and self:GetDragon():Level() >= requires[3][2]
  return flag
end

function GameUIDragonSkill:GetSkillEffection()
  local config = self.skill:GetSkillConfig()
  local count  = string.format("%d%%",self.skill:Level() * config.effection * 100)
  return Localize.dragon_skill_effection[self.skill:Name()] .. " " .. count
end


function GameUIDragonSkill:OnBasicChanged()
  local dragon = self.dragon_manager:GetDragon(self.skill:Type())
  self.skill = dragon:GetSkillByKey(self.skill:Key())
  self:RefreshUI()
end

return GameUIDragonSkill