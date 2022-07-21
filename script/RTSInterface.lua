#include Automatic.lua

function RTSDrawMenu()
    local stats = {
        integrity = AutoRound(AutoKeyDefaultFloat('level.rts.stats.integrity', 0), 1),
        money = AutoRound(AutoKeyDefaultFloat('level.rts.stats.money', 0), 1),
        wave = AutoKeyDefaultInt('level.rts.stats.wave', 0),
        waveCooldown = AutoRound(AutoKeyDefaultFloat('level.rts.stats.waveCooldown', 0), 0.1),
    }

    -- AutoSecondaryColor = {0, 0, 0, 0.25}
    AutoFont = 'font/Teko/Teko-Regular.ttf'
    
    -- Top Left Stats
    UiPush()
        UiTranslate(AutoPad.heavy, AutoPad.heavy)

        AutoContainer(320, 100)
        AutoSpreadDown(AutoPad.thin)
            AutoText("NEXUS INTEGRITY : " .. stats.integrity, 42)
            AutoText("MONEY : " .. stats.money, 42)
        local spread = AutoSpreadEnd()
    UiPop()

    -- Soilder Display
    UiPush()
        UiTranslate(AutoPad.heavy, spread.comb.h + AutoPad.thick * 3 + AutoPad.heavy)

        local toshow = {0, 0, 0, 0, 0, 0}
        for i, v in ipairs(soldiers) do
            if v.team == ALLY_TEAM and nexus.alive then
                toshow[v.type] = toshow[v.type] and toshow[v.type] + 1 or 1
            end
        end
        
        for i = 1, AutoTableCount(toshow) do
            local v = toshow[i]
            if v > 0 then
                AutoSpreadRight()
                    UiPush()
                        AutoImage(nil, AutoPad.heavy, AutoPad.heavy)
                        UiAlign('center')
                        AutoText(toshow[i], 48)
                    UiPop()
                local spread = AutoSpreadEnd()
                
                UiTranslate(0, AutoPad.heavy + AutoPad.thick)
            end
        end
    UiPop()

    -- Wave Counter
    UiPush()
        UiTranslate(UiCenter(), AutoPad.heavy)
        UiAlign('center top')

        -- at around wave 20 it will start shaking a bit, caps out around 50
        -- Can be removed if you want, I always like adding juice
        local extra = stats.wave == 0 and 0 or AutoLogistic(stats.wave, 2, -0.25, 30)
        local rnd = AutoRndVec(extra)
        UiTranslate(rnd[1], rnd[2])

        UiTranslate(2, 2)
        AutoSpreadDown(AutoPad.thin)
            local org = AutoPrimaryColor
            AutoPrimaryColor = {0, 0, 0, 1}

            AutoText("WAVE "..stats.wave, 128)
            AutoText(stats.waveCooldown, 46)
        AutoSpreadEnd()
            
        UiTranslate(-2, -2)
        AutoSpreadDown(AutoPad.thin)
            AutoPrimaryColor = org
            AutoText("WAVE " .. stats.wave, 128)
            AutoText(stats.waveCooldown, 46)
        AutoSpreadEnd()
    UiPop()
end