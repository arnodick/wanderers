function load(m)
	local map = textfile.load(m)
	for a=1, #map do
		for b=1, #map[a] do
			if bit.rshift( bit.band(map[a][b] - 1, 0xffff0000), 16 ) == 1 then
				makewall((b-1)*TileW, (a-1)*TileH, TileW, TileH)
			end
		end
	end
	return map
end

function draw(m)
	for b=1,#m do
		for a=1,#m[b] do
			love.graphics.draw( Spritesheet, Quads[ bit.band(m[b][a] - 1, 0x0000ffff) ],(a-1)*TileW,(b-1)*TileH) --bitwise and is to get just the rightmost 16 bits (non-flag integer)
		end
	end
end

return
{
	load = load,
	draw = draw,
}