#include Automatic.lua

function RTSDrawMenu()
    local stats = {
        integrity = AutoKeyDefaultFloat('level.rts.stats.integrity', 0),
        money = AutoRound(AutoKeyDefaultFloat('level.rts.stats.money', 0), 1),
        wave = AutoKeyDefaultInt('level.rts.stats.wave', 0),
        waveCooldown = AutoRound(AutoKeyDefaultFloat('level.rts.stats.waveCooldown', 0), 0.1),
        fuel = AutoKeyDefaultFloat('level.rts.stats.fuel', 0)
    }

    -- AutoSecondaryColor = {0, 0, 0, 0.25}
    AutoFont = 'font/Teko/Teko-Regular.ttf'
    
    -- Top Left Stats
    UiPush()
        UiTranslate(AutoPad.heavy, AutoPad.heavy)

        AutoContainer(320, 120)
        AutoSpreadDown(AutoPad.thin)
            AutoText("NEXUS INTEGRITY : ", 42)-- .. stats.integrity, 42)
            UiPush()
                local minIntegrity = 40
                local ratio = (stats.integrity - minIntegrity) / (100 - minIntegrity)
                ratio = math.max(0, ratio)
                UiColor(1 - ratio, ratio, 0.2, 1)
                UiTranslate(170, -42)
                UiRect(ratio * 130, 30)
            UiPop()
            AutoText("FUEL : ", 42)
            UiPush()
                local ratio = stats.fuel
                ratio = math.max(0, ratio)
                UiColor(1, 1, 1, 1)
                UiTranslate(170, -42)
                UiRect(ratio * 130, 30)
            UiPop()
            AutoText("MONEY : " .. stats.money, 42)
        local spread = AutoSpreadEnd()
    UiPop()

    -- Soldier Display
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
                        local img = "MOD/img/"
                        if i == 1 then
                            img = img .. "infantry"
                        elseif i == 2 then
                            img = img .. "heavy"
                        elseif i == 3 then
                            img = img .. "sniper"
                        elseif i == 4 then
                            img = img .. "captain"
                        elseif i == 5 then
                            img = img .. "doc"
                        elseif i == 6 then
                            img = img .. "tank"
                        end
                        img = img .. "_preview.png"
                        AutoImage(img, AutoPad.heavy, AutoPad.heavy)
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
        local extra = stats.wave == 0 and 0 or AutoLogistic(stats.wave, 2, -0.25, 10)
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