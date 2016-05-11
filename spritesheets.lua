function load(spr, tw, th)
	-- takes a spritesheet file(PNG) and some tile sizes and returns the spritesheet object and its QUADS
	local spritesheet = love.graphics.newImage(spr)
	local quads = {}
	local spritesheetW, spritesheetH = spritesheet:getWidth(), spritesheet:getHeight()
	local spritesheetTilesW,spritesheetTilesH = spritesheetW/tw, spritesheetH/th
	for b=0, spritesheetTilesW do
		for a=0, spritesheetTilesH do
			quads[a+b*spritesheetTilesH] = love.graphics.newQuad(a*tw,b*th,tw,th,spritesheetW,spritesheetH)
		end
	end
	return spritesheet, quads
end

return
{
	load = load,
}