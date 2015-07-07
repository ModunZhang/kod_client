local DragonSprite = import(".DragonSprite")
local FunctionUpgradingSprite = import(".FunctionUpgradingSprite")
local DragonEyrieSprite = class("DragonEyrieSprite", FunctionUpgradingSprite)
local DragonManager = import("..entity.DragonManager")
local DRAGON_ZORDER = 1



local TIP_TAG = 101001
function DragonEyrieSprite:ctor(...)
    DragonEyrieSprite.super.ctor(self, ...)
    local dragon_manget = self:GetEntity():BelongCity():GetDragonEyrie():GetDragonManager()
    dragon_manget:AddListenOnType(self,DragonManager.LISTEN_TYPE.OnDefencedDragonChanged)
    self:ReloadSpriteCaseDragonDefencedChanged(dragon_manget:GetDefenceDragon())

    if self:HasUnHatedDragon() then
	    display.newNode():addTo(self):schedule(function()
	        self:DoAni()
	    end, 1)
	end
end
function DragonEyrieSprite:RefreshSprite()
    DragonEyrieSprite.super.RefreshSprite(self)
    self:DoAni()
end
function DragonEyrieSprite:ReloadSpriteCauseTerrainChanged()
end

function DragonEyrieSprite:ReloadSpriteCaseDragonDefencedChanged(dragon)
    if self.dragon_sprite and not dragon then
        self.dragon_sprite:removeSelf()
        self.dragon_sprite = nil
    elseif dragon then
        if not self.dragon_sprite then
            local x, y = self:GetSpriteOffset()
            self.dragon_sprite = DragonSprite.new(self:GetMapLayer(),dragon:GetTerrain()):addTo(self, DRAGON_ZORDER):scale(0.5):pos(x+20, y+100)
        else
            self.dragon_sprite:ReloadSpriteCauseTerrainChanged(dragon:GetTerrain())
        end
    end
end

function DragonEyrieSprite:OnDefencedDragonChanged(dragon)
    self:ReloadSpriteCaseDragonDefencedChanged(dragon)
end


function DragonEyrieSprite:onCleanup()
    self:GetEntity():BelongCity():GetDragonEyrie():GetDragonManager():RemoveListenerOnType(self,DragonManager.LISTEN_TYPE.OnDefencedDragonChanged)
    if DragonEyrieSprite.super.onCleanup then
        DragonEyrieSprite.super.onCleanup(self)
    end
end

function DragonEyrieSprite:DoAni()
    if self:GetEntity():IsUnlocked() then
        if self:HasUnHatedDragon() then
            if not self:getChildByTag(TIP_TAG) then
                local x,y = self:GetSpriteTopPosition()
                y = y + 30
                display.newSprite("tmp_tips_74x80.png")
                    :addTo(self,1,TIP_TAG):align(display.BOTTOM_CENTER,x,y)
                    :runAction(UIKit:ShakeAction(true, 2))
            end
        else
            self:removeChildByTag(TIP_TAG)
        end
    end
end
function DragonEyrieSprite:HasUnHatedDragon()
    local manager = self:GetEntity():BelongCity():GetDragonEyrie():GetDragonManager()
    local hated_count = 0
    if manager:HaveDragonHateEvent() then
        hated_count = hated_count + 1
    end
    for _,dragon in pairs(manager:GetDragons()) do
        if dragon:Ishated() then
            hated_count = hated_count + 1
        end
    end
    return hated_count < 3
end






return DragonEyrieSprite




















