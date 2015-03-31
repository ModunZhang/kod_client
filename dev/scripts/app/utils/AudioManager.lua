--
-- Author: Danny He
-- Date: 2014-12-12 10:41:06
--
local AudioManager = class("AudioManager")

local bg_music_map = {
	MainScene = "music_begin.mp3",
	MyCityScene = "music_city.mp3",
	AllianceScene = "bgm_peace.mp3",
	PVEScene = "bgm_peace.mp3",
	AllianceBattleScene = "bgm_battle.mp3",
}

local bg_sound_map = {
	MyCityScene = "sfx_peace.mp3"
}

local effect_sound_map = {
	NORMAL_DOWN = "sfx_tap_button.wav",
	NORMAL_UP = "ui_button_down.wav",
	HOME_PAGE = "sfx_tap_homePage.wav",
	OPEN_MAIL = "sfx_open_mail.wav",
	USE_ITEM = "sfx_use_item.wav",
	BUY_ITEM = "sfx_buy_item.wav",
	COMPLETE = "sfx_complete.wav",
	TROOP_LOSE = "sfx_troop_lose.wav",
	TROOP_SENDOUT = "sfx_troop_sendOut.wav",
	SPLASH_BUTTON_START = "sfx_click_start.mp3",
	UI_BUILDING_UPGRADE_START = "sfx_building_upgrade.wav",
	UI_BUILDING_DESTROY = "sfx_building_destroy.wav",
	UI_BLACKSMITH_FORGE = "ui_blacksmith_forge.mp3",
	UI_TOOLSHOP_CRAFT_START = "ui_toolShop_craft_start.mp3"
}

local soldier_step_sfx_map = {
	infantry = {"sfx_step_infantry01.wav", "sfx_step_infantry02.wav", "sfx_step_infantry03.wav"}
}

local building_sfx_map = {
    keep = {"sfx_select_keep.wav"},
    watchTower = {"sfx_select_watchtower.wav"},
    warehouse = {"sfx_select_warehouse.wav"},
    dragonEyrie = {"sfx_select_dragon1.wav", "sfx_select_dragon2.wav", "sfx_select_dragon3.wav"},
    barracks = {"sfx_select_barracks.wav"},
    hospital = {"sfx_select_hospital.wav"},
    academy = {"sfx_select_academy.wav"},
    materialDepot = {"sfx_select_warehouse.wav"},
    blackSmith = {"sfx_select_blackSmith.wav"},
    foundry = {"sfx_select_foundry.wav"},
    hunterHall = {"sfx_select_hunterHall.wav"},
    lumbermill = {"sfx_select_lumbermill.wav"},
    stoneMason = {"sfx_select_stonemason.wav"},
    mill = {"sfx_select_mill.wav"},
    townHall = {"sfx_select_townHall.wav"},
    toolShop = {"sfx_select_toolshop.wav"},
    tradeGuild = {"sfx_select_tradeGuild.wav"},
    trainingGround = {"sfx_select_trainingGround.wav"},
    hunterHall = {"sfx_select_hunterHall.wav"},
    workshop = {"sfx_select_workshop.wav"},
    stable = {"sfx_select_stable.wav"},
    wall = {"sfx_select_wall.wav"},
    tower = {"sfx_select_tower.wav"},
    dwelling = {"sfx_select_dwelling.wav"},
    farmer = {"sfx_select_resourceBuilding.wav"},
    woodcutter = {"sfx_select_resourceBuilding.wav"},
    quarrier = {"sfx_select_resourceBuilding.wav"},
    miner = {"sfx_select_resourceBuilding.wav"},
}


local BACKGROUND_MUSIC_KEY = "BACKGROUND_MUSIC_KEY"
local EFFECT_MUSIC_KEY = "EFFECT_MUSIC_KEY"

-------------------------------------------------------------------------

function AudioManager:ctor(game_default)
	self.game_default = game_default
	self.is_bg_auido_on = self:GetGameDefault():getBasicInfoValueForKey(BACKGROUND_MUSIC_KEY,true)
	self.is_effect_audio_on = self:GetGameDefault():getBasicInfoValueForKey(EFFECT_MUSIC_KEY,true)
	self:PreLoadAudio()
end

function AudioManager:GetGameDefault()
	return self.game_default
end
--预加载音乐到内存(android)
function AudioManager:PreLoadAudio()

end


function AudioManager:PlayeBgMusic(filename)
	if self.is_bg_auido_on then
		audio.playMusic("audios/" .. filename,true)
	end
end

function AudioManager:PlayeBgSound(filename)
	if self.is_bg_auido_on then
		audio.playSound("audios/" .. filename,true)
	end
end

function AudioManager:PlayeEffectSound(filename)
	if self.is_effect_audio_on then
		audio.playSound("audios/" .. filename,false)
	end
end

function AudioManager:PlayeAttackSoundBySoldierName(soldier_name)
	local audio_name = string.format("sfx_%s_attack.wav", soldier_name)
	assert(audio_name, audio_name.." 音乐不存在")
	self:PlayeEffectSound(audio_name)
end

--Api normal
function AudioManager:PlayBuildingEffectByType(type_)
	local sfx = building_sfx_map[type_]
	if sfx then
		self:PlayeEffectSound(sfx[math.random(#sfx)])
	end
end
function AudioManager:PlaySoldierStepEffectByType(type_)
	local sfx = soldier_step_sfx_map[type_]
	if sfx then
		print(sfx[math.random(#sfx)])
		self:PlayeEffectSound(sfx[math.random(#sfx)])
	end
end

function AudioManager:PlayGameMusic(scene_name)
	local file_key = scene_name or display.getRunningScene().__cname
	print("PlayGameMusic---->",file_key)
 	if bg_music_map[file_key] then
		self:PlayeBgMusic(bg_music_map[file_key])
	end
	-- if bg_sound_map[file_key] then
	-- 	self:PlayeBgSound(bg_sound_map[file_key])
	-- end
end

function AudioManager:PlayeEffectSoundWithKey(key)
	print("PlayeEffectSoundWithKey---->",key)
	self:PlayeEffectSound(self:GetEffectAudio(key))
end

function AudioManager:GetEffectAudio(key)
	return effect_sound_map[key]
end

function AudioManager:StopMusic()
	audio.stopMusic()
end

function AudioManager:StopEffectSound()
	self.is_effect_audio_on = false
	audio.stopAllSounds()
end

--control 
function AudioManager:SwitchBackgroundMusicState(isOn)
	isOn = checkbool(isOn)
	if self.is_bg_auido_on == isOn then return end
	self.is_bg_auido_on = isOn 
	if isOn then
		self:PlayGameMusic()
	else
		self:StopMusic()
	end
	self:GetGameDefault():setBasicInfoBoolValueForKey(BACKGROUND_MUSIC_KEY,isOn)
	self:GetGameDefault():flush()
	if not isOn then audio.stopAllSounds() end --关闭主城的两重音乐
end

function AudioManager:GetBackgroundMusicState()
	return self.is_bg_auido_on
end

function AudioManager:SwitchEffectSoundState(isOn)
	isOn = checkbool(isOn)
	if self.is_effect_audio_on == isOn then return end
	self.is_effect_audio_on = isOn
	self:GetGameDefault():setBasicInfoBoolValueForKey(EFFECT_MUSIC_KEY,isOn)
	self:GetGameDefault():flush()
end

function AudioManager:GetEffectSoundState()
	return self.is_effect_audio_on
end

function AudioManager:StopAll()
	self:StopMusic()
	self:StopEffectSound()
end

return AudioManager
