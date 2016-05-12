function maptotilecoords(x,y)
	local mousex,mousey = controls.mousetomapcoords(x,y)
	local mapx,mapy = math.floor(mousex/TileW), math.floor(mousey/TileH)
	return mapx,mapy
end

return
{
	maptotilecoords = maptotilecoords,
}