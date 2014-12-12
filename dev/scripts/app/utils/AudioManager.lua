--
-- Author: Danny He
-- Date: 2014-12-12 10:41:06
--
AudioManager = {}
local bg_music_map = {
	MainScene = "music_begin.mp3",
	CityScene = "music_city.mp3",
}

local bg_sound_map = {
	CityScene = "sfx_peace.mp3"
}

local effect_sound_map = {
	NORMAL_DOWN = "ui_button_down.wav",
	NORMAL_UP = "ui_button_down.wav",
	SPLASH_BUTTON_START = "sfx_click_start.mp3",
	UI_BUILDING_UPGRADE_START = "ui_building_upgrade_start.mp3",
	UI_BLACKSMITH_FORGE = "ui_blacksmith_forge.mp3",
	UI_TOOLSHOP_CRAFT_START = "ui_toolShop_craft_start.mp3"
}

--over
local play_music = audio.playMusic
function audio.playMusic(filename, isLoop)
	if not CONFIG_PLAY_AUDIO then
		return 
	end
	return play_music(filename, isLoop)
end
local play_sound = audio.playSound
function audio.playSound(filename, isLoop)
	if not CONFIG_PLAY_AUDIO then
		return 
	end
	return play_sound(filename, isLoop)
end

-------------------------------------------------------------------------

function AudioManager:Init()
	self.is_bg_auido_on = true
	self.is_effect_audio_on = true
	self:PreLoadAudio()
end

--预加载音乐到内存
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

--Api normal

function AudioManager:PlayGameMusic(scene_name)
	local file_key = scene_name or display.getRunningScene().__cname
 	if bg_music_map[file_key] then
		self:PlayeBgMusic(bg_music_map[file_key])
	end
	if bg_sound_map[file_key] then
		self:PlayeBgSound(bg_sound_map[file_key])
	end
end

function AudioManager:PlayeEffectSoundWithKey(key)
	self:PlayeEffectSound(self:GetEffectAudio(key))
end

function AudioManager:GetEffectAudio(key)
	return effect_sound_map[key]
end