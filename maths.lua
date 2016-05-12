--BRITISH STYLE motherfuckers

function clamp(n, mi, ma)
	if n<mi then n=mi
	elseif n>ma then n=ma end
	return n
end

return
{
	clamp = clamp,
}