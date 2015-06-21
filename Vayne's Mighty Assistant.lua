--[[
                 _.--""--._
                /  _    _  \
             _  ( (_\  /_) )  _
            { \._\   /\   /_./ }
            /_"=-.}______{.-="_\
             _  _.=("""")=._  _
            (_'"_.-"`~~`"-._"'_)
             {_"            "_}

         Vayne's Mighty Assistant
                    by Manciuszz.

         » Auto-Condemn = Automatically condemns enemy into walls, structures(inhibitors, towers, nexus).
            • Prediction[VIP ONLY]/No Prediction mode
            • Takes into account enemy hitboxes.
            • Doesn't interrupt recalling.

         » Auto-Condemn on incoming gapclosers!

         » Manual Condemn-Assistant = Draws a circle of predicted position after condemn.
            • Draw Arrow/Simple circle

         » Disable Auto-Condemn on certain champions in-game.
]]

if myHero.charName ~= "Vayne" then return end
require 'ProSeriesLib'


local VayneAssistant

local enemyTable = GetEnemyHeroes()

local informationTable = {}
local spellExpired = true



local eRange, eSpeed, eDelay, eRadius = 1000, 2200, 0.25, nil
local VP = VPrediction()

local AllClassMenu = 16

-- Code -------------------------------------------

function OnLoad()
    VayneAssistant = scriptConfig("Vayne's Mighty Assistant", "VayneAssistant")

    VayneAssistant:addSubMenu("Features & Settings", "settingsSubMenu")
    VayneAssistant:addSubMenu("Disable Auto-Condemn on", "condemnSubMenu")

    VayneAssistant:addParam("autoCondemn", "Auto-Condemn Toggle:", SCRIPT_PARAM_ONKEYTOGGLE, false, GetKey("W"))
    VayneAssistant:addParam("switchKey", "Switch key mode:", SCRIPT_PARAM_ONOFF, false)

    VayneAssistant.settingsSubMenu:addParam("PushAwayGapclosers", "Push Gapclosers Away", SCRIPT_PARAM_ONOFF, true)
    VayneAssistant.settingsSubMenu:addParam("CondemnAssistant", "Condemn Visual Assistant:", SCRIPT_PARAM_ONOFF, true)
    VayneAssistant.settingsSubMenu:addParam("pushDistance", "Push Distance", SCRIPT_PARAM_SLICE, 300, 0, 450, 0) -- Reducing this value means that the enemy has to be closer to the wall, so you could cast condemn.
    VayneAssistant.settingsSubMenu:addParam("eyeCandy", "After-Condemn Circle:", SCRIPT_PARAM_ONOFF, true)
        VayneAssistant.settingsSubMenu:addParam("shootingMode", "Prediction/No prediction:", SCRIPT_PARAM_ONOFF, true)


    VayneAssistant:permaShow("autoCondemn")
    -- Override in case it's stuck.
--    VayneAssistant.pushDistance = 300
    VayneAssistant.autoCondemn = true
    VayneAssistant.switchKey = false

    for i, enemy in ipairs(enemyTable) do
        VayneAssistant.condemnSubMenu:addParam("disableCondemn"..i, " >> "..enemy.charName, SCRIPT_PARAM_ONOFF, false)
        VayneAssistant["disableCondemn"..i] = false -- Override
    end
    PrintChat(" >> Vayne's Mighty Assistant!")
end

function OnDraw()
    if myHero.dead then return end

    if IsKeyDown(AllClassMenu) then
        VayneAssistant._param[1].pType = VayneAssistant.switchKey and 2 or 3
        VayneAssistant._param[1].text  = VayneAssistant.switchKey and "Auto-Condemn OnHold:" or "Auto-Condemn Toggle:"
        if VayneAssistant.switchKey and VayneAssistant.autoCondemn then
            VayneAssistant.autoCondemn = false
        end

        VayneAssistant.settingsSubMenu._param[5].text  = VayneAssistant.settingsSubMenu.shootingMode  and "Currently: VP" or "Currently: No prediction"

    end

    if myHero:CanUseSpell(_E) == READY then
        if VayneAssistant.settingsSubMenu.PushAwayGapclosers then
            if not spellExpired and (GetTickCount() - informationTable.spellCastedTick) <= (informationTable.spellRange/informationTable.spellSpeed)*1000 then
                local spellDirection     = (informationTable.spellEndPos - informationTable.spellStartPos):normalized()
                local spellStartPosition = informationTable.spellStartPos + spellDirection
                local spellEndPosition   = informationTable.spellStartPos + spellDirection * informationTable.spellRange
                local heroPosition = Point(myHero.x, myHero.z)

                local lineSegment = LineSegment(Point(spellStartPosition.x, spellStartPosition.y), Point(spellEndPosition.x, spellEndPosition.y))
                --lineSegment:draw(ARGB(255, 0, 255, 0), 70)

                if lineSegment:distance(heroPosition) <= (not informationTable.spellIsAnExpetion and 65 or 200) then
                    CastSpell(_E, informationTable.spellSource)
                end
            else
                spellExpired = true
                informationTable = {}
            end
        end

        if VayneAssistant.autoCondemn then
            for i, enemyHero in ipairs(enemyTable) do
                if not VayneAssistant.condemnSubMenu["disableCondemn"..i] then 
                    if enemyHero ~= nil and enemyHero.valid and not enemyHero.dead and enemyHero.visible and GetDistance(enemyHero) <= 715 and GetDistance(enemyHero) > 0 then
                        local enemyPosition = VayneAssistant.settingsSubMenu.shootingMode  and VP:GetPredictedPos(enemyHero, eDelay, eSpeed) or enemyHero
                        local PushPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*VayneAssistant.settingsSubMenu.pushDistance

                        if enemyHero.x > 0 and enemyHero.z > 0 then
                            local checks = math.ceil((VayneAssistant.settingsSubMenu.pushDistance)/65)
                            local checkDistance = (VayneAssistant.settingsSubMenu.pushDistance)/checks
                            local InsideTheWall = false
                            for k=1, checks, 1 do
                                local checksPos = enemyPosition + (Vector(enemyPosition) - myHero):normalized()*(checkDistance*k)
                                local WallContainsPosition = IsWall(D3DXVECTOR3(checksPos.x, checksPos.y, checksPos.z))
                                if WallContainsPosition then
                                    InsideTheWall = true
                                    break
                                end
                            end

                            if InsideTheWall then CastSpell(_E, enemyHero) end

                            if VayneAssistant.settingsSubMenu.eyeCandy and PushPos.x > 0 and PushPos.z > 0 then
                                DrawCircle(PushPos.x, PushPos.y, PushPos.z, 65, ARGB(255, 0, 255, 0))
                            end


                        end
                    end
                end
            end
        end
    end
end

function OnProcessSpell(unit, spell)
    if not VayneAssistant.settingsSubMenu.PushAwayGapclosers then return end

    local jarvanAddition = unit.charName == "JarvanIV" and unit:CanUseSpell(_Q) ~= READY and _R or _Q -- Did not want to break the table below.
    local isAGapcloserUnit = {
--        ['Ahri']        = {true, spell = _R, range = 450,   projSpeed = 2200},
        ['Aatrox']      = {true, spell = _Q,                  range = 1000,  projSpeed = 1200, },
        ['Akali']       = {true, spell = _R,                  range = 800,   projSpeed = 2200, }, -- Targeted ability
        ['Alistar']     = {true, spell = _W,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
        ['Diana']       = {true, spell = _R,                  range = 825,   projSpeed = 2000, }, -- Targeted ability
        ['Gragas']      = {true, spell = _E,                  range = 600,   projSpeed = 2000, },
        ['Graves']      = {true, spell = _E,                  range = 425,   projSpeed = 2000, exeption = true },
        ['Hecarim']     = {true, spell = _R,                  range = 1000,  projSpeed = 1200, },
        ['Irelia']      = {true, spell = _Q,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
        ['JarvanIV']    = {true, spell = jarvanAddition,      range = 770,   projSpeed = 2000, }, -- Skillshot/Targeted ability
        ['Jax']         = {true, spell = _Q,                  range = 700,   projSpeed = 2000, }, -- Targeted ability
        ['Jayce']       = {true, spell = 'JayceToTheSkies',   range = 600,   projSpeed = 2000, }, -- Targeted ability
        ['Khazix']      = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
        ['Leblanc']     = {true, spell = _W,                  range = 600,   projSpeed = 2000, },
        ['LeeSin']      = {true, spell = 'blindmonkqtwo',     range = 1300,  projSpeed = 1800, },
        ['Leona']       = {true, spell = _E,                  range = 900,   projSpeed = 2000, },
        ['Malphite']    = {true, spell = _R,                  range = 1000,  projSpeed = 1500 + unit.ms},
        ['Maokai']      = {true, spell = _Q,                  range = 600,   projSpeed = 1200, }, -- Targeted ability
        ['MonkeyKing']  = {true, spell = _E,                  range = 650,   projSpeed = 2200, }, -- Targeted ability
        ['Pantheon']    = {true, spell = _W,                  range = 600,   projSpeed = 2000, }, -- Targeted ability
        ['Poppy']       = {true, spell = _E,                  range = 525,   projSpeed = 2000, }, -- Targeted ability
        --['Quinn']       = {true, spell = _E,                  range = 725,   projSpeed = 2000, }, -- Targeted ability
        ['Renekton']    = {true, spell = _E,                  range = 450,   projSpeed = 2000, },
        ['Sejuani']     = {true, spell = _Q,                  range = 650,   projSpeed = 2000, },
        ['Shen']        = {true, spell = _E,                  range = 575,   projSpeed = 2000, },
        ['Tristana']    = {true, spell = _W,                  range = 900,   projSpeed = 2000, },
        ['Tryndamere']  = {true, spell = 'Slash',             range = 650,   projSpeed = 1450, },
        ['XinZhao']     = {true, spell = _E,                  range = 650,   projSpeed = 2000, }, -- Targeted ability
    }
    if unit.type == 'obj_AI_Hero' and unit.team == TEAM_ENEMY and isAGapcloserUnit[unit.charName] and GetDistance(unit) < 2000 and spell ~= nil then
        if spell.name == (type(isAGapcloserUnit[unit.charName].spell) == 'number' and unit:GetSpellData(isAGapcloserUnit[unit.charName].spell).name or isAGapcloserUnit[unit.charName].spell) then
            if spell.target ~= nil and spell.target.name == myHero.name or isAGapcloserUnit[unit.charName].spell == 'blindmonkqtwo' then
--                print('Gapcloser: ',unit.charName, ' Target: ', (spell.target ~= nil and spell.target.name or 'NONE'), " ", spell.name, " ", spell.projectileID)
                CastSpell(_E, unit)
            else
                spellExpired = false
                informationTable = {
                    spellSource = unit,
                    spellCastedTick = GetTickCount(),
                    spellStartPos = Point(spell.startPos.x, spell.startPos.z),
                    spellEndPos = Point(spell.endPos.x, spell.endPos.z),
                    spellRange = isAGapcloserUnit[unit.charName].range,
                    spellSpeed = isAGapcloserUnit[unit.charName].projSpeed,
                    spellIsAnExpetion = isAGapcloserUnit[unit.charName].exeption or false,
                }
            end
        end
    end

end
