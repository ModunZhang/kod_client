print("加载玩家自定义函数!")

NOT_HANDLE = function(...) print("net message not handel, please check !") end

local old_ctor = cc.ui.UIPushButton.ctor
function cc.ui.UIPushButton:ctor(...)
    old_ctor(self, ...)
    self:addButtonPressedEventListener(function(event)
        audio.playSound("audios/ui_button_down.wav")
    end)
    self:addButtonReleaseEventListener(function(event)
        audio.playSound("audios/ui_button_up.wav")
    end)
end

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