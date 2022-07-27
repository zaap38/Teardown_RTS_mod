function init()

	stockpiles = FindTriggers("ammoStockpile",true)

	rectsprite = LoadSprite("LEVEL/scripts/gfx/rect.png")
end

function tick(dt)   
	
	-- grab the pc object and the trigger zone --


	-- draw the rect sprite --
	
	triggerWidth = 9
	triggerDepth = 5
	
	spriteColorR = 2
	spriteColorB = 2
	spriteColorG = 2
	spriteColorAlpha = .1
	
	for _,stockpile in pairs(stockpiles) do
		DrawSprite(rectsprite, GetTriggerTransform(stockpile), triggerWidth, triggerDepth, spriteColorR, spriteColorG, spriteColorB, spriteColorAlpha, true, false)
	end

	-- DebugPrint("1".." "..getDistanceToPlayer())
end

function getDistanceToPlayer()
	local playerPos = GetPlayerPos()
	return VecLength(VecSub(playerPos,  GetTriggerTransform(stockpiles[1]).pos))
end