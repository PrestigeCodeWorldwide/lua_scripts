function range(i, to, inc)
	if i == nil then
		return nil
	end

	if to == nil then
		to = i
		i = to == 0 and 0 or (to > 0 and 1 or -1)
	end

	inc = inc or (i < to and 1 or -1)

	i = i - inc
	return function()
		if i == to then
			return nil
		end
		i = i + inc
		return i
	end
end

return range
