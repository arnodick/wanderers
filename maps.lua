function getflag(c,f)
	--takes the hex value from map cell and an integer flag position, returns true if that flag position is set
	local flag = 2^(f-1) --converts flag position to its actual number value (ie: f 1 = 1, f 2 = 2, f 3 = 4, f 4 = 8 etc.)
	if bit.band ( bit.rshift( c, 16 ), flag ) == flag then --checks if flag f is set in the map cell. ignores other flags.
		return true
	else
		return false
	end
end

function load(m)
	--loads map sprites and walls from a hex populated textfile, returns map array
	local map = textfile.load(m) --each cell (flags + integer) is loaded into map array
	for a=1, #map do
		for b=1, #map[a] do
			if getflag(map[a][b], 1) then
				makewall((b-1)*TileW, (a-1)*TileH, TileW, TileH) --each cell that has a wall flag loads a wall entity
			end
		end
	end
	return map
end

function draw(m)
	--draws the map, YO
	for b=1,#m do
		for a=1,#m[b] do
			love.graphics.draw( Spritesheet, Quads[ bit.band(m[b][a] - 1, 0x0000ffff) ],(a-1)*TileW,(b-1)*TileH) --bitwise AND is to get just the rightmost 16 bits (non-flag integer)
		end
	end
end

return
{
	getflag = getflag,
	load = load,
	draw = draw,
}