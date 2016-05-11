function getflag(c,f)
	--takes the hex value map cell and an integer flag position, returns true if that flag is set
	local flag = 2^(f-1) --converts flag position to its actual number value (ie: f 1 = 1, f 2 = 2, f 3 = 4, f 4 = 8 etc.)
	if bit.band ( bit.rshift( c, 16 ), flag ) == flag then --checks if flag f is set in the map cell. ignores other flags.
		return true
	else
		return false
	end
end

function load(m)
	local map = textfile.load(m)
	for a=1, #map do
		for b=1, #map[a] do
			if getflag(map[a][b], 1) then
				makewall((b-1)*TileW, (a-1)*TileH, TileW, TileH)
			end
		end
	end
	return map
end

function draw(m)
	for b=1,#m do
		for a=1,#m[b] do
			love.graphics.draw( Spritesheet, Quads[ bit.band(m[b][a] - 1, 0x0000ffff) ],(a-1)*TileW,(b-1)*TileH) --bitwise AND is to get just the rightmost 16 bits (non-flag integer)
		end
	end
end

return
{
	load = load,
	draw = draw,
}