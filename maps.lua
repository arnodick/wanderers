local bytesize=4

function load(m)
	local map = {}
	for row in love.filesystem.lines(m) do
		table.insert(map, textfile.loadbytes(row))
	end
	return map
end

function loadbytes(l)
	local ar={}
	for a=1, #l, bytesize*2 do
		table.insert( ar, tonumber(string.sub(l, a, a+bytesize*2-1),16) )
	end
	return ar
end

function save(m,n)
	local str=""
	for b=1,#m do
		for a=1,#m[b] do
			--str=str..string.format("%08x",m[b][a])
			str=str..string.format("%0"..tostring(bytesize*2).."x",m[b][a])
		end
		str=str.."\n"
	end
	love.filesystem.write(n, str)
end

return
{
	load = load,
	loadbytes = loadbytes,
	save = save,
}