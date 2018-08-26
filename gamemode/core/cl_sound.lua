--[[
	Filename: cl_sound.lua
	Description: Sound wrapper that is object oriented and allows for a ton of cool features like registering attentuation types and reverb properties.
	Also allows for sound cues which allow mixing, crossfading, adding noise, etc.
--]]

-- # Micro-ops
local rain = rain

rain.sound = {}

function rain.sound:PlayMenuMusic()
	if (!self.MenuMusic) then
		self.MenuMusic = CreateSound(LocalPlayer(), "stalker/music/menu_theme.mp3")
		self.MenuMusic:Play()
	end
end

function rain.sound:StopMenuMusic()
	if (self.MenuMusic) then
		self.MenuMusic:FadeOut(1)
		self.MenuMusic = nil
	end
end