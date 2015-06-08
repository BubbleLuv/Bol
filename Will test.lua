if myHero.charName ~= "Caitlyn" then
  return
end
local Author = "BubbleLuv"
local Version = 1.0
local _b = "1.0"
local ab = false
local bb = "raw.github.com"
local cb = "/BubbleLuv/Bol/Bubbling MarskMan.lua" .. "?rand=" .. math.random(1, 10000)
local db = SCRIPT_PATH .. FILE_NAME
local _c = "https://" .. bb .. cb
function AutoupdaterMsg(dc)
	PrintChat("<font color=\"#FFFF00\">Bubbling Marksman đã tải dữ liệu xong với nhân vật <font color=\"#FF0000\">Caitlyn")
end
if ab then
  local dc = GetWebResult(bb, "/BubbleLuv/Bol/ADCversion.lua")
  if dc then
    ServerVersion = type(tonumber(dc)) == "number" and tonumber(dc) or nil
    if ServerVersion and tonumber(_b) < ServerVersion then
      AutoupdaterMsg("New version available: v" .. ServerVersion)
      AutoupdaterMsg("Updating, please don't press F9")
      DelayAction(function()
        DownloadFile(_c, db, function()
          AutoupdaterMsg("Cập nhật thành công(" .. _b .. " => " .. ServerVersion .. ")Hãy bấm F9 2 lần để load lại script với phiên bản mới nhất")
        end)
      end, 3)
    else
    end
  else
    AutoupdaterMsg("Cập nhật phiên bản mới thất bại")
  end
end
local ac
GapCloserList = {
  Ahri = {true, spell = "AhriTumble"},
  Aatrox = {true, spell = "AatroxQ"},
  Akali = {
    true,
    spell = "AkaliShadowDance"
  },
  Alistar = {true, spell = "Headbutt"},
  Corki = {true, spell = "CarpetBomb"},
  Diana = {
    true,
    spell = "DianaTeleport"
  },
  Elise = {
    true,
    spell = "EliseSpiderQCast"
  },
  Fiora = {true, spell = "FioraQ"},
  Fizz = {
    true,
    spell = "FizzPiercingStrike"
  },
  Gnar = {true, spell = "GnarE"},
  Gragas = {true, spell = "GragasE"},
  Graves = {true, spell = "GravesMove"},
  Hecarim = {true, spell = "HecarimUlt"},
  Irelia = {
    true,
    spell = "IreliaGatotsu"
  },
  JarvanIV = {
    true,
    spell = "jarvanAddition"
  },
  Jax = {
    true,
    spell = "JaxLeapStrike"
  },
  Jayce = {
    true,
    spell = "JayceToTheSkies"
  },
  Kassadin = {true, spell = "RiftWalk"},
  Khazix = {true, spell = "KhazixW"},
  Leblanc = {
    true,
    spell = "LeblancSlide"
  },
  LeeSin = {
    true,
    spell = "blindmonkqtwo"
  },
  Leona = {
    true,
    spell = "LeonaZenithBlade",
    range = 900,
    projSpeed = 2000
  },
  Lucian = {true, spell = "LucianE"},
  Malphite = {true, spell = "UFSlash"},
  Maokai = {
    true,
    spell = "MaokaiTrunkLine"
  },
  MasterYi = {
    true,
    spell = "AlphaStrike"
  },
  MonkeyKing = {
    true,
    spell = "MonkeyKingNimbus"
  },
  Nidalee = {true, spell = "Pounce"},
  Pantheon = {true, spell = "PantheonW"},
  Pantheon = {
    true,
    spell = "PantheonRJump"
  },
  Pantheon = {
    true,
    spell = "PantheonRFall"
  },
  Poppy = {
    true,
    spell = "PoppyHeroicCharge"
  },
  Rammus = {true, spell = "PowerBall"},
  Renekton = {
    true,
    spell = "RenektonSliceAndDice"
  },
  Riven = {true, spell = "RivenFeint"},
  Sejuani = {
    true,
    spell = "SejuaniArcticAssault"
  },
  Shyvana = {
    true,
    spell = "ShyvanaTransformCast"
  },
  Shen = {
    true,
    spell = "ShenShadowDash"
  },
  Talon = {
    true,
    spell = "TalonCutthroat"
  },
  Tristana = {true, spell = "RocketJump"},
  Tryndamere = {true, spell = "Slash"},
  Vi = {true, spell = "ViQ"},
  XinZhao = {
    true,
    spell = "XenZhaoSweep"
  },
  Yasuo = {
    true,
    spell = "YasuoDashWrapper"
  }
}
local bc = {
  AA = myHero.range
}
local cc = {
  SkillQ = {
    range = 1150,
    width = 90,
    speed = 2200,
    delay = 0.25
  },
  SkillW = {
    range = 800,
    width = 0,
    speed = 1400,
    delay = 0
  },
  SkillE = {
    range = 950,
    width = 80,
    speed = 2000,
    delay = 0.25
  },
  SkillR = {
    range = 2500,
    width = 0,
    speed = 1500,
    delay = 0
  }
}
function GetCustomTarget()
  ts:update()
  if _G.MMA_GameFileNotification ~= nil and ValidTarget(_G.MMA_Target) then
    return _G.MMA_ConsideredTarget(1100)
  end
  if _G.AutoCarry and ValidTarget(_G.AutoCarry.Crosshair:GetTarget()) then
    _G.AutoCarry.Crosshair:SetSkillCrosshairRange(1100)
    return _G.AutoCarry.Crosshair:GetTarget()
  end
  if _G.MMA_GameFileNotification == nil and not _G.Reborn_Loaded then
    return ts.target
  end
  return ts.target
end
function OnLoad()
	PrintChat("<font color=\"#FFFF00\">Bubbling Marksman đã tải dữ liệu xong với nhân vật <font color=\"#FF0000\">Caitlyn")
  if _G.MMA_GameFileNotification == nil and not _G.Reborn_Loaded then
    require("SxOrbWalk")
  end
  require("VPrediction")
  require("DivinePred")
  
  Config = scriptConfig("Bubbling MarskMan", "Caitlyn")
  Config:addSubMenu("[CIS] Key Bindings", "KeyBindings")
  Config.KeyBindings:addParam("ComboActive", "Combo Key", SCRIPT_PARAM_ONKEYDOWN, false, 32)
  Config.KeyBindings:addParam("HarassActive", "Harass Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("C"))
  Config.KeyBindings:addParam("ClearActive", "Lane/Jungleclear Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("V"))
  Config.KeyBindings:addParam("UltiActive", "Ultimate Auto Select Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("R"))
  Config.KeyBindings:addParam("EToMouseActive", "E To Mouse Key", SCRIPT_PARAM_ONKEYDOWN, false, GetKey("G"))
  Config:addSubMenu("[CIS] Combo Settings", "CSet")
  Config.CSet:addSubMenu("Q Settings", "QSet")
  Config.CSet.QSet:addParam("UseQ", "Use Q in 'Combo'", SCRIPT_PARAM_ONOFF, true)
  Config.CSet.QSet:addParam("MinQ", "Minimum Q Range", SCRIPT_PARAM_SLICE, 650, 0, 1200, 0)
  Config.CSet:addSubMenu("W Settings", "WSet")
  Config.CSet.WSet:addParam("UseW", "Use W in 'Combo'", SCRIPT_PARAM_ONOFF, true)
  Config.CSet.WSet:addParam("AutoWCC", "Auto W on 'CC'", SCRIPT_PARAM_ONOFF, true)
  Config.CSet:addSubMenu("E Settings", "ESet")
  Config.CSet.ESet:addParam("AutoEGC", "Auto E on 'Gapcloser'", SCRIPT_PARAM_ONOFF, true)
  Config.CSet:addSubMenu("R Settings", "RSet")
  Config.CSet.RSet:addParam("UseR", "Auto Select Target with R", SCRIPT_PARAM_ONOFF, true)
  Config:addSubMenu("[CIS] Harass Settings", "HSet")
  Config.HSet:addParam("UseQ", "Use Q in 'Harass'", SCRIPT_PARAM_ONOFF, true)
  Config:addSubMenu("[CIS] Laneclear Settings", "LSet")
  Config.LSet:addParam("UseQ", "Use Q in 'Laneclear'", SCRIPT_PARAM_ONOFF, false)
  Config.LSet:addParam("ManaManager", "Do not use Q under % (mana)", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
  Config:addSubMenu("[CIS] Jungleclear Settings", "JSet")
  Config.JSet:addParam("UseQ", "Use Q in 'Jungleclear'", SCRIPT_PARAM_ONOFF, true)
  Config.JSet:addParam("ManaManager", "Do not use Q under % (mana)", SCRIPT_PARAM_SLICE, 40, 0, 100, 0)
  if _G.MMA_GameFileNotification == nil and not _G.Reborn_Loaded then
    Config:addSubMenu("[CIS] Item Settings", "ISet")
    Config.ISet:addSubMenu("BotRK Settings", "Botrk")
    Config.ISet.Botrk:addParam("UseBotrk", "Use Botrk", SCRIPT_PARAM_ONOFF, true)
    Config.ISet.Botrk:addParam("MaxOwnHealth", "Max Own Health Percent", SCRIPT_PARAM_SLICE, 50, 1, 100, 0)
    Config.ISet.Botrk:addParam("MinEnemyHealth", "Min Enemy Health Percent", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Config.ISet:addSubMenu("Bilgewater Settings", "Bilgewater")
    Config.ISet.Bilgewater:addParam("UseBilgewater", "Use Bilgewater", SCRIPT_PARAM_ONOFF, true)
    Config.ISet.Bilgewater:addParam("MaxOwnHealth", "Max Own Health Percent", SCRIPT_PARAM_SLICE, 80, 1, 100, 0)
    Config.ISet.Bilgewater:addParam("MinEnemyHealth", "Min Enemy Health Percent", SCRIPT_PARAM_SLICE, 20, 1, 100, 0)
    Config.ISet:addSubMenu("Youmuu Settings", "Youmuu")
    Config.ISet.Youmuu:addParam("UseYoumuu", "Use Youmuu", SCRIPT_PARAM_ONOFF, true)
  end
  Config:addSubMenu("[CIS] KS Settings", "KSet")
  Config.KSet:addParam("KSTQ", "KS with Q", SCRIPT_PARAM_ONOFF, true)
  Config.KSet:addParam("KSTE", "KS with E", SCRIPT_PARAM_ONOFF, false)
  Config:addSubMenu("[CIS] Draw Settings", "DSet")
  Config.DSet:addParam("LowFps", "Lag Free Circles", SCRIPT_PARAM_ONOFF, true)
  Config.DSet:addParam("DrawKill", "Draw R Killable Target", SCRIPT_PARAM_ONOFF, true)
  Config:addSubMenu("[CIS] Target Selector", "TSet")
  Config:addParam("pred", "Cast Skill ", SCRIPT_PARAM_LIST, 1, {"DivinePred", "VPrediction")

  Config:addParam("packets", "Only vip Packet Usage", SCRIPT_PARAM_ONOFF, true)
  Config:addParam("Author", "Author", SCRIPT_PARAM_INFO, Author)
  Config:addParam("Version", "Version", SCRIPT_PARAM_INFO, version)
  Config:addParam("Dayupdate", "Dayupdate", SCRIPT_PARAM_INFO, Dayupdate)




  end
  ac = VPrediction()
  ts = TargetSelector(TARGET_LESS_CAST_PRIORITY, 1100, DAMAGE_PHYSICAL)
  ts.name = "Focus"
  Config.TSet:addTS(ts)
  if _G.MMA_GameFileNotification ~= nil then
    PrintChat("<font color = \"#FFFFFF\">[Caitlyn] </font><font color = \"#FF0000\">MMA Status:</font> <font color = \"#FFFFFF\">Successfully integrated.</font> </font>")
    Config:addParam("MMAON", "[CIS] MMA support is active.", 5, "")
  elseif _G.Reborn_Loaded then
    PrintChat("<font color = \"#FFFFFF\">[Caitlyn] </font><font color = \"#FF0000\">SAC Status:</font> <font color = \"#FFFFFF\">Successfully integrated.</font> </font>")
    Config:addParam("SACON", "[CIS] SAC:R support is active.", 5, "")
  else
    PrintChat("<font color = \"#FFFFFF\">[Caitlyn] </font><font color = \"#FF0000\">Orbwalker not found:</font> <font color = \"#FFFFFF\">SxOrbWalk integrated.</font> </font>")
    Config:addSubMenu("[CIS] Orbwalker", "SxOrb")
    SxOrb:LoadToMenu(Config.SxOrb)
  end
  Minions = minionManager(MINION_ENEMY, 1000, myHero, MINION_SORT_MAXHEALTH_ASC)
  JMinions = minionManager(MINION_JUNGLE, 1000, myHero, MINION_SORT_MAXHEALTH_DEC)
end
function OnTick()
  Target = GetCustomTarget()
  QREADY = myHero:CanUseSpell(_Q) == READY
  WREADY = myHero:CanUseSpell(_W) == READY
  EREADY = myHero:CanUseSpell(_E) == READY
  RREADY = myHero:CanUseSpell(_R) == READY
  if Config.KeyBindings.ComboActive and Config.CSet.QSet.UseQ and ValidTarget(Target) and GetDistance(Target) <= cc.SkillQ.range and GetDistance(Target) > Config.CSet.QSet.MinQ and CanMove() then
    CastQ(Target)
  end
  if Config.KeyBindings.HarassActive and Config.HSet.UseQ and ValidTarget(Target) and GetDistance(Target) <= cc.SkillQ.range and CanMove() then
    CastQ(Target)
  end
  if Config.KeyBindings.ClearActive then
    Laneclear()
    Jungleclear()
  end
  if Config.KeyBindings.UltiActive then
    CastR()
  end
  if Config.KeyBindings.EToMouseActive then
    EToMouse()
  end
  KS()
  AutoTrap()
end
function OnDraw()
  if Config.DSet.DrawQ then
    if Config.DSet.LowFps then
      DrawCircleAdv(myHero.x, myHero.y, myHero.z, cc.SkillQ.range, ARGB(255, 0, 255, 255))
    else
      DrawCircle(myHero.x, myHero.y, myHero.z, cc.SkillQ.range, ARGB(255, 0, 255, 255))
    end
  end
  if Config.DSet.DrawE then
    if Config.DSet.LowFps then
      DrawCircleAdv(myHero.x, myHero.y, myHero.z, cc.SkillE.range, ARGB(255, 0, 255, 255))
    else
      DrawCircle(myHero.x, myHero.y, myHero.z, cc.SkillE.range, ARGB(255, 0, 255, 255))
    end
  end
  if Config.DSet.DrawR then
    DrawCircleMinimap(myHero.x, myHero.y, myHero.z, SkillRrange())
  end
  if Config.DSet.DrawKill then
    for dc, _d in pairs(GetEnemyHeroes()) do
      if ValidTarget(_d) then
        local ad = getDmg("R", _d, myHero)
        if ad > _d.health and RREADY and _d.visible and not _d.dead then
          local bd = WorldToScreen(D3DXVECTOR3(_d.x, _d.y, _d.z))
          DrawText("Press 'R' To Kill!", 25, bd.x, bd.y, RGB(255, 255, 0))
        end
      end
    end
  end
end
function SkillRrange()
  if myHero:GetSpellData(_R).level == 0 then
    return 0
  end
  if myHero:GetSpellData(_R).level == 1 then
    return 2000
  end
  if myHero:GetSpellData(_R).level == 2 then
    return 2500
  end
  if myHero:GetSpellData(_R).level == 3 then
    return 3000
  end
end
function DrawCircleNextLvl(dc, _d, ad, bd, cd, dd, __a)
  bd = bd or 300
  quality = math.max(8, round(180 / math.deg((math.asin(__a / (2 * bd))))))
  quality = 2 * math.pi / quality
  bd = bd * 0.92
  local a_a = {}
  for theta = 0, 2 * math.pi + quality, quality do
    local b_a = WorldToScreen(D3DXVECTOR3(dc + bd * math.cos(theta), _d, ad - bd * math.sin(theta)))
    a_a[#a_a + 1] = D3DXVECTOR2(b_a.x, b_a.y)
  end
  DrawLines2(a_a, cd or 1, dd or 4294967295)
end
function round(dc)
  if dc >= 0 then
    return math.floor(dc + 0.5)
  else
    return math.ceil(dc - 0.5)
  end
end
function DrawCircleAdv(dc, _d, ad, bd, cd)
  local dd = Vector(dc, _d, ad)
  local __a = Vector(cameraPos.x, cameraPos.y, cameraPos.z)
  local a_a = dd - (dd - __a):normalized() * bd
  local b_a = WorldToScreen(D3DXVECTOR3(a_a.x, a_a.y, a_a.z))
  if OnScreen({
    x = b_a.x,
    y = b_a.y
  }, {
    x = b_a.x,
    y = b_a.y
  }) then
    DrawCircleNextLvl(dc, _d, ad, bd, 1, cd, 100)
  end
end
function EToMouse()
  myHero:MoveTo(mousePos.x, mousePos.z)
  local dc = Vector(mousePos.x, mousePos.y, mousePos.z)
  local _d = Vector(myHero.x, myHero.y, myHero.z)
  local ad = _d + (_d - dc) * (500 / GetDistance(mousePos))
  local bd = _d + -1 * (Vector(_d.x - dc.x, _d.y - dc.y, _d.z - dc.z):normalized() * 495)
  if not IsWall(D3DXVECTOR3(bd.x, bd.y, bd.z)) then
    CastSpell(_E, ad.x, ad.z)
  end
end
function CastQ(dc)
  local _d, ad, bd = ac:GetLineAOECastPosition(dc, cc.SkillQ.delay, cc.SkillQ.width, cc.SkillQ.range, cc.SkillQ.speed, myHero, false)
  if ad >= 2 and bd >= 1 then
    if VIP_USER and Config.packets then
      Packet("S_CAST", {
        spellId = _Q,
        fromX = _d.x,
        fromY = _d.z,
        toX = _d.x,
        toY = _d.z
      }):send()
    elseif not VIP_USER or not Config.packets then
      CastSpell(_Q, _d.x, _d.z)
    end
  end
end
function CastR()
  for dc, _d in pairs(GetEnemyHeroes()) do
    local ad = getDmg("R", _d, myHero)
    if ValidTarget(_d) and GetDistance(_d) <= SkillRrange() and ad > _d.health and RREADY then
      if VIP_USER and Config.packets then
        Packet("S_CAST", {
          spellId = _R,
          targetNetworkId = _d.networkID
        }):send()
      elseif not VIP_USER or not Config.packets then
        CastSpell(_R, _d)
      end
    end
  end
end
function AutoTrap()
  for dc, _d in ipairs(GetEnemyHeroes()) do
    if not _d.dead and ValidTarget(_d) and GetDistance(_d) < cc.SkillW.range and Config.CSet.WSet.AutoWCC then
      local ad, bd = ac:IsImmobile(_d, cc.SkillW.delay, cc.SkillW.width, cc.SkillW.speed, myHero)
      if ad and GetDistance(bd) < cc.SkillW.range and WREADY then
        if VIP_USER and Config.packets then
          Packet("S_CAST", {
            spellId = _W,
            fromX = bd.x,
            fromY = bd.z,
            toX = bd.x,
            toY = bd.z
          }):send()
        elseif not VIP_USER or not Config.packets then
          CastSpell(_W, bd.x, bd.z)
        end
      end
    end
  end
end
function KS()
  for dc, _d in pairs(GetEnemyHeroes()) do
    if ValidTarget(_d) and not _d.dead then
      local ad = getDmg("Q", _d, myHero)
      local bd = getDmg("E", _d, myHero)
      if Config.KSet.KSTQ and ad > _d.health then
        local cd, dd, __a = ac:GetLineCastPosition(_d, cc.SkillQ.delay, cc.SkillQ.width, cc.SkillQ.range, cc.SkillQ.speed, myHero, true)
        if dd >= 2 and GetDistance(cd) <= cc.SkillQ.range then
          if VIP_USER and Config.packets then
            Packet("S_CAST", {
              spellId = _Q,
              fromX = cd.x,
              fromY = cd.z,
              toX = cd.x,
              toY = cd.z
            }):send()
          elseif not VIP_USER or not Config.packets then
            CastSpell(_Q, cd.x, cd.z)
          end
        end
      end
      if Config.KSet.KSTE and bd > _d.health then
        local cd, dd, __a = ac:GetLineCastPosition(_d, cc.SkillE.delay, cc.SkillE.width, cc.SkillE.range - 100, cc.SkillE.speed, myHero, true)
        if dd >= 2 and GetDistance(cd) <= cc.SkillE.range then
          if VIP_USER and Config.packets then
            Packet("S_CAST", {
              spellId = _E,
              fromX = cd.x,
              fromY = cd.z,
              toX = cd.x,
              toY = cd.z
            }):send()
          elseif not VIP_USER or not Config.packets then
            CastSpell(_E, cd.x, cd.z)
          end
        end
      end
    end
  end
end
function Laneclear()
  Minions:update()
  for dc, _d in pairs(Minions.objects) do
    if ValidTarget(_d) and _d ~= nil and Config.LSet.UseQ and GetDistance(_d) <= cc.SkillQ.range and myHero.mana / myHero.maxMana > Config.LSet.ManaManager / 100 then
      local ad, bd = GetBestLineFarmPosition(cc.SkillQ.range, cc.SkillQ.width, Minions.objects)
      if ad ~= nil then
        if VIP_USER and Config.packets then
          Packet("S_CAST", {
            spellId = _Q,
            fromX = ad.x,
            fromY = ad.z,
            toX = ad.x,
            toY = ad.z
          }):send()
        elseif not VIP_USER or not Config.packets then
          CastSpell(_Q, ad.x, ad.z)
        end
      end
    end
  end
end
function Jungleclear()
  JMinions:update()
  for dc, _d in pairs(JMinions.objects) do
    if ValidTarget(_d) and _d ~= nil and Config.JSet.UseQ and GetDistance(_d) <= cc.SkillQ.range and myHero.mana / myHero.maxMana > Config.JSet.ManaManager / 100 then
      local ad, bd = GetBestLineFarmPosition(cc.SkillQ.range, cc.SkillQ.width, JMinions.objects)
      if ad ~= nil then
        if VIP_USER and Config.packets then
          Packet("S_CAST", {
            spellId = _Q,
            fromX = ad.x,
            fromY = ad.z,
            toX = ad.x,
            toY = ad.z
          }):send()
        elseif not VIP_USER or not Config.packets then
          CastSpell(_Q, ad.x, ad.z)
        end
      end
    end
  end
end
function GetBestLineFarmPosition(dc, _d, ad)
  local bd
  local cd = 0
  for dd, __a in ipairs(ad) do
    local a_a = Vector(myHero.visionPos) + dc * (Vector(__a) - Vector(myHero.visionPos)):normalized()
    local b_a = CountObjectsOnLineSegment(myHero.visionPos, a_a, _d, ad)
    if cd < b_a then
      cd = b_a
      bd = Vector(__a)
    end
    if cd ~= #ad then
    end
  end
  return bd, cd
end
function CountObjectsOnLineSegment(dc, _d, ad, bd)
  local cd = 0
  for dd, __a in ipairs(bd) do
    local a_a, b_a, c_a = VectorPointProjectionOnLineSegment(dc, _d, __a)
    if c_a and GetDistanceSqr(a_a, __a) < ad * ad then
      cd = cd + 1
    end
  end
  return cd
end
function CanMove()
  if _G.MMA_GameFileNotification ~= nil then
    return _G.MMA_AbleToMove
  elseif _G.AutoCarry then
    return _G.AutoCarry.CanMove
  else
    return SxOrb:CanMove()
  end
end
function OnProcessSpell(dc, _d)
  if Config.CSet.ESet.AutoEGC and EREADY and dc.team ~= myHero.team then
    local ad = _d.name
    if GapCloserList[dc.charName] and ad == GapCloserList[dc.charName].spell and GetDistance(dc) < 2000 and (_d.target ~= nil and _d.target.name == myHero.name or GapCloserList[dc.charName].spell == "blindmonkqtwo") then
      if VIP_USER and Config.packets then
        Packet("S_CAST", {
          spellId = _E,
          fromX = _d.endPos.x,
          fromY = _d.endPos.z,
          toX = _d.endPos.x,
          toY = _d.endPos.z
        }):send()
      elseif not VIP_USER or not Config.packets then
        CastSpell(_E, _d.endPos.x, _d.endPos.z)
      end
    end
  end
end
