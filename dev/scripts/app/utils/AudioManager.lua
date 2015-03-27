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
	NORMAL_DOWN = "ui_button_down.wav",
	NORMAL_UP = "ui_button_down.wav",
	SPLASH_BUTTON_START = "sfx_click_start.mp3",
	UI_BUILDING_UPGRADE_START = "ui_building_upgrade_start.mp3",
	UI_BLACKSMITH_FORGE = "ui_blacksmith_forge.mp3",
	UI_TOOLSHOP_CRAFT_START = "ui_toolShop_craft_start.mp3"
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

function AudioManager:PlayGameMusic(scene_name)
	local file_key = scene_name or display.getRunningScene().__cname
	print("PlayGameMusic---->",file_key)
 	if bg_music_map[file_key] then
		self:PlayeBgMusic(bg_music_map[file_key])
	end
	if bg_sound_map[file_key] then
		self:PlayeBgSound(bg_sound_map[file_key])
	end
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
