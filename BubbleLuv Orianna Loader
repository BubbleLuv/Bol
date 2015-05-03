if myHero.charName ~= "Orianna" then return end
require "vPrediction"
require "HPrediction"
require "DivinePred"
require "Pewdiction"
require "SxOrbWalk"

local Author = "BubbleLuv"
local version = 1.4
local BallSpeedQ = 1200
local BallSpeedE = 1700 
local Dayupdate = 3.052015
local UPDATE_NAME = "BubbleLuv Orianna Loader"
local UPDATE_HOST = "raw.github.com"
local UPDATE_PATH = "/BubbleLuv/Bol/master/BubOrianna.version" .. "?rand=" .. math.random(1, 10000)
local UPDATE_PATH2 = "/BubbleLuv/Bol/master/BubbleLuv Orianna Loader.lua"
local UPDATE_FILE_PATH = SCRIPT_PATH..GetCurrentEnv().FILE_NAME
local UPDATE_URL = "http://"..UPDATE_HOST..UPDATE_PATH2
local SpellList = false
_G.UseUpdater = true
function AutoupdaterMsg(msg) print("<b><font color=\"#6699FF\">"..UPDATE_NAME..":</font></b> <font color=\"#FFFFFF\">"..msg..".</font>") end
	if _G.UseUpdater then
  		local ServerData = GetWebResult(UPDATE_HOST, UPDATE_PATH)
  		if ServerData then
    		local ServerVersion = string.match(ServerData, "local version = \"%d+.%d+\"")
    		ServerVersion = string.match(ServerVersion and ServerVersion or "", "%d+.%d+")
    		if ServerVersion then
      			ServerVersion = tonumber(ServerVersion)
      			if tonumber(version) < ServerVersion then
        			AutoupdaterMsg("Đã có phiên bản mới"..ServerVersion)
        			AutoupdaterMsg("Đang tải script, thư viện mới, xin chờ...")
        			DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg("Cập nhật phiên bản mới thành công phiên bản. ("..version.." => "..ServerVersion.."), hãy bấm 2 lần F9 để load script.") end) 
        			SpellList = true		
      			else
        			AutoupdaterMsg("Bạn đang sử dụng phiên bản mới nhất ("..ServerVersion..")")
      			end
    		end
		else
    	AutoupdaterMsg("Cập nhật phiên bản mới thất bại")
		SpellList = true
 	end
end
local InitiatorsList = 
	{
	  ["Vi"] = "ViQ",--R
	  ["Vi"] = "ViR",--R
	  ["Malphite"] = "Landslide",--R UFSlash
	  ["Nocturne"] = "NocturneParanoia",--R
	  ["Zac"] = "ZacE",--E
	  ["MonkeyKing"] = "MonkeyKingNimbus",--R
	  ["MonkeyKing"] = "MonkeyKingSpinToWin",--R
	  ["MonkeyKing"] = "SummonerFlash",--Flash
	  ["Shyvana"] = "ShyvanaTransformCast",--R
	  ["Thresh"] = "threshqleap",--Q2
	  ["Aatrox"] = "AatroxQ",--Q
	  ["Renekton"] = "RenektonSliceAndDice",--E
	  ["Kennen"] = "KennenLightningRush",--E
	  ["Kennen"] = "SummonerFlash",--Flash
	  ["Olaf"] = "OlafRagnarok",--R
	  ["Udyr"] = "UdyrBearStance",--E
	  ["Volibear"] = "VolibearQ",--Q
	  ["Talon"] = "TalonCutthroat",--e?
	  ["JarvanIV"] = "JarvanIVDragonStrike",--Q
	  ["Warwick"] = "InfiniteDuress",--R
	  ["Jax"] = "JaxLeapStrike",--Q
	  ["Yasuo"] = "YasuoRKnockUpComboW",--Q
	  ["Diana"] = "DianaTeleport",
	  ["LeeSin"] = "BlindMonkQTwo",
	  ["Shen"] = "ShenShadowDash",
	  ["Alistar"] = "Headbutt",
	  ["Amumu"] = "BandageToss",
	  ["Urgot"] = "UrgotSwap2",
	  ["Rengar"] = "RengarR",
	}

local InterruptList = 
	{
	  ["Katarina"] = "KatarinaR",
	  ["Malzahar"] = "AlZaharNetherGrasp",
	  ["Warwick"] = "InfiniteDuress",
	  ["Velkoz"] = "VelkozR"
	}
	
--[[Spell data]]
local Qradius = 80
local Wradius = 245
local Eradius = 80
local Rradius = 380

local Qrange = 825
local Erange = 1095

local Qdelay = 0
local Wdelay = 0.25
local Edelay = 0.25
local Rdelay = 0.6

local BallSpeed = 1200--Q
local BallSpeedE = 1700--E

_IGNITE = nil
_AA = 142857

--[[Spell damage]]
local Qdamage = {60, 90, 120, 150, 180}
local Qscaling = 0.5
local Wdamage = {70, 115, 160, 205, 250}
local Wscaling = 0.7
local Edamage = {60, 90, 120, 150, 180}
local Escaling = 0.3
local Rdamage = {150, 225, 300}
local Rscaling = 0.7
local AAdamage = {10, 10, 10, 18, 18, 18, 26, 26, 26, 34, 34, 34, 42, 42, 42, 50, 50, 50}
local AAscaling = 0.15

local MainCombo = {_AA, _AA, _Q, _W, _R, _Q, _IGNITE}
local Far = 1.4

--[[Ball]]
local BallPos = myHero or Vector(0,0,0)
local BallMoving = false

--[[CDS]]
local QREADY = true
local WREADY = true
local EREADY = true
local RREADY = true
local IGNITEREADY = true

--[[VPrediction]]
local VP

local Menu = nil

local SelectedTarget = nil

local DamageToHeros = {}
local lastrefresh = 0

local ComboMode
local _ST, _TF  = 1,2

local LastChampionSpell = {}

--[[Ball location]]
function OnCreateObj(obj)
	--[[Casting Q creates this object when ball lands]]
        if obj.name:lower():find("yomu_ring_green") then
                BallPos = obj
                BallMoving = false
        end
        
        --[[When ball goes out of range it returns to Orianna and creates this object]]
        if (obj.name:lower():find("orianna_ball_flash_reverse")) then
            BallPos = myHero
			BallMoving = false
        end
end

function OnProcessSpell(unit, spell)
	if unit.isMe and spell.name:lower():find("orianaizunacommand") then--Q
		BallMoving = true
		DelayAction(function(p) BallPos = Vector(p) end, GetDistance(spell.endPos, BallPos) / BallSpeed - GetLatency()/1000 - 0.35, {Vector(spell.endPos)})
	end

	if unit.isMe and spell.name:lower():find("orianaredactcommand") then--E
		BallMoving = true
		BallPos = spell.target
	end

	if unit.type == "obj_AI_Hero" then
		LastChampionSpell[unit.networkID] = {name = spell.name, time=os.clock()}
	end
end

AddApplyBuffCallback(function(unit, source, buff)
	--[[When the ball reaches an ally]]
	if unit.team == myHero.team and buff.name:lower():find("orianaghostself") then
		BallMoving = false
		BallPos = unit
	end
end)
--[[End of ball location]]

function OnLoad()
	Menu = scriptConfig("Orianna", "Orianna")
	--[[Combo]]

	VP = VPrediction()
	Menu:addSubMenu("Combo", "Combo")
		Menu.Combo:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF , true)
		Menu.Combo:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseR", "Use R", SCRIPT_PARAM_ONOFF, true)
		Menu.Combo:addParam("UseRN", "Use R at least in", SCRIPT_PARAM_LIST, 1, { "1 target", "2 targets", "3 targets", "4 targets" , "5 targets"})
		local Disable = nil
	  Menu.Combo:addParam("Enabled", "Normal combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)
	Menu:addSubMenu("Misc", "Misc")
		Menu.Misc:addParam("UseW", "Auto-W if it will hit", SCRIPT_PARAM_LIST, 1, { "No", ">0 targets", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
		Menu.Misc:addParam("UseR", "Auto-ultimate if it will hit", SCRIPT_PARAM_LIST, 1, { "No", ">0 targets", ">1 targets", ">2 targets", ">3 targets", ">4 targets" })
		Menu.Misc:addParam("EQ", "Use E + Q if tEQ < %x * tQ", SCRIPT_PARAM_SLICE, 100, 0, 200)
		Menu.Misc:addSubMenu("Auto-E on initiators", "AutoEInitiate")
		local added = false
		for champion, spell in pairs(InitiatorsList) do
			for i, ally in ipairs(GetAllyHeroes()) do
				if ally.charName == champion then
					added = true
					Menu.Misc.AutoEInitiate:addParam(champion..spell, champion.." ("..spell..")", SCRIPT_PARAM_ONOFF, true)
				end
			end
		end
	
		if not added then
			Menu.Misc.AutoEInitiate:addParam("info", "Info", SCRIPT_PARAM_INFO, "Not supported initiators found")
		else
			Menu.Misc.AutoEInitiate:addParam("Active", "Active", SCRIPT_PARAM_ONOFF, true)
		end
		Menu.Misc:addParam("Interrupt", "Auto interrupt important spells", SCRIPT_PARAM_ONOFF, true)
		Menu.Misc:addParam("BlockR", "Block R if it is not going to hit", SCRIPT_PARAM_ONOFF, true)

	--[[Harassing]]
	Menu:addSubMenu("Harass", "Harass")
		Menu.Harass:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF , true)
		Menu.Harass:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, false)
		Menu.Harass:addParam("ManaCheck", "Don't harass if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100)
		
	--[[Farming]]
	Menu:addSubMenu("Farm", "Farm")
		Menu.Farm:addParam("UseQ",  "Use Q", SCRIPT_PARAM_LIST, 4, { "No", "Freezing", "LaneClear", "Both" })
		Menu.Farm:addParam("UseW",  "Use W", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
		Menu.Farm:addParam("UseE",  "Use E", SCRIPT_PARAM_LIST, 3, { "No", "Freezing", "LaneClear", "Both" })
		Menu.Farm:addParam("ManaCheck", "Don't laneclear if mana < %", SCRIPT_PARAM_SLICE, 0, 0, 100)
		Menu:addParam("Freeze", "Farm Freezing", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("C"))
		Menu:addParam("LaneClear", "Farm LaneClear", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("X"))
	
	--[[Jungle farming]]
	Menu:addSubMenu("JungleFarm", "JungleFarm")
		Menu.JungleFarm:addParam("UseQ", "Use Q", SCRIPT_PARAM_ONOFF, true)
		Menu.JungleFarm:addParam("UseW", "Use W", SCRIPT_PARAM_ONOFF, true)
		Menu.JungleFarm:addParam("UseE", "Use E", SCRIPT_PARAM_ONOFF, true)
		Menu:addParam("Enabled", "Farm jungle!", SCRIPT_PARAM_ONKEYDOWN, false,   string.byte("X"))
	
	--[[Drawing]]
	Menu:addSubMenu("Drawing", "Drawing")
		Menu.Drawing:addParam("Qrange", "Draw Q range", SCRIPT_PARAM_ONOFF, true)
		Menu.Drawing:addParam("Wrange", "Draw W radius", SCRIPT_PARAM_ONOFF, false)
		Menu.Drawing:addParam("Rrange", "Draw R radius", SCRIPT_PARAM_ONOFF, false)
		Menu.Drawing:addParam("DrawDamage", "Draw damage after combo in healthbars", SCRIPT_PARAM_ONOFF, true)
		Menu.Drawing:addParam("DrawBall", "Draw ball position", SCRIPT_PARAM_ONOFF, true)
	Menu:addParam("Enabled", "Harass!", SCRIPT_PARAM_ONKEYDOWN, false, string.byte("C"))
		Menu:addParam("Enabled2", "Harass (TOGGLE)!", SCRIPT_PARAM_ONKEYTOGGLE, false, string.byte("L"))
	
	Menu:addParam("Enabled", "Active combo", SCRIPT_PARAM_ONKEYDOWN, false, 32)	
		Menu:addParam("pred", "Cast Skill ", SCRIPT_PARAM_LIST, 1, {"DivinePred", "VPrediction", "HPrediction", "Pewdiction"})
		Menu:addParam("pred", "Use R to Interrupt", SCRIPT_PARAM_LIST, 1, {"On", "Off"})
		Menu:addParam("BallSpeedQ", "BallSpeedQ", SCRIPT_PARAM_INFO, BallSpeedQ)
		Menu:addParam("BallSpeedE", "BallSpeedE", SCRIPT_PARAM_INFO, BallSpeedE)
	Menu:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
	Menu:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
		Menu:addParam("Dayupdate", "Dayupdate", SCRIPT_PARAM_INFO, Dayupdate)
	Menu:addSubMenu("Orbwalker", "Orbwalker")
	Sx = SxOrbWalk()
  Sx:LoadToMenu(Menu.Orbwalker)
	 
	EnemyMinions = minionManager(MINION_ENEMY, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
	JungleMinions = minionManager(MINION_JUNGLE, Qrange, myHero, MINION_SORT_MAXHEALTH_DEC)
	
 	if myHero:GetSpellData(SUMMONER_1).name:find("SummonerDot") then
		_IGNITE = SUMMONER_1
	elseif myHero:GetSpellData(SUMMONER_2).name:find("SummonerDot") then
		_IGNITE = SUMMONER_2
	else
		_IGNITE = nil
	end
	if VP.version == nil or type(tonumber(VP.version)) ~= "number" or tonumber(VP.version) < 3 then
		
	end
	
end

function GetComboDamage(Combo, Unit)
	local totaldamage = 0
	for i, spell in ipairs(Combo) do
		totaldamage = totaldamage + GetDamage(spell, Unit)
	end
	return totaldamage
end

function GetDamage(Spell, Unit)
	local truedamage = 0
	if Spell == _Q and myHero:GetSpellData(_Q).level ~= 0 then
		truedamage = myHero:CalcMagicDamage(Unit, Qdamage[myHero:GetSpellData(_Q).level] + myHero.ap * Qscaling)
	elseif Spell == _W and myHero:GetSpellData(_W).level ~= 0 and WREADY then
		truedamage = myHero:CalcMagicDamage(Unit, Wdamage[myHero:GetSpellData(_W).level] + myHero.ap * Wscaling)
	elseif Spell == _E and myHero:GetSpellData(_E).level ~= 0 then
		truedamage = myHero:CalcMagicDamage(Unit, Edamage[myHero:GetSpellData(_E).level] + myHero.ap * Escaling)
	elseif Spell == _R and myHero:GetSpellData(_R).level ~= 0 and RREADY then
		truedamage = myHero:CalcMagicDamage(Unit, Rdamage[myHero:GetSpellData(_R).level] + myHero.ap * Rscaling)
	elseif Spell == _AA and myHero:GetSpellData(_AA).level ~= 0 then
		truedamage = myHero:CalcDamage(Unit, myHero.totalDamage) + myHero:CalcMagicDamage(Unit, AAdamage[myHero.level] + myHero.ap * AAscaling)
	elseif Spell == _IGNITE and _IGNITE and IGNITEREADY then
		truedamage = 50 + 20 * myHero.level
	end
	return truedamage
end

--[[Check the number of enemies hit by casting W]]
function CheckEnemiesHitByW()
	local enemieshit = {}
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local position = VP:GetPredictedPos(enemy, Wdelay)
		if ValidTarget(enemy) and GetDistanceSqr(position, BallPos) <= Wradius*Wradius and GetDistanceSqr(enemy, BallPos) <= Wradius*Wradius then
			table.insert(enemieshit, enemy)
		end
	end
	return #enemieshit, enemieshit
end

--[[Check the number of enemies hit by casting E]]
function CheckEnemiesHitByE(To)
	local enemieshit = {}
	local StartPoint = Vector(BallPos.x, 0, BallPos.z)
	local EndPoint = Vector(To.x, 0, To.z)
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local cp, hc, position = VP:GetLineCastPosition(enemy, Edelay, Eradius, math.huge, BallSpeedE, StartPoint)
		if position then
			local PointInLine, tmp, isOnSegment = VectorPointProjectionOnLineSegment(StartPoint, EndPoint, position)
			if ValidTarget(enemy) and isOnSegment and GetDistanceSqr(PointInLine, position) <= math.pow(Eradius + VP:GetHitBox(enemy), 2) and GetDistanceSqr(PointInLine, enemy) < math.pow((Eradius) * 2 + 30, 2) then
				table.insert(enemieshit, enemy)
			end
		end
	end
	return #enemieshit, enemieshit
end

--[[Check number of enemies hit by casting R]]
function CheckEnemiesHitByR()
	local enemieshit = {}
	for i, enemy in ipairs(GetEnemyHeroes()) do
		local position = VP:GetPredictedPos(enemy, Rdelay)
		if ValidTarget(enemy) and GetDistanceSqr(position, BallPos) <= Rradius*Rradius and GetDistanceSqr(enemy, BallPos) <= math.pow(1.25 * Rradius, 2)  then
			table.insert(enemieshit, enemy)
		end
	end
	return #enemieshit, enemieshit
end

function CastQ(target, fast)
	local Speed = BallSpeed * 1.5
	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, Qdelay, Qradius, math.huge, Speed, BallPos)
	local CastPoint = CastPosition

	if (HitChance < 2) then return end

	if GetDistanceSqr(myHero, Position) > math.pow(Qrange + Wradius + VP:GetHitBox(target), 2) then
		target2 = GetBestTarget(Qrange, target)
		if target2 then
			CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target2, Qdelay, Qradius, math.huge, Speed, BallPos)
			CastPoint = CastPosition
		else
			do return end
		end
	end

	if GetDistanceSqr(myHero, Position) > math.pow(Qrange + Wradius + VP:GetHitBox(target), 2) then
		do return end
	end

	if EREADY and Menu.Misc.EQ ~= 0 then
		local TravelTime = GetDistance(BallPos, CastPoint) / BallSpeed
		local MinTravelTime = GetDistance(myHero, CastPoint) / BallSpeed + GetDistance(myHero, BallPos) / BallSpeedE
		local Etarget = myHero

		for i, ally in ipairs(GetAllyHeroes()) do
			if ValidTarget(ally, Erange, false) then
				local t = GetDistance(ally, CastPoint) / BallSpeed + GetDistance(ally, BallPos) / BallSpeedE
				if t < MinTravelTime then
					MinTravelTime = t
					Etarget = ally
				end
			end
		end


		if MinTravelTime < (Menu.Misc.EQ / 100) * TravelTime and (not Etarget.isMe or GetDistanceSqr(BallPos, myHero) > 10000) and GetDistanceSqr(Etarget) < GetDistanceSqr(CastPoint) then
			CastE(Etarget)
			do return end
		end
	end
	if GetDistanceSqr(myHero, CastPoint) < Qrange * Qrange then
		CastSpell(_Q, CastPoint.x, CastPoint.z)
	else
		CastPoint = Vector(myHero) + Qrange * (Vector(CastPoint) - Vector(myHero)):normalized()
		CastSpell(_Q, CastPoint.x, CastPoint.z)
	end
end

function CastW()
	local hitcount, hit = CheckEnemiesHitByW()
	if hitcount >= 1 then
		CastSpellEx(_W)
	end
end

function CastE(target)
	if target then
		CastSpell(_E, target)
	end
end

function CastECH(target, n)
	local hitcount, hit = CheckEnemiesHitByE(target)
	if hitcount >= n then
		CastE(target)
	end
end

function CastR(target)
	local position = VP:GetPredictedPos(target, Rdelay)
	if GetDistanceSqr(position, BallPos) < Rradius*Rradius and GetDistanceSqr(target, BallPos) < Rradius*Rradius then
		CastSpellEx(_R)
	end
end

function GetNMinionsHit(Pos, radius)
	local count = 0
	for i, minion in pairs(EnemyMinions.objects) do
		if GetDistanceSqr(minion, Pos) < radius*radius then
			count = count + 1
		end
	end
	return count
end

function GetNMinionsHitE(Pos)
	local count = 0
	local StartPoint = Vector(Pos.x, 0, Pos.z)
	local EndPoint = Vector(myHero.x, 0, myHero.z)
	for i, minion in pairs(EnemyMinions.objects) do
		local position = Vector(minion.x, 0, minion.z)
		local PointInLine = VectorPointProjectionOnLineSegment(StartPoint, EndPoint, position)
		if GetDistanceSqr(PointInLine, position) < Eradius*Eradius then
			count = count + 1
		end
	end
	return count
end

function Farm(Mode)
	local UseQ
	local UseW
	local UseE
	
	EnemyMinions:update()
	if Mode == "Freeze" then
		UseQ =  Menu.Farm.UseQ == 2
		UseW =  Menu.Farm.UseW == 2 
		UseE =  Menu.Farm.UseE == 2 
	elseif Mode == "LaneClear" then
		UseQ =  Menu.Farm.UseQ == 3
		UseW =  Menu.Farm.UseW == 3 
		UseE =  Menu.Farm.UseE == 3 
	end
	
	UseQ =  Menu.Farm.UseQ == 4 or UseQ
	UseW =  Menu.Farm.UseW == 4  or UseW
	UseE =  Menu.Farm.UseE == 4 or UseE
	
	if UseQ and QREADY then
		if UseW then
			local MaxHit = 0
			local MaxPos = 0
			for i, minion in pairs(EnemyMinions.objects) do
				if GetDistanceSqr(minion) <= Qrange*Qrange then
					local MinionPos = VP:GetPredictedPos(minion, Qdelay, BallSpeed, BallPos)
					local Hit = GetNMinionsHit(minion, Wradius)
					if Hit >= MaxHit then
						MaxHit = Hit
						MaxPos = MinionPos
					end
				end
			end
			if MaxHit > 0 and MaxPos then
				CastSpell(_Q, MaxPos.x, MaxPos.z)
			end
		else
			for i, minion in pairs(EnemyMinions.objects) do
				if minion.health + 15 < GetDamage(_Q, minion) and GetDistanceSqr(myHero, minion) > 600 then
					local MinionPos = VP:GetPredictedPos(minion, Qdelay, BallSpeed, BallPos)
					CastSpell(_Q, MinionPos.x, MinionPos.z)
					break
				end
			end
		end
	end

	if UseW and WREADY then
		local Hit = GetNMinionsHit(BallPos, Wradius)
		if Hit >= 3 then
			CastSpellEx(_W)
		end
	end
	
	if UseE and EREADY then
		local Hit = GetNMinionsHitE(BallPos)
		if Hit >= 3 and (not WREADY or not UseW) then
			CastE(myHero)
		end
	end
end

function FarmJungle()
	JungleMinions:update()
	local UseQ = Menu.JungleFarm.UseQ 
	local UseW = Menu.JungleFarm.UseW 
	local UseE = Menu.JungleFarm.UseE 
	
	local Minion = JungleMinions.objects[1] and JungleMinions.objects[1] or nil
	
	if Minion then
		local Position = VP:GetPredictedPos(Minion, Qdelay, BallSpeed, BallPos)
		if UseQ and QREADY then
			CastSpell(_Q, Position.x, Position.z)
		end
		
		if UseW and WREADY and GetDistanceSqr(BallPos, Minion) < Wradius*Wradius then
			CastSpellEx(_W)
		end
		
		if UseE and (not WREADY or not UseW) and EREADY and GetDistanceSqr(Minion) < 700*700 then
			local starget = myHero
			local dist = GetDistanceSqr(Minion)
			for i, ally in ipairs(GetAllyHeroes()) do
				local dist2 = GetDistanceSqr(ally, Minion)
				if ValidTarget(ally, Erange, false) and dist2 < dist then
					dist = dist2
					starget = ally
				end
			end
			CastE(starget)
		end
	end
end

function FindBestLocationToQ(target)
	local points = {}
	local targets = {}
	
	local CastPosition,  HitChance,  Position = VP:GetLineCastPosition(target, Qdelay, Qradius, Qrange, BallSpeed, BallPos)
	table.insert(points, Position)
	table.insert(targets, target)
	
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Qrange + Rradius) and enemy.networkID ~= target.networkID then
			CastPosition,  HitChance,  Position = VP:GetLineCastPosition(enemy, Qdelay, Qradius, Qrange, BallSpeed, BallPos)
			table.insert(points, Position)
			table.insert(targets, enemy)
		end
	end
	

	for o = 1, 5 do
		local MECa = MEC(points)
		local Circle = MECa:Compute()
		
		if Circle.radius <= Rradius and #points >= 3 and RREADY then
			return Circle.center, 3
		end
	
		if Circle.radius <= Wradius and #points >= 2 and WREADY then
			return Circle.center, 2
		end
		
		if #points == 1 then
			return Circle.center, 1
		elseif Circle.radius <= (Qradius + 50) and #points >= 1 then
			return Circle.center, 2
		end
		
		local Dist = -1
		local MyPoint = points[1]
		local index = 0
		
		for i=2, #points, 1 do
			if GetDistanceSqr(points[i], MyPoint) >= Dist*Dist then
				Dist = GetDistanceSqr(points[i], MyPoint)
				index = i
			end
		end
		if index > 0 then
			table.remove(points, index)
		end
	end
end


function GetBestTarget(Range, Ignore)
	local LessToKill = 100
	local LessToKilli = 0
	local target = nil
	
	for i, enemy in ipairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, Range) then
			DamageToHero = myHero:CalcMagicDamage(enemy, 200)
			ToKill = enemy.health / DamageToHero
			if ((ToKill < LessToKill) or (LessToKilli == 0)) and (Ignore == nil or (Ignore.networkID ~= enemy.networkID)) then
				LessToKill = ToKill
				LessToKilli = i
				target = enemy
			end
		end
	end
	
	if SelectedTarget ~= nil and ValidTarget(SelectedTarget, Range) and (Ignore == nil or (Ignore.networkID ~= SelectedTarget.networkID)) then
		target = SelectedTarget
	end
	
	return target
end

function OnTickChecks()
	QREADY = (myHero:CanUseSpell(_Q) == READY) or ((myHero:GetSpellData(_Q).currentCd < 1) and (myHero:GetSpellData(_Q).level > 0))
	WREADY = (myHero:CanUseSpell(_W) == READY) or ((myHero:GetSpellData(_W).currentCd < 1) and (myHero:GetSpellData(_W).level > 0))
	EREADY = (myHero:CanUseSpell(_E) == READY) or ((myHero:GetSpellData(_E).currentCd < 1) and (myHero:GetSpellData(_E).level > 0))
	RREADY = (myHero:CanUseSpell(_R) == READY) or ((myHero:GetSpellData(_R).currentCd < 1) and (myHero:GetSpellData(_R).level > 0))

	IGNITEREADY = _IGNITE and myHero:CanUseSpell(_IGNITE) == READY or false
	
	if CountEnemyHeroInRange(Qrange + Rradius, myHero) == 1 then
		ComboMode = _ST
	else
		ComboMode = _TF
	end
	

	
	if Menu.Misc.UseW > 1 and WREADY then
		local hitcount, hit = CheckEnemiesHitByW()
		if hitcount >= (Menu.Misc.UseW -1) then
			CastSpellEx(_W)
		end		
	end
	
	if Menu.Misc.UseR > 1 and RREADY then
		local hitcount, hit = CheckEnemiesHitByR()
		if (hitcount >= (Menu.Misc.UseR - 1)) and GetDistanceToClosestAlly(BallPos) < Qrange * Far then
			CastSpellEx(_R)
		end		
	end
	
	if Menu.Misc.AutoEInitiate.Active and EREADY then
		for i, unit in ipairs(GetAllyHeroes()) do
			if GetDistanceSqr(unit) < Erange*Erange then
				for champion, spell in pairs(InitiatorsList) do
					if LastChampionSpell[unit.networkID] and LastChampionSpell[unit.networkID].name ~=nil and Menu.Misc.AutoEInitiate[champion.. LastChampionSpell[unit.networkID].name] and (os.clock() - LastChampionSpell[unit.networkID].time < 1.5) then
						CastE(unit)
					end
				end
			end
		end
	end
	
	if Menu.Misc.Interrupt then
		for i, unit in ipairs(GetEnemyHeroes()) do
			for champion, spell in pairs(InterruptList) do
				if GetDistanceSqr(unit) <= Qrange*Qrange and LastChampionSpell[unit.networkID] and spell == LastChampionSpell[unit.networkID].name and (os.clock() - LastChampionSpell[unit.networkID].time < 1) then
					CastSpell(_Q, unit.x, unit.z)
					if GetDistanceSqr(BallPos, unit) < Rradius*Rradius then
						CastSpellEx(_R)
					end
				end
			end
		end
	end
end

function OnWndMsg(Msg, Key)
	if Msg == WM_LBUTTONDOWN then
		local minD = 0
		local starget = nil
		for i, enemy in ipairs(GetEnemyHeroes()) do
			if ValidTarget(enemy) then
				if GetDistanceSqr(enemy, mousePos) <= minD*minD or starget == nil then
					minD = GetDistanceSqr(enemy, mousePos)
					starget = enemy
				end
			end
		end
		
		if starget and minD < 100 then
			if SelectedTarget and starget.charName == SelectedTarget.charName then
				SelectedTarget = nil
			else
				SelectedTarget = starget
				print("<font color=\"#FF0000\">Orianna: New target selected: "..starget.charName.."</font>")
			end
		end
	end
end

function Harass(target)
	if Menu.Harass.UseQ and target then
		CastQ(target)
	end
	if Menu.Harass.UseW then
		CastW()
	end
end

function GetDistanceToClosestAlly(p)
	local d = GetDistanceSqr(p, myHero)
	for i, ally in ipairs(GetAllyHeroes()) do
		if ValidTarget(ally, math.huge, false) then
			local dist = GetDistanceSqr(p, ally)
			if dist < d then
				d = dist
			end
		end
	end
	return d
end

function CountAllyHeroInRange(range, point)
	local n = 0
	for i, ally in ipairs(GetAllyHeroes()) do
		if ValidTarget(ally, math.huge, false) and GetDistanceSqr(point, ally) <= range * range then
			n = n + 1
		end
	end
	return n
end

function Combo(target)
	if ComboMode == _ST then--Single Target

		if target and Menu.Combo.UseR and CountEnemyHeroInRange(1000, target) >= CountAllyHeroInRange(1000, target)  then
			if target and GetComboDamage(MainCombo, target) > target.health and GetDistanceToClosestAlly(BallPos) < Qrange * Far then
				local hitcount, hit = CheckEnemiesHitByR()
				if hitcount >= Menu.Combo.UseRN then
					CastR(target)
				end
			end
		end

		if Menu.Combo.UseW then
			CastW()
		end
		
		if Menu.Combo.UseQ and target and QREADY then
			CastQ(target)
		end
		
		if Menu.Combo.UseE then
			for i, ally in ipairs(GetAllyHeroes()) do
				if ValidTarget(ally, math.huge, false) and GetDistanceSqr(ally) < Erange*Erange and CountEnemyHeroInRange(400, ally) >= 1 and (target == nil or GetDistanceSqr(ally, target) < 400*400) then
					CastE(ally)
				end
			end
		end
		
		if Menu.Combo.UseE then
			CastECH(myHero, 1)
		end
	else
		if Menu.Combo.UseR then
			if CountEnemyHeroInRange(800, BallPos) > 1 then
				local hitcount, hit = CheckEnemiesHitByR()
				local potentialkills, kills = 0, 0
				if hitcount >= 2 then
					for i, champion in ipairs(hit) do
						if (champion.health - GetComboDamage(MainCombo, champion)) < 0.4*champion.maxHealth or (GetComboDamage(MainCombo, champion) >= 0.4*champion.maxHealth) then
							potentialkills = potentialkills + 1
						end
						if (champion.health - GetComboDamage(MainCombo, champion)) < 0 then
							kills = kills + 1
						end
					end
				end
				if (((GetDistanceToClosestAlly(BallPos) < Qrange * Far) and ((hitcount >= CountEnemyHeroInRange(800, BallPos))) or (potentialkills >= 2)) or kills >= 1) and hitcount >= Menu.Combo.UseRN then
					CastSpellEx(_R)
				end
			elseif Menu.Combo.UseRN == 1 then
				if target and GetComboDamage({_Q, _W, _R}, target) > target.health and GetDistanceToClosestAlly(BallPos) < Qrange * Far then
					CastR(target)
				end
			end
		end
		
		if Menu.Combo.UseW then
			CastW()
		end

		if Menu.Combo.UseQ and target then
			local Qposition, hit = FindBestLocationToQ(target)
			
			if Qposition and hit > 1 then
				CastSpell(_Q, Qposition.x, Qposition.z)
			else
				CastQ(target)
			end
		end
		
		if Menu.Combo.UseE and EREADY then
			if CountEnemyHeroInRange(800, BallPos) <= 2 then
				CastECH(myHero, 1)
			else
				CastECH(myHero, 2)
			end
			
			
			for i, ally in ipairs(GetAllyHeroes()) do
				if ValidTarget(ally, Erange, false) and CountEnemyHeroInRange(300, ally) >= 3 and (target == nil or GetDistanceSqr(ally, target) < 300*300) then
					CastSpell(_E, ally)
				end
			end
		end
	end
end

function OnTick()
	OnTickChecks()
	local target = GetBestTarget(Qrange + Qradius)
	if not target then
		target = GetBestTarget(Qrange + Qradius * 2)
	end
	if Menu.Combo.Enabled then
		Combo(target)
	elseif (Menu.Harass.Enabled or Menu.Harass.Enabled2) and (Menu.Harass.ManaCheck <= (myHero.mana / myHero.maxMana * 100)) then
		Harass(target)
	end

	if Menu.Farm.Freeze or Menu.Farm.LaneClear then
		local Mode = Menu.Farm.Freeze and "Freeze" or "LaneClear"
		if Menu.Farm.ManaCheck >= (myHero.mana / myHero.maxMana * 100) then
			Mode = "Freeze"
		end

		Farm(Mode)
	end
	
	if Menu.JungleFarm.Enabled then
		FarmJungle()
	end
end

AddCastSpellCallback(function(spell, p, p2, p3)
	if Menu.Misc.BlockR then
		if spell == _R then
			local hitnumber, hit = CheckEnemiesHitByR()
			if hitnumber == 0 then
				BlockR = true
			end
		end
	end
end)

function OnSendPacket(p)
	if p.header == 104 and BlockR then
		p:Block()
		BlockR = false
	end
end

	
--[[	Credits to zikkah	]]
function GetHPBarPos(enemy)
	enemy.barData = GetEnemyBarData()
	local barPos = GetUnitHPBarPos(enemy)
	local barPosOffset = GetUnitHPBarOffset(enemy)
	local barOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local barPosPercentageOffset = { x = enemy.barData.PercentageOffset.x, y = enemy.barData.PercentageOffset.y }
	local BarPosOffsetX = 171
	local BarPosOffsetY = 46
	local CorrectionY =  0
	local StartHpPos = 31
	barPos.x = barPos.x + (barPosOffset.x - 0.5 + barPosPercentageOffset.x) * BarPosOffsetX + StartHpPos
	barPos.y = barPos.y + (barPosOffset.y - 0.5 + barPosPercentageOffset.y) * BarPosOffsetY + CorrectionY 
						
	local StartPos = Vector(barPos.x , barPos.y, 0)
	local EndPos =  Vector(barPos.x + 108 , barPos.y , 0)

	return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

function DrawIndicator(unit, health)
	local SPos, EPos = GetHPBarPos(unit)
	local barlenght = EPos.x - SPos.x
	local Position = SPos.x + (health / unit.maxHealth) * barlenght
	if Position < SPos.x then
		Position = SPos.x
	end
	DrawText("|", 13, Position, SPos.y+10, ARGB(255,0,255,0))
end

function DrawOnHPBar(unit, health)
	local Pos = GetHPBarPos(unit)
	if health < 0 then
		DrawCircle2(unit.x, unit.y, unit.z, 100, ARGB(255, 255, 0, 0))	
		DrawText("HP: "..health,13, Pos.x, Pos.y, ARGB(255,255,0,0))
	else
		DrawText("HP: "..health,13, Pos.x, Pos.y, ARGB(255,0,255,0))
	end
end

--[[Credits to barasia, vadash and viseversa for anti-lag circles]]
function DrawCircleNextLvl(x, y, z, radius, width, color, chordlength)
	radius = radius or 300
	quality = math.max(8,math.floor(180/math.deg((math.asin((chordlength/(2*radius)))))))
	quality = 2 * math.pi / quality
	local points = {}
	for theta = 0, 2 * math.pi + quality, quality do
		local c = WorldToScreen(D3DXVECTOR3(x + radius * math.cos(theta), y, z - radius * math.sin(theta)))
		points[#points + 1] = D3DXVECTOR2(c.x, c.y)
	end
	DrawLines2(points, width or 1, color or 4294967295)
end

function DrawCircle2(x, y, z, radius, color)
	local vPos1 = Vector(x, y, z)
	local vPos2 = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
	local tPos = vPos1 - (vPos1 - vPos2):normalized() * radius
	local sPos = WorldToScreen(D3DXVECTOR3(tPos.x, tPos.y, tPos.z))
	if OnScreen({ x = sPos.x, y = sPos.y }, { x = sPos.x, y = sPos.y })  then
		DrawCircleNextLvl(x, y, z, radius, 1, color, 75)	
	end
end


function OnDraw()

	if Menu.Drawing.Qrange then
		DrawCircle2(myHero.x, myHero.y, myHero.z, Qrange, ARGB(255, 0, 255, 0))
	end
	
	if Menu.Drawing.Erange then
		DrawCircle2(myHero.x, myHero.y, myHero.z, Erange, ARGB(255, 0, 255, 0))
	end
	
	if Menu.Drawing.Wrange then
		DrawCircle2(BallPos.x, BallPos.y, BallPos.z, Wradius, ARGB(255,0,255,0))
	end
	
	if Menu.Drawing.Rrange then
		DrawCircle2(BallPos.x, BallPos.y, BallPos.z, Rradius, ARGB(255,0,255,0))
	end
	
	if Menu.Drawing.DrawBall then
		DrawCircle2(BallPos.x, BallPos.y, BallPos.z, 100, ARGB(255,0,255,0))
	end
	
	--[[HealthBar HP tracker]]
	if Menu.Drawing.DrawDamage then
		for i=1, heroManager.iCount do
			local enemy = heroManager:GetHero(i)
			if ValidTarget(enemy) then
				if DamageToHeros[i] ~= nil then
					RemainingHealth = enemy.health - DamageToHeros[i]
				end
				if RemainingHealth ~= nil then
					DrawIndicator(enemy, math.floor(RemainingHealth))
					DrawOnHPBar(enemy, math.floor(RemainingHealth))
				end
			end
		end
	end

	if SelectedTarget ~= nil and ValidTarget(SelectedTarget) then
		DrawCircle2(SelectedTarget.x, SelectedTarget.y, SelectedTarget.z, 100, ARGB(255,255,0,0))
	end
end
  

-- Delay the auto updating to allow fast double F9
DelayAction(function()
	local VersionData = GetWebResult('chdev.info', '/orianna.version')
	if VersionData ~= nil and string.match(VersionData, 'ServerVersion') and load ~= nil then
		-- load the ServerVersion and ChangeLog
		load(VersionData)()
		if ServerVersion then
			-- if local version is lower then update
			if tonumber(version) < ServerVersion and AUTO_UPDATE then
				AutoupdaterMsg('New version available: ' .. ServerVersion)
				AutoupdaterMsg('Updating, please don\'t press F9')
				DelayAction(function() DownloadFile(UPDATE_URL, UPDATE_FILE_PATH, function () AutoupdaterMsg('Successfully updated. ('..version..' => '..ServerVersion..'), press F9 twice to load the updated version.') end) end, 1)
			end
		end
		
		if ChangeLog then
			AutoupdaterMsg('Changelog: ' .. ChangeLog)
		end
	end
end, 1)
