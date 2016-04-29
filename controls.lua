function mousetomapcoords(x,y)
	return math.floor(x/Scale), math.floor(y/Scale)
end

return
{
	mousetomapcoords = mousetomapcoords,
}