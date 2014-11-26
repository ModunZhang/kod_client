--
-- Author: Danny He
-- Date: 2014-11-20 21:51:12
--
--TODO:周期性的请求对方联盟数据
local AllianceScene = import(".AllianceScene")
local EnemyAllianceScene = class("EnemyAllianceScene", AllianceScene)
local GameUIAllianceEnter = import("..ui.GameUIAllianceEnter")

function EnemyAllianceScene:ctor(alliance)
	self.alliance_ = alliance
	dump(self:GetAlliance())
	EnemyAllianceScene.super.ctor(self)
end

function EnemyAllianceScene:OnTouchClicked(pre_x, pre_y, x, y)
	local building = self:GetSceneLayer():GetClickedObject(x, y)
    if building then
        dump(building:GetEntity())
        if building:GetEntity():GetType() ~= "building" then
            UIKit:newGameUI('GameUIAllianceEnter',self:GetAlliance(),building:GetEntity(),GameUIAllianceEnter.MODE.Enemy):addToCurrentScene(true)
        else
            local building_info = building:GetEntity():GetAllianceBuildingInfo()
            print("index x y ",x,y,building_info.name)
            LuaUtils:outputTable("building_info", building_info)
            UIKit:newGameUI('GameUIAllianceEnter',self:GetAlliance(),building_info,GameUIAllianceEnter.MODE.Enemy):addToCurrentScene(true)
        end
    end
end

function EnemyAllianceScene:GetAlliance()
	return self.alliance_
end

function EnemyAllianceScene:CreateAllianceUI()
	local home = UIKit:newGameUI('GameUIEnemyAllianceHome'):addToScene(self)
    self:GetSceneLayer():AddObserver(home)
    home:setTouchSwallowEnabled(false)
end
return EnemyAllianceScene