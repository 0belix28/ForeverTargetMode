-- ForeverTargetMode : indique en combat si on est en mono-cible ou en multi-cibles.
-- Comptage : ennemis visibles (barres d'info / nameplates) qui sont en combat
-- contre toi ou ton groupe. Les barres d'info ennemies doivent être activées (touche V).
local ADDON, ns = ...

local DEFAULTS = {
    enabled = true,
    locked = true,
    threshold = 2,     -- nombre d'ennemis à partir duquel on passe en "multi"
    scale = 1.0,
    showCount = true,  -- afficher le nombre d'ennemis
    point = { "CENTER", "UIParent", "CENTER", 0, 180 },
}

local PREFIX = "|cff33ccffForeverTargetMode|r : "
local function Print(msg) DEFAULT_CHAT_FRAME:AddMessage(PREFIX .. msg) end

local function Version()
    local get = (C_AddOns and C_AddOns.GetAddOnMetadata) or GetAddOnMetadata
    return (get and get(ADDON, "Version")) or "?"
end

-- Appel protégé : renvoie nil si l'appel échoue ou si la valeur est "secrète".
local function Safe(fn, ...)
    if not fn then return nil end
    local ok, v = pcall(fn, ...)
    if not ok then return nil end
    if issecretvalue and issecretvalue(v) then return nil end
    return v
end

local function IsGroupUnit(unit)
    if Safe(UnitIsUnit, unit, "player") or Safe(UnitIsUnit, unit, "pet") then return true end
    if Safe(UnitInParty, unit) or Safe(UnitInRaid, unit) then return true end
    return false
end

-- Cet ennemi se bat-il contre nous / notre groupe ?
local function IsEngagedEnemy(unit)
    if not Safe(UnitExists, unit) then return false end
    if Safe(UnitIsDeadOrGhost, unit) then return false end
    if not Safe(UnitCanAttack, "player", unit) then return false end
    local inCombat = Safe(UnitAffectingCombat, unit)
    if inCombat == false then return false end

    -- Sur notre table de menace ?
    local ok, threat = pcall(UnitThreatSituation, "player", unit)
    if ok and issecretvalue and issecretvalue(threat) then
        -- Menace illisible (valeur secrète) : un ennemi en combat est compté.
        return inCombat ~= false
    end
    if ok and threat ~= nil then return true end
    -- Cible quelqu'un de notre groupe ?
    local tgt = unit .. "target"
    if Safe(UnitExists, tgt) and IsGroupUnit(tgt) then return true end
    return false
end

local function CountEnemies()
    local n = 0
    local plates = (C_NamePlate and C_NamePlate.GetNamePlates and C_NamePlate.GetNamePlates()) or {}
    for _, plate in ipairs(plates) do
        local unit = plate.namePlateUnitToken or (plate.UnitFrame and plate.UnitFrame.unit)
        if unit and IsEngagedEnemy(unit) then n = n + 1 end
    end
    -- Sans barres d'info, on compte au moins la cible actuelle.
    if n == 0 and Safe(UnitExists, "target") and Safe(UnitCanAttack, "player", "target")
        and not Safe(UnitIsDeadOrGhost, "target") then
        n = 1
    end
    return n
end

----------------------------------------------------------------------
-- Affichage
----------------------------------------------------------------------
local frame = CreateFrame("Frame", "ForeverTargetModeFrame", UIParent)
frame:SetSize(280, 44)
frame:SetMovable(true)
frame:SetClampedToScreen(true)
frame:RegisterForDrag("LeftButton")
frame:Hide()

local bg = frame:CreateTexture(nil, "BACKGROUND")
bg:SetAllPoints()
bg:SetColorTexture(0, 0, 0, 0.5)
bg:Hide()

local text = frame:CreateFontString(nil, "OVERLAY")
text:SetFont(STANDARD_TEXT_FONT, 24, "THICKOUTLINE")
text:SetPoint("CENTER")

frame:SetScript("OnDragStart", function(self) if not ns.db.locked then self:StartMoving() end end)
frame:SetScript("OnDragStop", function(self)
    self:StopMovingOrSizing()
    local p, _, rp, x, y = self:GetPoint()
    ns.db.point = { p, "UIParent", rp, x, y }
end)

local function ApplyLayout()
    local db = ns.db
    local p = db.point
    frame:ClearAllPoints()
    frame:SetPoint(p[1], UIParent, p[3], p[4], p[5])
    frame:SetScale(db.scale)
    frame:EnableMouse(not db.locked)
    bg:SetShown(not db.locked)
end

local lastText
local function Render(count)
    local db = ns.db
    local s
    if count >= db.threshold then
        s = "|cffff4020MULTI TARGET|r"
        if db.showCount then s = s .. " |cffffffff(" .. count .. ")|r" end
    else
        s = "|cff40ff40SINGLE TARGET|r"
    end
    if s ~= lastText then
        text:SetText(s)
        lastText = s
    end
end

local inCombat = false
local acc = 0
frame:SetScript("OnUpdate", function(_, elapsed)
    if not inCombat then return end
    acc = acc + elapsed
    if acc < 0.25 then return end
    acc = 0
    Render(CountEnemies())
end)

local function Refresh()
    lastText = nil
    if not ns.db.enabled then frame:Hide() return end
    if inCombat then
        Render(CountEnemies())
        frame:Show()
    elseif ns.db.locked then
        frame:Hide()
    else
        text:SetText("|cff33ccffForeverTargetMode|r |cffaaaaaa(glisser)|r")
        frame:Show()
    end
end

----------------------------------------------------------------------
-- Événements
----------------------------------------------------------------------
local ev = CreateFrame("Frame")
ev:RegisterEvent("ADDON_LOADED")
ev:RegisterEvent("PLAYER_REGEN_DISABLED")
ev:RegisterEvent("PLAYER_REGEN_ENABLED")
ev:RegisterEvent("PLAYER_ENTERING_WORLD")
ev:SetScript("OnEvent", function(_, event, arg1)
    if event == "ADDON_LOADED" then
        if arg1 ~= ADDON then return end
        ForeverTargetModeDB = ForeverTargetModeDB or {}
        for k, v in pairs(DEFAULTS) do
            if ForeverTargetModeDB[k] == nil then
                ForeverTargetModeDB[k] = type(v) == "table" and CopyTable(v) or v
            end
        end
        ns.db = ForeverTargetModeDB
        ApplyLayout()
        return
    end
    if not ns.db then return end
    if event == "PLAYER_REGEN_DISABLED" then
        inCombat = true
    elseif event == "PLAYER_REGEN_ENABLED" then
        inCombat = false
    elseif event == "PLAYER_ENTERING_WORLD" then
        inCombat = InCombatLockdown() and true or false
    end
    Refresh()
end)

----------------------------------------------------------------------
-- Commandes
----------------------------------------------------------------------
local function Help()
    Print("v" .. Version() .. " - commandes :")
    Print("/ftm - ouvrir le panneau d'options")
    Print("/ftm unlock - déverrouiller pour déplacer le texte")
    Print("/ftm lock - verrouiller la position")
    Print("/ftm seuil <n> - ennemis nécessaires pour MULTI (actuel : " .. ns.db.threshold .. ")")
    Print("/ftm scale <0.5-3> - taille du texte (actuel : " .. ns.db.scale .. ")")
    Print("/ftm count - afficher / masquer le nombre d'ennemis")
    Print("/ftm toggle - activer / désactiver l'addon")
    Print("/ftm reset - remettre la position par défaut")
end

SLASH_FOREVERTARGETMODE1 = "/ftm"
SlashCmdList.FOREVERTARGETMODE = function(msg)
    local db = ns.db
    local cmd, arg = strsplit(" ", strtrim(msg or ""):lower(), 2)
    if cmd == "unlock" then
        db.locked = false; ApplyLayout(); Refresh()
        Print("déverrouillé : fais glisser le texte, puis /ftm lock.")
    elseif cmd == "lock" then
        db.locked = true; ApplyLayout(); Refresh()
        Print("verrouillé.")
    elseif cmd == "seuil" or cmd == "threshold" then
        local n = tonumber(arg)
        if n and n >= 2 then
            db.threshold = math.floor(n)
            Print("MULTI à partir de " .. db.threshold .. " ennemis.")
        else
            Print("valeur invalide (2 minimum).")
        end
    elseif cmd == "scale" then
        local n = tonumber(arg)
        if n and n >= 0.5 and n <= 3 then
            db.scale = n; ApplyLayout()
            Print("taille : " .. n)
        else
            Print("valeur invalide (0.5 à 3).")
        end
    elseif cmd == "count" then
        db.showCount = not db.showCount; lastText = nil
        Print("nombre d'ennemis " .. (db.showCount and "affiché." or "masqué."))
    elseif cmd == "toggle" then
        db.enabled = not db.enabled; Refresh()
        Print(db.enabled and "|cff40ff40activé|r" or "|cffff4020désactivé|r")
    elseif cmd == "reset" then
        db.point = CopyTable(DEFAULTS.point); db.scale = DEFAULTS.scale; ApplyLayout()
        Print("position réinitialisée.")
    elseif cmd == "" or cmd == "options" or cmd == "config" then
        if ForeverTargetMode_OpenOptions then ForeverTargetMode_OpenOptions() end
    else
        Help()
    end
    if ns.RefreshOptions then ns.RefreshOptions() end
end

function ForeverTargetMode_OnCompartmentClick()
    if ForeverTargetMode_OpenOptions then ForeverTargetMode_OpenOptions() end
end

-- Accès pour Options.lua
ns.DEFAULTS = DEFAULTS
ns.Print = Print
ns.Version = Version
ns.ApplyLayout = ApplyLayout
ns.Refresh = Refresh
ns.Help = Help
function ns.ResetText() lastText = nil end
