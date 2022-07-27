function tick()
	if InputPressed("x") then
		SetInt("level.dispatch", 1)
	end
	if InputPressed("y") then
		SetInt("level.tankdispatch", 1)
	end
end