--
-- Author: Danny He
-- Date: 2014-12-29 16:28:23
--
local GameUIAllianceCityEnter = UIKit:createUIClass("GameUIAllianceCityEnter","GameUIAllianceEnterBase")
local config_wall = GameDatas.BuildingFunction.wall
local FullScreenPopDialogUI = import(".FullScreenPopDialogUI")
local GameUIWriteMail = import(".GameUIWriteMail")

function GameUIAllianceCityEnter:ctor(building,isMyAlliance,my_alliance,enemy_alliance)
	GameUIAllianceCityEnter.super.ctor(self,building,my_alliance)
	self.isMyAlliance = isMyAlliance
	self.enemy_alliance = enemy_alliance
	local x,y = self:GetBuilding():GetLogicPosition()
	self.member = self:GetPlayerByLocation(x,y)
end

function GameUIAllianceCityEnter:IsMyAlliance()
	return self.isMyAlliance
end

function GameUIAllianceCityEnter:GetMember()
	return self.member
end

function GameUIAllianceCityEnter:GetLevelLabelText()
	return "LEVEL " .. self:GetMember():KeepLevel()
end

function GameUIAllianceCityEnter:GetProcessLabelText()
	return self:GetMember():WallHp() .. "/" .. config_wall[self:GetMember():WallLevel()].wallHp
end
function GameUIAllianceCityEnter:GetCurrentAlliance()
	return self.isMyAlliance and self:GetMyAlliance() or self:GetEnemyAlliance()
end


function GameUIAllianceCityEnter:GetPlayerByLocation( x,y )
    for _,member in pairs(self:GetCurrentAlliance():GetAllMembers()) do
        print(member.location.x,member.location.y)
        if member.location.x == x and y == member.location.y then
            return member
        end
    end
end

function GameUIAllianceCityEnter:GetBuildingInfoOriginalY()
    return self.process_bar_bg:getPositionY()-self.process_bar_bg:getContentSize().height-40
end
function GameUIAllianceCityEnter:FixedUI()
    self:GetDescLabel():hide()
    self:GetHonourIcon():hide()
    self:GetHonourLabel():hide()
    self:GetProgressTimer():setPercentage(self:GetMember():WallHp()/config_wall[self:GetMember():WallLevel()].wallHp * 100)
end

function GameUIAllianceCityEnter:GetEnemyAlliance()
	return self.enemy_alliance
end

function GameUIAllianceCityEnter:GetUIHeight()
	return 311
end

function GameUIAllianceCityEnter:GetUITitle()
	return self:GetMember().name
end

function GameUIAllianceCityEnter:GetBuildingImage()
	return "keep_760x855.png"
end

function GameUIAllianceCityEnter:GetBuildingCategory()
	return 'member'
end

function GameUIAllianceCityEnter:GetBuildingDesc()
	return "本地化缺失"
end


function GameUIAllianceCityEnter:GetBuildingInfo()
	local location = {
        {_("坐标"),0x797154},
        {self:GetLocation(),0x403c2f},
    }
    local player_name = {
	    {_("玩家"),0x797154},
	    {self:GetMember().name,0x403c2f},
    }
    
    local help_count = {
        {_("协防玩家"),0x797154},
        {self:GetMember().helpedByTroopsCount,0x403c2f},
	}
  	return {location,player_name,help_count}
end

function GameUIAllianceCityEnter:GetEnterButtons()
	local buttons = {}
	local member = self:GetMember()
	if self:IsMyAlliance() then --自己
		local alliance = self:GetMyAlliance()
		if DataManager:getUserData()._id == self:GetMember():Id() then
		    local enter_button = self:BuildOneButton("playercity_66x83.png",_("进入")):onButtonClicked(function()
				app:EnterMyCityScene()
				self:leftButtonClicked()
			end)
			buttons = {enter_button}
	    else --盟友
	    	local help_button
		    local can_not_help_in_city = City:IsHelpedToTroopsWithPlayerId(member:Id())
		    if can_not_help_in_city then
		    	help_button = self:BuildOneButton("help_defense_55x69.png",_("撤防")):onButtonClicked(function()
					 NetManager:getRetreatFromHelpedAllianceMemberPromise(member:Id()):catch(function(err)
		                dump(err:reason())
		            end)
				end)
		    else
				help_button = self:BuildOneButton("help_defense_55x69.png",_("协防")):onButtonClicked(function()
					local playerId = member:Id()
		            if not alliance:CheckHelpDefenceMarchEventsHaveTarget(playerId) then
		                UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
		                    NetManager:getHelpAllianceMemberDefencePromise(dragonType, soldiers, playerId)
		                end):addToCurrentScene(true)
						self:leftButtonClicked()
		            else
		                local dialog = FullScreenPopDialogUI.new()
		                dialog:SetTitle(_("错误"))
		                dialog:SetPopMessage(_("已有协防部队正在行军"))
		                dialog:AddToCurrentScene()
		                self:leftButtonClicked()
		                return
		            end
				end)
		    end
		    local enter_button = self:BuildOneButton("playercity_66x83.png",_("进入")):onButtonClicked(function()
                app:EnterPlayerCityScene(member:Id())
				self:leftButtonClicked()
			end)
			local mail_button = self:BuildOneButton("mail_70x55.png",_("邮件")):onButtonClicked(function()
                local mail = GameUIWriteMail.new()
                    mail:SetTitle(_("个人邮件"))
                    mail:SetAddressee(member:Name())
                    mail:OnSendButtonClicked( GameUIWriteMail.SEND_TYPE.PERSONAL_MAIL)
					mail:addToCurrentScene()
				self:leftButtonClicked()
			end)
			local info_button = self:BuildOneButton("icon_info_1.png",_("信息")):onButtonClicked(function()
                UIKit:newGameUI("GameUIAllianceMemberInfo",true,member:Id()):addToCurrentScene(true)
				self:leftButtonClicked()
			end)
		    buttons = {help_button,enter_button,mail_button,info_button}
		end
	else -- 敌方玩家
		local attack_button = self:BuildOneButton("attack_80x66.png",_("进攻")):onButtonClicked(function()
			UIKit:newGameUI('GameUIAllianceSendTroops',function(dragonType,soldiers)
                NetManager:getAttackPlayerCityPromise(dragonType, soldiers, member:Id())
            end):addToCurrentScene(true)
			self:leftButtonClicked()
		end)
		local strike_button = self:BuildOneButton("Strike_72x72.png",_("突袭")):onButtonClicked(function()
			UIKit:newGameUI("GameUIStrikePlayer",member:Id()):addToCurrentScene(true)
			self:leftButtonClicked()
		end)
		local enter_button = self:BuildOneButton("playercity_66x83.png",_("进入")):onButtonClicked(function()
			app:EnterPlayerCityScene(member:Id())
			self:leftButtonClicked()
		end)
		local info_button = self:BuildOneButton("icon_info_1.png",_("信息")):onButtonClicked(function()
			UIKit:newGameUI("GameUIAllianceMemberInfo",true,member:Id()):addToCurrentScene(true)
			self:leftButtonClicked()
		end)
		buttons = {attack_button,strike_button,enter_button,info_button}
	end
 	return buttons
end

return GameUIAllianceCityEnter