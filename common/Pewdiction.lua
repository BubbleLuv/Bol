--[[	Examples:
	local Pred = Pewdiction()
	Pred:RegisterDashCallback(function(dashStartPos, dashEndPos, dashUnit, isMyHeroInDash, collisionTime)
		if isMyHeroInDash and myHero:CanUseSpell(_E) == READY then
			if collisionTime < os.clock() + 0.25 then -- _E windUpTime = 0.25
				local castPos = dashStartPos + (Vector(myHero.pos) - dashStartPos):normalized() * 475 -- _E range = 475
				CastSpell(_E, castPos.x, castPos.z)
			end
		end
	end)
	Pred:RegisterInteruptCallback(function(interuptUnit, interuptPos, interuptDistance, interuptEndTime)
		local TimeToHit = spellDelay + ((interuptDistance - spellMissileOffset) / spellMissileSpeed)
		if os.clock() + TimeToHit < interuptEndTime then
			CastSpell(spellSlot, interuptPos.x, interuptPos.z)
		end	
	end)
	local CastPos, HitChance = Pred:GetBestCastPosition(target, spellDelay, spellWidth, spellRange, spellMissileSpeed, spellCastPos, spellMissileOffset)
	if CastPos and HitChance >= Pred.HITCHANCE_HIGH then
		CastSpell(spellSlot, CastPos.x, CastPos.z)
	end
	local isNotCollision, collisionCount, collisionMinions = Pred:MinionCollision(spellCastPos, CastPos, spellWidth, target, spellDelay, spellMissileSpeed, spellMissileOffset)
	--isNotCollision, Boolean - true if there is no collision
	--collisionCount, int - Number of minions in collision
	--collisionMinions, table - Contains table of minions that spell will collide with
--]]

--~~~~~~ General Localizations
local pi, pi2, atan, huge = math.pi, 2*math.pi, math.atan, math.huge
local clock = os.clock
local pairs, ipairs = pairs, ipairs
local insert, remove = table.insert, table.remove
local TEAM_ALLY, TEAM_ENEMY
local COLOR_WHITE, COLOR_RED = ARGB(255,255,255,255), ARGB(185,255,0,0)
--~~~~~~ End Localizations

class "ScriptUpdate"
function ScriptUpdate:__init(LocalVersion, Host, VersionPath, ScriptPath, SavePath, CallbackUpdate, CallbackNoUpdate, CallbackNewVersion)
    self.LocalVersion = LocalVersion
    self.Host = Host
    self.VersionPath = '/BoL/TCPUpdater/GetScript2.php?script='..self:Base64Encode(self.Host..VersionPath)..'&rand='..math.random(99999999)
    self.ScriptPath = '/BoL/TCPUpdater/GetScript2.php?script='..self:Base64Encode(self.Host..ScriptPath)..'&rand='..math.random(99999999)
    self.SavePath = SavePath
    self.CallbackUpdate = CallbackUpdate
    self.CallbackNoUpdate = CallbackNoUpdate
    self.CallbackNewVersion = CallbackNewVersion
    self.LuaSocket = require("socket")
    self.Socket = self.LuaSocket.connect('sx-bol.eu', 80)
    self.Socket:send("GET "..self.VersionPath.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
    self.Socket:settimeout(0, 'b')
    self.Socket:settimeout(99999999, 't')
    self.LastPrint = ""
    self.File = ""
    AddTickCallback(function() self:GetOnlineVersion() end)
end

function ScriptUpdate:Base64Encode(data)
    local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
    return ((data:gsub('.', function(x)
        local r,b='',x:byte()
        for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and '1' or '0') end
        return r;
    end)..'0000'):gsub('%d%d%d?%d?%d?%d?', function(x)
        if (#x < 6) then return '' end
        local c=0
        for i=1,6 do c=c+(x:sub(i,i)=='1' and 2^(6-i) or 0) end
        return b:sub(c+1,c+1)
    end)..({ '', '==', '=' })[#data%3+1])
end

function ScriptUpdate:GetOnlineVersion()
    if self.Status == 'closed' then return end
    self.Receive, self.Status, self.Snipped = self.Socket:receive(1024)

    if self.Receive then
        if self.LastPrint ~= self.Receive then
            self.LastPrint = self.Receive
            self.File = self.File .. self.Receive
        end
    end

    if self.Snipped ~= "" and self.Snipped then
        self.File = self.File .. self.Snipped
    end
    if self.Status == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('\r\n\r\n')
        if HeaderEnd and ContentStart then
            self.OnlineVersion = tonumber(self.File:sub(ContentStart + 1))
            if self.OnlineVersion > self.LocalVersion then
                if self.CallbackNewVersion and type(self.CallbackNewVersion) == 'function' then
                    self.CallbackNewVersion(self.OnlineVersion,self.LocalVersion)
                end
                self.DownloadSocket = self.LuaSocket.connect('sx-bol.eu', 80)
                self.DownloadSocket:send("GET "..self.ScriptPath.." HTTP/1.0\r\nHost: sx-bol.eu\r\n\r\n")
                self.DownloadSocket:settimeout(0, 'b')
                self.DownloadSocket:settimeout(99999999, 't')
                self.LastPrint = ""
                self.File = ""
                AddTickCallback(function() self:DownloadUpdate() end)
            else
                if self.CallbackNoUpdate and type(self.CallbackNoUpdate) == 'function' then
                    self.CallbackNoUpdate(self.LocalVersion)
                end
            end
        else
            print('Error: Could not get end of Header')
        end
    end
end

function ScriptUpdate:DownloadUpdate()
    if self.DownloadStatus == 'closed' then return end
    self.DownloadReceive, self.DownloadStatus, self.DownloadSnipped = self.DownloadSocket:receive(1024)

    if self.DownloadReceive then
        if self.LastPrint ~= self.DownloadReceive then
            self.LastPrint = self.DownloadReceive
            self.File = self.File .. self.DownloadReceive
        end
    end

    if self.DownloadSnipped ~= "" and self.DownloadSnipped then
        self.File = self.File .. self.DownloadSnipped
    end

    if self.DownloadStatus == 'closed' then
        local HeaderEnd, ContentStart = self.File:find('\r\n\r\n')
        if HeaderEnd and ContentStart then
            local ScriptFileOpen = io.open(self.SavePath, "w+")
            ScriptFileOpen:write(self.File:sub(ContentStart + 1))
            ScriptFileOpen:close()
            if self.CallbackUpdate and type(self.CallbackUpdate) == 'function' then
                self.CallbackUpdate(self.OnlineVersion,self.LocalVersion)
            end
        end
    end
end

class 'Pewdiction'

function Pewdiction:__init()
	self.Version = 0.01
	ScriptUpdate(self.Version, 'raw.githubusercontent.com', '/PewPewPew2/BoL/Danger-Meter/Pewdiction.version', '/PewPewPew2/BoL/Danger-Meter/Pewdiction.lua', SCRIPT_PATH..GetCurrentEnv().FILE_NAME, function() print('Pewdiction: Update Complete. Reload(F9 F9)') end, function() print('Pewdiction: Latest Version Loaded.') end, function() print('Pewdiction: New Version Found, please wait...') end)

	TEAM_ALLY = myHero.team
	TEAM_ENEMY = TEAM_ALLY == 100 and 200 or 100
	local m, b = Minions(), Buffs()
	self.Minions = m.Objects
	self.Buffs = b.Buffs
	self.Enemies = GetEnemyHeroes()
	self.HITCHANCE_LOW = 1
	self.HITCHANCE_MEDIUM = 2
	self.HITCHANCE_HIGH = 3
	self.HITCHANCE_VERYHIGH = 4
	self.TargetsVisible = {}
	for i=1, #self.Enemies do
		self.TargetsVisible[self.Enemies[i].networkID] = self.Enemies[i].visible and clock() or huge 
	end
	self.WaypointHistory = {}
	self.ActiveImmobile = {}
	self.ActiveDashes = {}
	self.ActiveSlows = {}
	self.Wait = {}
	self.DashCallbacks = {}
	self.InteruptCallbacks = {}
	AddNewPathCallback(function(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
		self:NewPath(unit, startPos, endPos, isDash, dashSpeed, dashGravity, dashDistance)
	end)
	AddProcessSpellCallback(function(unit, spell) self:ProcessSpell(unit, spell) end)
	if VIP_USER then
		AddRecvPacketCallback(function(p) self:RecvPacket(p) end)
	else
		AddTickCallback(function() 
			for i, enemy in ipairs(self.Enemies) do
				if enemy.valid then
					if enemy.visible then
						if self.TargetsVisible[enemy.networkID] == huge then
							self.TargetsVisible[enemy.networkID] = clock()
						end
					elseif self.TargetsVisible[enemy.networkID] ~= huge then
						self.TargetsVisible[enemy.networkID] = huge
						self.WaypointHistory[enemy.networkID] = {}
					end
				end
			end
		end)
	end
	self.Dashes = {
		['ahritumble'] 				= { ['type'] = 1, ['range'] = 475, ['speed'] = 1500, ['Menu'] = 'Ahri R',	      	},
		['gravesmove'] 				= { ['type'] = 1, ['range'] = 475, ['speed'] = 1450, ['Menu'] = 'Graves E',			},
		['khazixe'] 				= { ['type'] = 1, ['range'] = 600, ['speed'] = 1700, ['Menu'] = 'Khazix E',			},
		['khazixelong'] 			= { ['type'] = 1, ['range'] = 900, ['speed'] = 1700, ['Menu'] = 'Khazix E',			},
		['leblancslide'] 			= { ['type'] = 1, ['range'] = 600, ['speed'] = 1750, ['Menu'] = 'Leblanc W',		},
		['leblancslidem'] 			= { ['type'] = 1, ['range'] = 600, ['speed'] = 1750, ['Menu'] = 'Leblanc W',		},
		['luciane'] 				= { ['type'] = 1, ['range'] = 425, ['speed'] = 1550, ['Menu'] = 'Lucian E',			},
		['renektonsliceanddice'] 	= { ['type'] = 1, ['range'] = 450, ['speed'] = 1200, ['Menu'] = 'Renekton E',	  	},
		['renektondice'] 			= { ['type'] = 1, ['range'] = 450, ['speed'] = 1200, ['Menu'] = 'Renekton E',	  	},
		['sejuaniarcticassault'] 	= { ['type'] = 1, ['range'] = 625, ['speed'] = 1250, ['Menu'] = 'Sejuani Q',	  	},
		['shenshadowdash'] 			= { ['type'] = 1, ['range'] = 575, ['speed'] = 1250, ['Menu'] = 'Shen E',			},
		['shyvanatransformcast'] 	= { ['type'] = 1, ['range'] = 1000,['speed'] = 920,	 ['Menu'] = 'Shyvana R',		},
		['tristanaw'] 				= { ['type'] = 1, ['range'] = 845, ['speed'] = 850,  ['Menu'] = 'Tristana W',		},
		['slashcast'] 				= { ['type'] = 1, ['range'] = 660, ['speed'] = 1050, ['Menu'] = 'Tryndamere E', 	},
		['aatroxq'] 				= { ['type'] = 1, ['range'] = 650, ['speed'] = 1200, ['Menu'] = 'Aatrox Q',		  	},
		['carpetbomb'] 				= { ['type'] = 1, ['range'] = 800, ['speed'] = 1100, ['Menu'] = 'Corki W',			},
		['gnare'] 					= { ['type'] = 1, ['range'] = 475, ['speed'] = 950,	 ['Menu'] = 'Gnar E',		  	},
		['gnarbige'] 				= { ['type'] = 1, ['range'] = 475, ['speed'] = 950,	 ['Menu'] = 'Mega Gnar E',    	},
		['gragase'] 				= { ['type'] = 1, ['range'] = 600, ['speed'] = 1100, ['Menu'] = 'Gragas E',			},
		['hecarimult'] 				= { ['type'] = 1, ['range'] = 1000,['speed'] = 1300, ['Menu'] = 'Hecarim R',		},
		['ufslash'] 				= { ['type'] = 1, ['range'] = 1000,['speed'] = 1715, ['Menu'] = 'Malphite R',		},
		['rivenfeint'] 				= { ['type'] = 2, ['range'] = 250, ['speed'] = 1000, ['Menu'] = 'Riven E',			},
		['vaynetumble'] 			= { ['type'] = 2, ['range'] = 300, ['speed'] = 900,	 ['Menu'] = 'Vayne Q',		 	},
		['pounce'] 					= { ['type'] = 2, ['range'] = 375, ['speed'] = 1075, ['Menu'] = 'Cougar Nidalee W',	},
		['reksaieburrowed'] 		= { ['type'] = 2, ['range'] = 800, ['speed'] = 800,	 ['Menu'] = 'RekSai E',			},
		['akalishadowdance'] 		= { ['type'] = 3, ['range'] = 700, ['speed'] = 2250, ['Menu'] = 'AkaliR',			},
		['headbutt']				= { ['type'] = 3, ['range'] = 650, ['speed'] = 1800, ['Menu'] = 'Alistar W',		},
		['dianateleport'] 			= { ['type'] = 3, ['range'] = 825, ['speed'] = 2000, ['Menu'] = 'Diana R',		  	},
		['ireliagatotsu'] 			= { ['type'] = 3, ['range'] = 650, ['speed'] = 2250, ['Menu'] = 'Irelia Q',			},
		['jaxleapstrike'] 			= { ['type'] = 3, ['range'] = 700, ['speed'] = 1500, ['Menu'] = 'Jax Q',			},
		['maokaiunstablegrowth'] 	= { ['type'] = 3, ['range'] = 525, ['speed'] = 2200, ['Menu'] = 'Maokai W',			},
		['monkeykingnimbus'] 		= { ['type'] = 3, ['range'] = 625, ['speed'] = 2000, ['Menu'] = 'Wukong E',			},
		['jarvanivcataclysm'] 		= { ['type'] = 3, ['range'] = 650, ['speed'] = 2000, ['Menu'] = 'Jarvan IV R',		},
		['quinne'] 					= { ['type'] = 3, ['range'] = 700, ['speed'] = 2000, ['Menu'] = 'Quinn E',			},
		['quinnvalore'] 			= { ['type'] = 3, ['range'] = 700, ['speed'] = 2000, ['Menu'] = 'Quinn Valor E',	},
		['threshqleap'] 			= { ['type'] = 3, ['range'] = 1100,['speed'] = 1200, ['Menu'] = 'Thresh Q',			},
		['vir'] 					= { ['type'] = 3, ['range'] = 800, ['speed'] =  850, ['Menu'] = 'Vir R',			},
		['braumw'] 					= { ['type'] = 3, ['range'] = 625, ['speed'] = 1750, ['Menu'] = 'Braum W',			},
		['xenzhaosweep'] 			= { ['type'] = 3, ['range'] = 600, ['speed'] = 2600, ['Menu'] = 'Xin Zhao E',		},
		['fioraq'] 					= { ['type'] = 3, ['range'] = 600, ['speed'] = 2000, ['Menu'] = 'Fiora Q',		  	},
		['pantheonw'] 				= { ['type'] = 3, ['range'] = 600, ['speed'] = 1500, ['Menu'] = 'Pantheon W',	   	},
		['caitlynentrapment']		= { ['type'] = 4, ['range'] = 490, ['speed'] = 1075, ['Menu'] = 'Caitlyn E',		},
		['fizzpiercingstrike'] 		= { ['type'] = 5, ['range'] = 550, ['speed'] = 1800, ['Menu'] = 'Fizz Q',			},
		['yasuodashwrapper'] 		= { ['type'] = 5, ['range'] = 475, ['speed'] = 1150, ['Menu'] = 'Yasuo E',			},
		['poppyheroiccharge'] 		= { ['type'] = 5, ['range'] = 525, ['speed'] = 1600, ['Menu'] = 'Poppy E',			},
		['ezrealarcaneshift'] 		= { ['type'] = 6, ['range'] = 475, ['delay'] = 0.25, ['Menu'] = 'Ezreal E',			},	--flashes start here
		['crowstorm'] 				= { ['type'] = 6, ['range'] = 800, ['delay'] = 1.77, ['Menu'] = 'FiddleSticks R',	},
		['deceive'] 				= { ['type'] = 6, ['range'] = 400, ['delay'] = 0.33, ['Menu'] = 'Shaco Q',			},
		['riftwalk'] 				= { ['type'] = 6, ['range'] = 650, ['delay'] = 0.33, ['Menu'] = 'Kassadin R',		},
		['summonerflash']			= { ['type'] = 6, ['range'] = 400, ['delay'] = 0.015,['Menu'] = 'Summoner Flash',	},
		['elisespideredescent'] 	= { ['type'] = 7, ['range'] =   0, ['delay'] =  0.7, ['Menu'] = 'Elise W Descent',	},
		['alphastrike'] 			= { ['type'] = 7, ['range'] =   0, ['delay'] = 0.381,['Menu'] = 'Master Yi Q',	 	},
		['taloncutthroat'] 			= { ['type'] = 7, ['range'] =   0, ['delay'] = 	0.7, ['Menu'] = 'Talon E',	     	},
		['infiniteduress'] 			= { ['type'] = 7, ['range'] =   0, ['delay'] = 0.016,['Menu'] = 'Warwick R',	 	},
		['katarinae'] 				= { ['type'] = 7, ['range'] =   0, ['delay'] =  0.4, ['Menu'] = 'Katarina E',	 	},
		['elisespidere'] 			= { ['type'] = 7, ['range'] =   0, ['delay'] =  0.7, ['Menu'] = 'Elise Spider E',	},
		
		--['blindmonkqtwo'] 		= { ['type'] = 3, ['range'] = 1300,['speed'] = 2300, ['Menu'] = 'Lee Sin Q',}, no target for some reason
		--['blindmonkwone'] 		= { ['type'] = 3, ['range'] = 700, ['speed'] = 3000,}, no target for some reason
		--['fizzjumptwo'] 			= { ['type'] = 1, ['range'] = 400, ['speed'] = 1000,}, fizz becomes nil ??
		
		--['viq'] 					= { ['type'] = 2, ['range'] = ???, ['speed'] = 0, ['Menu'] = 'Vi Q',	},
		--['leonazenithblade'] 		= { ['type'] = 1, ['range'] = 875, ['speed'] = 0,  ['Menu'] = 'Leona E',	},
		--['nautilusanchordrag'] 	= { ['type'] = 1, ['range'] = 1100,['speed'] = 0,['Menu'] = 'Nautilus Q',},
		--['bandagetoss'] 			= { ['type'] = 1, ['range'] = 1100,['speed'] = 0,	},
		--['jarvanivdragonstrike'] 	= { ['type'] = 6, ['range'] = 770, ['speed'] = 0, ['Menu'] = 'JarvanIV EQ',	},
		--['azire'] 				= { ['type'] = 6, ['range'] = 770, ['speed'] = 0, ['Menu'] = 'Azir E',	},
		--['zace'] 					= { ['type'] = 3, ['range'] = ???, ['speed'] = 0, ['Menu'] = 'Zac E',	},
		--['nocturneparanoia2'] = { ['type'] = 3, ['range'] = 1250 + (750 * rLvl), ['speed'] = 0, },
	}
	self.ChannelBuffs = {
		['fearmonger_marker'] 		= true,	['katarinarsound'] 		= true,		['lissandrarself'] 		= true,
		['alzaharnethergrasp'] 		= true,	['meditate'] 			= true,		['absolutezero'] 		= true,
		['missfortunebulletsound'] 	= true,	['pantheonesound'] 		= true,		['velkozr'] 			= true,
		['infiniteduresssound'] 	= true,	['reapthewhirlwind'] 	= true,		['zhonyasringshield']   = true,
		['chronorevive']			= true,
		--['crowstorm']             = true,	['galioidolofdurand']   = true,		['shenstandunited']     = true,	FIND CORRECT NAMES
	}
	return self
end

function Pewdiction:RecvPacket(p)
	if p.header == 0x00D2 then --losevision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			self.TargetsVisible[o.networkID] = huge
			self.WaypointHistory[o.networkID] = {}
		end	
	end
	if p.header == 0x00A0 then --gainvision
		p.pos=2
		local o = objManager:GetObjectByNetworkId(p:DecodeF())
		if o and o.valid and o.type == 'AIHeroClient' and o.team == TEAM_ENEMY then
			self.TargetsVisible[o.networkID] = clock()
		end
	end	
end

function Pewdiction:ProcessSpell(unit, spell)
	if unit and unit.valid and unit.type == 'AIHeroClient' and unit.team == TEAM_ENEMY then
		local lowName = spell.name:lower()
		local d = self.Dashes[lowName]
		if d then
			local ePos, sPos, myPos = Vector(spell.endPos.x, spell.endPos.y, spell.endPos.z), Vector(unit.pos.x, unit.pos.y, unit.pos.z), Vector(myHero.pos.x, myHero.pos.y, myHero.pos.z)
			local endPos
			if d.type == 1 then
				endPos = GetDistance(ePos, sPos) < d.range and ePos or sPos + (ePos - sPos):normalized() * d.range
			elseif d.type == 2 then
				endPos = sPos + (sPos-ePos):normalized() * d.range
			elseif d.type == 3 then
				local tPos = Vector(spell.target.pos.x, spell.target.pos.y, spell.target.pos.z)
				endPos = sPos + (tPos - sPos):normalized() * (GetDistance(sPos,tPos) - 50)
			elseif d.type == 4 then
				endPos = sPos + (ePos - sPos):normalized() * (-d.range)
			elseif d.type == 5 then
				local tPos = Vector(spell.target.pos.x, spell.target.pos.y, spell.target.pos.z)
				endPos = sPos + (tPos - sPos):normalized() * GetDistance(sPos,tPos)
			elseif d.type == 6 then
				local distBetween = GetDistance(ePos, sPos)
				endPos = distBetween < d.range and ePos or sPos + (ePos - sPos):normalized() * d.range				
			elseif d.type == 7 then
				endPos = Vector(spell.target.pos.x, spell.target.pos.y, spell.target.pos.z)
			end
			if not IsWall(D3DXVECTOR3(endPos.x, endPos.y, endPos.z)) then
				local duration = d.delay and d.delay or GetDistance(sPos, endPos) / d.speed
				self.ActiveDashes[unit.networkID] = {
					['type'] 	 = d.type,
					['duration'] = duration,
					['startT']   = clock(),
					['endT'] 	 = clock() + duration,
					['speed']    = d.speed,
					['startPos'] = sPos,
					['endPos'] 	 = endPos,
				}
				self.Wait[unit.networkID] = self.ActiveDashes[unit.networkID].endT
			end
			if #self.DashCallbacks ~= 0 then	
				local real = sPos + (endPos - sPos):normalized() * (d.range + 120)
				local onSegment, onLine, isOnSegment = VectorPointProjectionOnLineSegment(sPos, real, Vector(myHero.pos))
				isOnSegment = isOnSegment and GetDistance(onSegment, myHero.pos) < (120 + myHero.boundingRadius)
				local collisionTime = isOnSegment and (GetDistance(sPos, onSegment) / d.speed) + spell.windUpTime or huge
				for i, func in ipairs(self.DashCallbacks) do
					func(sPos, real, unit, isOnSegment, collisionTime)
				end
			end
			return
		end	
		self.ActiveImmobile[unit.networkID] = clock() + spell.windUpTime
	end
end

function Pewdiction:NewPath(unit, startPos, endPos, isDash, dashSpeed)
	if unit and unit.valid and unit.type == 'AIHeroClient' and unit.team == TEAM_ENEMY then
		if not isDash then
			self.Wait[unit.networkID] = false
			if not self.WaypointHistory[unit.networkID] then
				self.WaypointHistory[unit.networkID] = {}
			end
			if unit.path and unit.path.count > 0 then
				self.WaypointHistory[unit.networkID][#self.WaypointHistory[unit.networkID]+1] = {
					pos = Vector(unit.pos.x, unit.pos.y, unit.pos.z), 
					waypoint = Vector(unit.endPath.x, unit.endPath.y, unit.endPath.z), 
					time = clock(), 
					n = unit.pathCount
				}
			end
		end
	end
end

function Pewdiction:RegisterDashCallback(func)
	self.DashCallbacks[#self.DashCallbacks + 1] = func
end

function Pewdiction:RegisterInteruptCallback(func)
	if #self.InteruptCallbacks == 0 then
		AddTickCallback(function()
			for _, enemy in pairs(self.Enemies) do
				if enemy.valid then
					for name, buff in pairs(self.Buffs[enemy.networkID]) do
						if self.ChannelBuffs[name] then
							local uPos = enemy.pos
							local distance = GetDistance(uPos, myHero.pos)
							for i, func in ipairs(self.InteruptCallbacks) do
								func(enemy, uPos, distance, buff.endT)
							end
						end
					end
				end
			end
		end)
	end
	self.InteruptCallbacks[#self.InteruptCallbacks + 1] = func
end

function Pewdiction:IsImmobile(unit, delay, speed, from, missileOffset)
	local uID = unit.networkID
	if self.Buffs[uID] then
		for name, buff in pairs(self.Buffs[uID]) do
			if self.ChannelBuffs[name] or buff.type == 5 or buff.type == 11 or buff.type == 29 or buff.type == 24 then
				self.ActiveImmobile[uID] = buff.endT
			elseif buff.type == 30 then
				self.Wait[uID] = clock() + 0.25
			end
		end
	end	
	if self.ActiveImmobile[uID] then
		local ExtraDelay = speed == huge and 0 or ((GetDistance(from, Vector(unit.pos.x, unit.pos.y, unit.pos.z)) - missileOffset) / speed)
		local remainingTime = self.ActiveImmobile[uID] - clock() > 0 and self.ActiveImmobile[uID] - clock() or 0
		return self.ActiveImmobile[uID] > (clock() + delay + ExtraDelay), Vector(unit.pos.x, unit.pos.y, unit.pos.z), remainingTime
	end
	return false, Vector(unit.pos.x, unit.pos.y, unit.pos.z), 0
end

function Pewdiction:IsSlowed(unit, delay, speed, from, missileOffset)
	local uID = unit.networkID
	if self.Buffs[uID] then
		for hash, buff in pairs(self.Buffs[uID]) do
			if buff.type == 10 or buff.type == 22 or buff.type == 21 or buff.type == 8 then
				self.ActiveSlows[uID] = buff.endT - clock()
			end
		end
	end		
	return self.ActiveSlows[uID] and self.ActiveSlows[uID] > (clock() + delay + ((GetDistance(Vector(unit.pos.x, unit.pos.y, unit.pos.z), from) - missileOffset) / speed))
end

function Pewdiction:IsDashing(unit, delay, width, speed, from, missileOffset)
	local isDashing, canHit, dashPos = false, false, nil
	if self.ActiveDashes[unit.networkID] then
		local d = self.ActiveDashes[unit.networkID]
		if d.endT >= clock() then
			local myPos = Vector(myHero.pos.x, myHero.pos.y, myHero.pos.z)
			isDashing = true
			if d.type < 6 then
				local interceptTime, interceptPos = VectorMovementCollision(d.startPos, d.endPos, d.speed, myPos, speed, clock()-d.startT)
				if interceptPos then
					interceptPos = Vector(interceptPos.x, 0, interceptPos.y)
					local timeToHit = delay + ((GetDistance(myPos, interceptPos) - missileOffset)/speed)
					if timeToHit > interceptTime then
						local xtraDistance = (d.speed * (timeToHit - interceptTime))
						interceptPos = interceptPos + (interceptPos - d.startPos):normalized() * xtraDistance
					end
					if interceptPos and GetDistanceSqr(interceptPos, d.startPos) < GetDistanceSqr(d.startPos, d.endPos) then
						return true, true, interceptPos
					end
				end
			end
			local timeToHit = delay + ((GetDistance(myPos, d.endPos) - missileOffset)/speed)
			if (d.endT - clock()) < timeToHit then
				dashPos = d.endPos
				canHit = (d.duration * (timeToHit - (d.endT - clock()))) < width
				if canHit and self.Wait[unit.networkID] then
					self.Wait[unit.networkID] = nil
				end
			end
		end
	end
	return isDashing, canHit, dashPos
end

function Pewdiction:CountWaypoints(NetworkID, from)
	local count = 0
	if self.WaypointHistory[NetworkID] then
		for i, waypoint in ipairs(self.WaypointHistory[NetworkID]) do
			if from <= waypoint.time then
				count = count+1
			end
		end
	end
	return count
end

function Pewdiction:AngleBetween(targetPos, castPos, from)
	local p1, p2 = (-targetPos + castPos), (-targetPos + from)

	local aV1 = atan(p1.z / p1.x)
	local aV2 = atan(p2.z / p2.x)
	
	aV1 = p1.x < 0 and aV1 + pi or aV1
	aV2 = p2.x < 0 and aV2 + pi or aV2
	local theta = aV1 - aV2
	theta = theta < 0 and theta + pi2 or theta
	theta = theta > pi and pi2 - theta or theta	
    return theta
end

function Pewdiction:GetCurrentWayPoints(object)
	local result = {}
	if object.hasMovePath then
		result[1] = Vector(object.pos.x, object.pos.y, object.pos.z)
		for i = object.pathIndex, object.pathCount do
			local p = object:GetPath(i)
			result[#result+1] = Vector(p.x, p.y, p.z)
		end
	else
		result[1] = Vector(object.pos.x, object.pos.y, object.pos.z)
	end
	return result
end

function Pewdiction:CalculateTargetPosition(unit, delay, width, speed, from, missileOffset)
	local Waypoints = self:GetCurrentWayPoints(unit)	
	local CastPosition = Vector(unit.pos.x, unit.pos.y, unit.pos.z)	
	local pathPotential = unit.ms * (((GetDistance(from, CastPosition) - missileOffset) / speed) + delay)
	
	if #Waypoints == 1 then
		CastPosition = Waypoints[1]
		return CastPosition, Waypoints
	else
		for i = 1, #Waypoints - 1 do
			local CurrentDistance = GetDistance(Waypoints[i], Waypoints[i + 1])
			if pathPotential < CurrentDistance then
				CastPosition = Waypoints[i] + (Waypoints[i + 1] - Waypoints[i]):normalized() * pathPotential
				break
			elseif i == (#Waypoints - 1) then
				CastPosition = Waypoints[i + 1]
			end
			pathPotential = pathPotential - CurrentDistance
		end	
	end
	return CastPosition, Waypoints
end

function Pewdiction:AnalyzeWaypoints(unit, delay, width, speed, from, missileOffset)
	local HitChance = 1
	local CastPosition, CurrentWayPoints
	local uID, uPos = unit.networkID, Vector(unit.pos.x, unit.pos.y, unit.pos.z)
	local SavedWayPoints = self.WaypointHistory[uID] or {}
	local TimeVisible = clock() - self.TargetsVisible[uID]
	local WPUpdateAverage = self:CountWaypoints(uID, TimeVisible) / TimeVisible
	local LastSecond = self:CountWaypoints(uID, clock() - 1)
	
	if GetDistanceSqr(from, uPos) < 62500 then
		HitChance = HitChance + 1
		CastPosition, CurrentWayPoints = self:CalculateTargetPosition(unit, delay*0.5, width, speed*2, from, missileOffset)
	else
		CastPosition, CurrentWayPoints = self:CalculateTargetPosition(unit, delay, width, speed, from, missileOffset)
	end

	if SavedWayPoints[#SavedWayPoints] and clock() - SavedWayPoints[#SavedWayPoints].time < 0.1 then																	
		HitChance = HitChance + 1
		if LastSecond < WPUpdateAverage then
			HitChance = HitChance + 1
		else
			HitChance = HitChance - 1
		end				
	else 
		if LastSecond < WPUpdateAverage then
			HitChance = HitChance + 1
		else
			HitChance = HitChance - 2
		end	
	end
	
	if CastPosition then
		local theta = self:AngleBetween(uPos, CastPosition, from)
		if theta > 1.31 and theta < 1.83 then
			HitChance = HitChance - 2
		elseif theta > 2.61 or theta < 0.52 then
			HitChance = HitChance + 1
		end
		if IsWall(D3DXVECTOR3(CastPosition.x, CastPosition.y, CastPosition.z)) then
			HitChance = HitChance - 2
		end
	end

	if #SavedWayPoints == 0 and TimeVisible > 5 then
		HitChance = HitChance + 3
	elseif self:CountWaypoints(uID, clock() - 0.1) > 0 or LastSecond == 1 then
		HitChance = HitChance + 1
	elseif #CurrentWayPoints <= 1 and TimeVisible > 2 then
		HitChance = HitChance + 1
	end

	if TimeVisible < 2 then
		HitChance = HitChance - 1
	elseif SavedWayPoints[#SavedWayPoints] then
		local AverageToCurrentDiff = WPUpdateAverage - (1 / (clock() - SavedWayPoints[#SavedWayPoints].time))
		if AverageToCurrentDiff > -2.5 then	--New WP expected
			HitChance = HitChance - 1
		elseif AverageToCurrentDiff > -1.5 then
			HitChance = HitChance - 2
		elseif AverageToCurrentDiff > -0.5 then
			HitChance = HitChance - 3
		end
	end

	if self:IsSlowed(unit, delay, speed, from, missileOffset) then
		HitChance = HitChance + 2
	elseif CastPosition and (width / unit.ms) >= (delay + ((GetDistance(from, CastPosition) - missileOffset) / speed)) then
		HitChance = HitChance + 2
	end

	if self.Wait[uID] and self.Wait[uID] > clock() then
		HitChance = 0
		CastPosition = uPos
	elseif not CastPosition then
		HitChance = 0
		CastPosition = CurrentWayPoints[#CurrentWayPoints]
	end
	return CastPosition, HitChance
end

function Pewdiction:GetBestCastPosition(unit, delay, width, range, speed, from, missileOffset)
	width = width + unit.boundingRadius
	delay = delay + 0.07 + (GetLatency() / 2000)
	
	local CastPosition, HitChance = Vector(unit.pos.x, unit.pos.y, unit.pos.z), 0

	if unit.type ~= 'AIHeroClient' then
		CastPosition = self:CalculateTargetPosition(unit, delay, width, speed, from, missileOffset)
		HitChance = 2
	else
		local isDashing, canHitDash, dashPos = self:IsDashing(unit, delay, width, speed, from, missileOffset)
		local isImmobile, immobilePos, immobileTime = self:IsImmobile(unit, delay, speed, from, missileOffset)
		if isDashing and canHitDash then
			HitChance = 4
			CastPosition = dashPos
		elseif isImmobile then
			CastPosition = immobilePos
			HitChance = 4
		else
			CastPosition, HitChance = self:AnalyzeWaypoints(unit, delay - immobileTime, width, speed, from, missileOffset)
		end
	end
	if not CastPosition or GetDistance(from, CastPosition) > range then -- not unit.isTargetable or
		HitChance = 0
	end
	return CastPosition, HitChance
end

function Pewdiction:MinionCollision(sPos, ePos, width, unit, delay, speed, missileOffset)
	unit = unit or myHero
	local collision = {}
	width = width+65
	local range = GetDistance(sPos, ePos)+65
	local real = sPos + (ePos - sPos):normalized() * range
	local theta = sPos-real
	local eP = real + Vector(-theta.z, theta.y, theta.x)
	local sP = sPos + Vector(-theta.z, theta.y, theta.x)
	local sL = sPos + (sPos-sP):normalized()*(-(width))
	local sR = sPos + (sPos-sP):normalized()*width
	local eR = real + (real-eP):normalized()*width
	local eL = real + (real-eP):normalized()*(-(width))
	local poly = Polygon(Point(sL.x, sL.z), Point(sR.x, sR.z), Point(eR.x, eR.z), Point(eL.x, eL.z))
	for _, minion in ipairs(self.Minions) do
		local minPos = Vector(minion.pos.x, minion.pos.y, minion.pos.z)
		if minion and minion ~= unit and GetDistance(minPos, sPos) <= (range*1.15) then
			if poly:contains(Point(minPos.x, minPos.z)) then
				collision[#collision + 1] = minion
			else
				local pPos = self:CalculateTargetPosition(minion, delay, width, speed, myHero.pos, missileOffset)
				if pPos and poly:contains(Point(pPos.x, pPos.z)) then
					collision[#collision + 1] = minion
				end
			end
		end
	end
	return #collision == 0, #collision, collision
end

function Pewdiction:HeroCollision(sPos, ePos, width, unit)
	unit = unit or myHero
	local collision = {}
	width = width+65
	local range = sPos:DistanceTo(ePos)
	local real = sPos:Lerp(ePos, (range + 65) / range)
	local theta = sPos-real
	local eP = real + Vector3(-theta.z, theta.y, theta.x)
	local sP = sPos + Vector3(-theta.z, theta.y, theta.x)
	local sL = sPos + (sPos-sP):Normalize()*(-(width))
	local sR = sPos + (sPos-sP):Normalize()*width
	local eR = real + (real-eP):Normalize()*width
	local eL = real + (real-eP):Normalize()*(-(width))
	local poly = Polygon()
	poly:Add(Point(sL.x, sL.z))
	poly:Add(Point(sR.x, sR.z))
	poly:Add(Point(eR.x, eR.z))
	poly:Add(Point(eL.x, eL.z))
	for _, hero in ipairs(self.Enemies) do
		local hPos = hero.pos
		if hero and hero ~= unit and hPos:DistanceTo(sPos) <= (range*1.15) then
			if Point(hPos.x, hPos.z):IsInside(poly) then
				collision[#collision + 1] = hero
			end
		end
	end
	return #collision == 0, #collision, collision
end

class 'Minions'

function Minions:__init()
	self.Objects = {}
	self.Others = {}
	for i = 0, objManager.maxObjects do
		if self:IsValid(objManager:getObject(i)) then
			insert(self.Objects, objManager:getObject(i))
		end
	end
	self.BadObjects = {
		['SRU_WallVisionBearer'] = true,
		['TestCubeRender'] = true,	
	}
	self.ToOthers = {
		['ZyraGraspingPlant'] = true,
		['ZyraThornPlant'] = true,
	}
	AddTickCallback(function() self:Tick() end)
	AddCreateObjCallback(function(o) self:CreateObj(o) end)
	AddDeleteObjCallback(function(o) self:DeleteObj(o) end)
	return self
end

function Minions:IsValid(o)
	return o and o.valid and not o.dead and o.type == 'obj_AI_Minion' and o.team ~= TEAM_ALLY and o.charName
end

function Minions:Tick()
	for i, o in ipairs(self.Objects) do
		if not self:IsValid(o) or self.BadObjects[o.charName] then
			remove(self.Objects, i)
			return
		elseif self.ToOthers[o.name] or o.name:lower():find('ward') then
			insert(self.Others, #self.Others+1, o)
			remove(self.Objects, i)
			return			
		end
	end
	for i, o in ipairs(self.Others) do
		if not self:IsValid(o) then
			remove(self.Others, i)
			return
		end
	end
end

function Minions:CreateObj(o)
	if self:IsValid(o) then
		insert(self.Objects, #self.Objects + 1, o)
	end
end

function Minions:DeleteObj(o)
	if o.valid then
		for i, m in ipairs(self.Objects) do
			if m.networkID == o.networkID then
				remove(self.Objects, i)
				return
			end
		end
	end
end

class 'Buffs'

function Buffs:__init()
	self.Buffs = {}
	self.Enemies = GetEnemyHeroes()
	for _, hero in ipairs(self.Enemies) do
		self.Buffs[hero.networkID] = {}
	end
	AddApplyBuffCallback(function(source, unit, buff) self:ApplyBuff(source, unit, buff) end)
	AddRemoveBuffCallback(function(unit, buff) self:RemoveBuff(unit, buff) end)
	AddTickCallback(function() self:Tick() end) --Remove when buff callbacks are working
	return self
end

function Buffs:Tick()
	for _, hero in pairs(self.Enemies) do
		for i=1, 64 do
			local b = hero:getBuff(i)
			if b and b.valid then
				if b.endT < clock() then
					self.Buffs[hero.networkID][b.name:lower()] = {
					['type']     = b.type,
					['endT']     = b.endT,
					['startT']   = b.startT,
					['duration'] = b.endT - b.startT,
					}
				elseif self.Buffs[hero.networkID][b.name:lower()] then
					self.Buffs[hero.networkID][b.name:lower()] = nil
				end
			end
		end
	end
end

function Buffs:ApplyBuff(source, unit, buff)
	if unit.valid and unit.type == 'AIHeroClient' then
		self.Buffs[unit.networkID][buff.name:lower()] = {
			['type']     = buff.type,
			['endT']     = buff.endTime,
			['startT']   = buff.startTime,
			['duration'] = buff.endTime - buff.startTime,
		}
	end
end

function Buffs:RemoveBuff(unit, buff)
	if unit.valid and unit.type == 'AIHeroClient' then
		if self.Buffs[unit.networkID][buff.name:lower()] then
			self.Buffs[unit.networkID][buff.name:lower()] = nil
		end
	end
end
