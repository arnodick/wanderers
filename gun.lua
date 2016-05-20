function update(g)
	if g.reload > 0 then
		g.reload = g.reload - 1
		if g.reload == 0 then
			g.amount = g.size
		end
	end
end

return
{
	update = update,
}