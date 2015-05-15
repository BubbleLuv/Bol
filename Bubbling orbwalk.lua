local ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, myHero.range, DAMAGE_PHYSICAL, false)
local mm = minionManager(MINION_ENEMY, myHero.range, myHero, MINION_SORT_HEALTH_ASC)
local lastAttack, lastWindUpTime, lastAttackCD = 0, 0, 0

function OnLoad()
	Config = scriptConfig("Bubbling Orbwalk", "orbwalk")
		Config:addParam("combo", "Orbwalk Key", SCRIPT_PARAM_ONKEYDOWN, false, string.byte(" "))
		Config:addParam("lasthit", "Last Hit", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("X"))
		Config:addParam("laneclear", "Lane Clear", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("V"))
		Config:addParam("drawaa", "Draw AA-Range", SCRIPT_PARAM_ONOFF, false)
end

function OnTick()
	range = myHero.range + myHero.boundingRadius - 3
	ts.range = range
	ts:update()
	mm:update()
	orbwalk()
	lasthit()
	laneclear()
end

function orbwalk()
	if not Config.combo then return end
	if ts.target ~=	nil then		
		if CanShoot() then
			myHero:Attack(ts.target)
		elseif CanMove() then
			moveToCursor()
		end
	else		
		moveToCursor() 
	end
end

-- WORST LAST HIT EVER
function lasthit()
	if Config.lasthit then
		for i, minion in pairs(mm.objects) do
			if ValidTarget(mm.objects[i]) then
				if mm.objects[i].health < myHero.damage then
					myHero:Attack(mm.objects[i])
				elseif CanMove() then
					moveToCursor()
				end
			else
				moveToCursor()
			end
		end
	end
end

function laneclear()
	if Config.laneclear then
		for i, minion in pairs(mm.objects) do
			if ValidTarget(mm.objects[i]) then
				if CanShoot() then
					myHero:Attack(mm.objects[i])
				elseif CanMove() then
					moveToCursor()
				end
			else		
				moveToCursor() 
			end
		end
	end
end

function CanMove()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastWindUpTime + 20)
end 
 
function CanShoot()
	return (GetTickCount() + GetLatency()/2 > lastAttack + lastAttackCD)
end 
 
function moveToCursor()
	if GetDistance(mousePos) > 1 then
		local moveToPos = myHero + (Vector(mousePos) - myHero):normalized()* (300 + GetLatency())
		myHero:MoveTo(moveToPos.x, moveToPos.z)
	end
end

function OnProcessSpell(unit, spell)
	if unit == myHero then
		if spell.name:lower():find("attack") then
			lastAttack = GetTickCount() - GetLatency()/2
			lastWindUpTime = spell.windUpTime*1000
			lastAttackCD = spell.animationTime*1000
		end 
	end
	
	if unit.isMe and spell.name:lower():find("attack") and Config.combo then
		if spell.target.type == myHero.type then
		DelayAction(function() CastSpell(_Q, mousePos.x, mousePos.z) end, spell.windUpTime - GetLatency() / 2000)
		end
	end
end

function OnDraw()
    if not myHero.dead then
		if Config.drawaa then DrawCircle(myHero.x, myHero.y, myHero.z, myHero.range, 0x19A712) end
    end
end
