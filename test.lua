function maptotilecoords(x,y)
	return math.floor(x/TileW), math.floor(y/TileH)
end

return
{
	maptotilecoords = maptotilecoords,
}