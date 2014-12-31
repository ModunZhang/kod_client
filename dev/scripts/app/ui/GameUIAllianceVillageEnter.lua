--
-- Author: Danny He
-- Date: 2014-12-29 16:35:40
--
local GameUIAllianceVillageEnter = UIKit:createUIClass("GameUIAllianceVillageEnter","GameUIAllianceEnterBase")
local Localize = import("..utils.Localize")
local VillageEvent = import("..entity.VillageEvent")
local GameUIStrikePlayer = import(".GameUIStrikePlayer")

function GameUIAllianceVillageEnter:ctor(building,isMyAlliance,my_alliance,enemy_alliance)
	GameUIAllianceVillageEnter.super.ctor(self,building,isMyAlliance,my_alliance)
	self.enemy_alliance = enemy_alliance
	-- self.isMyAlliance   = isMyAlliance
	self.village_info = building:GetAllianceVillageInfo()
	dump(self.village_info,"self.village_info--->")
end


-- function GameUIAllianceVillageEnter:IsMyAlliance()
-- 	return self.isMyAlliance
-- end

function GameUIAllianceVillageEnter:GetVillageInfo()
	return self.village_info
end

function GameUIAllianceVillageEnter:GetProcessIcon()
	return "res_food_114x100.png",0.4
end

function GameUIAllianceVillageEnter:HasEnemyAlliance()
	return self:GetEnemyAlliance() ~= nil
end

function GameUIAllianceVillageEnter:GetEnemyAlliance()
	return self.enemy_alliance
end

function GameUIAllianceVillageEnter:GetBuildingInfoOriginalY()
	return self.process_bar_bg:getPositionY()-self.process_bar_bg:getContentSize().height-40
end
function GameUIAllianceVillageEnter:GetUIHeight()
	return 311
end

function GameUIAllianceVillageEnter:GetProcessLabelText()
	return ""
end

function GameUIAllianceVillageEnter:FixedUI()
	self:GetDescLabel():hide()
	self:GetHonourIcon():hide()
	self:GetHonourLabel():hide()
end

function GameUIAllianceVillageEnter:GetUITitle()
	return Localize.village_name[self:GetBuilding():GetType()]
end

function GameUIAllianceVillageEnter:GetBuildingImage()
	return "woodcutter_1_342x250.png"
end

function GameUIAllianceVillageEnter:GetBuildingCategory()
	return 'village'
end

function GameUIAllianceVillageEnter:GetBuildingDesc()
	return "本地化缺失"
end


function GameUIAllianceVillageEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
	local labels = {}
    local village_id = self:GetVillageInfo().id
	local villageEvent = self:GetMyAlliance():FindVillageEventByVillageId(village_id)
 	if not villageEvent  then --我方未占领
 		if self:HasEnemyAlliance() then
	 		villageEvent = self:GetEnemyAlliance():FindVillageEventByVillageId(village_id)
		    if villageEvent then  --敌方联盟人占领
		      	local occupy_label = {
            		{_("占领者"),0x797154},
            		{villageEvent:PlayerData().name,0x403c2f}
        		}
        		local current_collect_label =  {
		            {_("当前采集"),0x797154},
		            {villageEvent:CollectCount() .. "(" .. villageEvent:CollectPercent()  .. "%)",0x403c2f,900},
        		}
        		local end_time_label = {
		            {_("完成时间"),0x797154},
		            {
		                villageEvent:GetTime() == 0 and _("已完成") or GameUtils:formatTimeStyle1(villageEvent:GetTime()),
		                0x403c2f,
		                1000
		            },
        		}
        		labels = {location,occupy_label,current_collect_label,end_time_label}
        		local str = self:GetVillageInfo().resource - villageEvent:CollectCount() .. "/" .. VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
				local percent = (self:GetVillageInfo().resource - villageEvent:CollectCount())/VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
				self:GetProgressTimer():setPercentage(percent*100)
				self:GetProcessLabel():setString(str)
				self:GetEnemyAlliance():AddListenOnType(self,self:GetEnemyAlliance().LISTEN_TYPE.OnVillageEventTimer)
				self:GetEnemyAlliance():AddListenOnType(self,self:GetEnemyAlliance().LISTEN_TYPE.OnVillageEventsDataChanged)
		    else --没人占领
		    	local no_one_label = {
		            {_("占领者"),0x797154},
		            {_("无"),0x403c2f}
        		}
        		labels = {location,no_one_label}
        		local str = self:GetVillageInfo().resource .. "/" .. VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
				local percent = self:GetVillageInfo().resource/VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
				self:GetProgressTimer():setPercentage(percent*100)
				self:GetProcessLabel():setString(str)
		    end
		else --没人占领
			local no_one_label = {
		        {_("占领者"),0x797154},
		        {_("无"),0x403c2f}
			}
			labels = {location,no_one_label}
			local str = self:GetVillageInfo().resource .. "/" .. VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
			local percent = self:GetVillageInfo().resource/VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
			self:GetProgressTimer():setPercentage(percent*100)
			self:GetProcessLabel():setString(str)
		end
	else --我方占领
		local occupy_label = {
            		{_("占领者"),0x797154},
            		{villageEvent:PlayerData().name,0x403c2f}
        		}
		local current_collect_label =  {
            {_("当前采集"),0x797154},
             {villageEvent:CollectCount() .. "(" .. villageEvent:CollectPercent()  .. "%)",0x403c2f,900},
		}
		local end_time_label = {
            {_("完成时间"),0x797154},
            {
                villageEvent:GetTime() == 0 and _("已完成") or GameUtils:formatTimeStyle1(villageEvent:GetTime()),
                0x403c2f,
                1000
            },
		}
		labels = {location,occupy_label,current_collect_label,end_time_label}
		local str = self:GetVillageInfo().resource - villageEvent:CollectCount() .. "/" .. VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
		local percent = (self:GetVillageInfo().resource - villageEvent:CollectCount())/VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
		self:GetProgressTimer():setPercentage(percent*100)
		self:GetProcessLabel():setString(str)
		self:GetMyAlliance():AddListenOnType(self,self:GetMyAlliance().LISTEN_TYPE.OnVillageEventTimer)
		self:GetMyAlliance():AddListenOnType(self,self:GetMyAlliance().LISTEN_TYPE.OnVillageEventsDataChanged)
 	end
  	return labels
end

function GameUIAllianceVillageEnter:OnVillageEventTimer(village_event,left_resource)
	if village_event:VillageData().id == self:GetVillageInfo().id then
		local str = left_resource .. "/" .. VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
		local percent = left_resource/VillageEvent.GetVillageConfig(self:GetVillageInfo().type,self:GetVillageInfo().level).production
		self:GetProgressTimer():setPercentage(percent*100)
		self:GetProcessLabel():setString(str)
		local label = self:GetInfoLabelByTag(900)
		if label then
			label:setString(village_event:CollectCount() .. "(" .. village_event:CollectPercent() .. "%)")
		end
		local label = self:GetInfoLabelByTag(1000)
		if label then
			label:setString(GameUtils:formatTimeStyle1(village_event:GetTime()))
		end
	end
end

function GameUIAllianceVillageEnter:OnVillageEventsDataChanged(changed_map)
	if changed_map.removed then
		for _,v in ipairs(changed_map.removed) do
			if v:VillageData().id == self:GetVillageInfo().id then
				self:leftButtonClicked()
			end
		end
	end
end

function GameUIAllianceVillageEnter:GetLevelLabelText()
	return _("等级") .. self:GetVillageInfo().level
end

function GameUIAllianceVillageEnter:GetEnterButtons()
	local buttons = {}
	local village_id = self:GetVillageInfo().id
    local villageEvent = self:GetMyAlliance():FindVillageEventByVillageId(village_id)
 	if not villageEvent  then --我方未占领
 		if self:HasEnemyAlliance() then
	 		villageEvent = self:GetEnemyAlliance():FindVillageEventByVillageId(village_id)
		    if villageEvent then  --敌方联盟人占领
		        local attack_button = self:BuildOneButton("village_capture_66x72.png",_("占领")):onButtonClicked(function()
					UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
	                    NetManager:getAttackVillagePromise(dragonType,soldiers,villageEvent:VillageData().alliance.id,village_id)
	                end):addToCurrentScene(true)
					self:leftButtonClicked()
				end)
				local strike_button = self:BuildOneButton("Strike_72x72.png",_("突袭")):onButtonClicked(function()
					UIKit:newGameUI("GameUIStrikePlayer",{defenceAllianceId = villageEvent:VillageData().alliance.id,defenceVillageId = village_id},GameUIStrikePlayer.STRIKE_TYPE.VILLAGE):addToCurrentScene(true)
					self:leftButtonClicked()
				end)
				buttons = {attack_button,strike_button}
		    else --没人占领
		    	local alliance_id = self:IsMyAlliance() and self:GetMyAlliance():Id() or self:GetEnemyAlliance():Id() 
		     	local attack_button = self:BuildOneButton("village_capture_66x72.png",_("占领")):onButtonClicked(function()
					UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
	                    NetManager:getAttackVillagePromise(dragonType,soldiers,alliance_id,village_id)
	                end):addToCurrentScene(true)
					self:leftButtonClicked()
				end)
				local strike_button = self:BuildOneButton("Strike_72x72.png",_("突袭")):onButtonClicked(function()
					UIKit:newGameUI("GameUIStrikePlayer",{defenceAllianceId = alliance_id,defenceVillageId = village_id},GameUIStrikePlayer.STRIKE_TYPE.VILLAGE):addToCurrentScene(true)
					self:leftButtonClicked()
				end)
				buttons = {attack_button,strike_button}
		    end
		else --没人占领
			local alliance_id = self:IsMyAlliance() and self:GetMyAlliance():Id() or self:GetEnemyAlliance():Id() 
	     	local attack_button = self:BuildOneButton("village_capture_66x72.png",_("占领")):onButtonClicked(function()
				UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
                    NetManager:getAttackVillagePromise(dragonType,soldiers,alliance_id,village_id)
                end):addToCurrentScene(true)
				self:leftButtonClicked()
			end)
			local strike_button = self:BuildOneButton("Strike_72x72.png",_("突袭")):onButtonClicked(function()
				UIKit:newGameUI("GameUIStrikePlayer",{defenceAllianceId = alliance_id,defenceVillageId = village_id},GameUIStrikePlayer.STRIKE_TYPE.VILLAGE):addToCurrentScene(true)
				self:leftButtonClicked()
			end)
			buttons = {attack_button,strike_button}
		end
	else --我方占领
		if villageEvent:GetPlayerRole() == villageEvent.EVENT_PLAYER_ROLE.Me then --自己占领
			local che_button = self:BuildOneButton("village_capture_66x72.png",_("撤军")):onButtonClicked(function()
				NetManager:getRetreatFromVillagePromise(villageEvent:VillageData().alliance.id,villageEvent:Id())
				self:leftButtonClicked()
			end)
	        buttons =  {che_button}
	    elseif villageEvent:GetPlayerRole() ==   villageEvent.EVENT_PLAYER_ROLE.Ally then --盟友占领
	    	local huan_fang_button = self:BuildOneButton("village_capture_66x72.png",_("换防")):onButtonClicked(function()
				UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
                    NetManager:getAttackVillagePromise(dragonType,soldiers,villageEvent:VillageData().alliance.id,village_id)
	            end):addToCurrentScene(true)
				self:leftButtonClicked()
			end)
	        buttons =  {huan_fang_button}
	    end
 	end
 	return buttons
end

function GameUIAllianceVillageEnter:onMoveOutStage()
	self:GetMyAlliance():RemoveListenerOnType(self,self:GetMyAlliance().LISTEN_TYPE.OnVillageEventTimer)
	self:GetMyAlliance():RemoveListenerOnType(self,self:GetMyAlliance().LISTEN_TYPE.OnVillageEventsDataChanged)
	if self:HasEnemyAlliance() then
		self:GetEnemyAlliance():RemoveListenerOnType(self,self:GetEnemyAlliance().LISTEN_TYPE.OnVillageEventTimer)
		self:GetEnemyAlliance():RemoveListenerOnType(self,self:GetEnemyAlliance().LISTEN_TYPE.OnVillageEventsDataChanged)
	end
	GameUIAllianceVillageEnter.super.onMoveOutStage(self)
end
return GameUIAllianceVillageEnter