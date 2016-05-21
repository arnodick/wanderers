function update(g)
	if g.reload > 0 then
		g.reload = g.reload - 1*Slowdown.amount
		if g.reload <= 0 then
			g.amount = g.size
			g.reload = 0
		end
	end
end

return
{
	update = update,
}