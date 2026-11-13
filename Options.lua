-- ForeverTargetMode - Panneau du menu Options (Échap > Options > AddOns)
-- Même direction artistique que ForeverEgo / ForeverTchatBell : logo + titre doré, encadrés à bord doré.
local ADDON, ns = ...

local LOGO = "Interface\\AddOns\\ForeverTargetMode\\Media\\Logo"
local TITLE_FONT = "Fonts\\MORPHEUS.TTF"
local GOLD_R, GOLD_G, GOLD_B = 1, 0.82, 0
local ROW_H = 24
local LABEL_W = 220

local panel = CreateFrame("Frame")
panel.name = "ForeverTargetMode"
panel:Hide()

local ui = {}

local function Tooltip(widget, title, text)
    widget:SetScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        GameTooltip:AddLine(title)
        if text then GameTooltip:AddLine(text, 0.8, 0.8, 0.8, true) end
        GameTooltip:Show()
    end)
    widget:SetScript("OnLeave", GameTooltip_Hide)
end

local function Check(parent, label, onClick)
    local cb = CreateFrame("CheckButton", nil, parent, "UICheckButtonTemplate")
    cb:SetSize(24, 24)
    cb.label = cb:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    cb.label:SetPoint("LEFT", cb, "RIGHT", 4, 0)
    cb.label:SetText(label)
    cb:SetScript("OnClick", function(self) onClick(self:GetChecked() and true or false) end)
    return cb
end

local function Button(parent, text, w, onClick)
    local b = CreateFrame("Button", nil, parent, "UIPanelButtonTemplate")
    b:SetSize(w, 21)
    b:SetText(text)
    b:SetScript("OnClick", onClick)
    return b
end

-- Encadré doré : fond sombre, bord doré, titre + trait doré.
local function Box(parent, anchor, title, gap)
    local box = CreateFrame("Frame", nil, parent, BackdropTemplateMixin and "BackdropTemplate" or nil)
    box:SetPoint("TOP", anchor, "BOTTOM", 0, -(gap or 22))
    box:SetPoint("LEFT", parent, "LEFT", 30, 0)
    box:SetPoint("RIGHT", parent, "RIGHT", -30, 0)
    if box.SetBackdrop then
        box:SetBackdrop({ bgFile = "Interface\\Buttons\\WHITE8X8", edgeFile = "Interface\\Buttons\\WHITE8X8", edgeSize = 1 })
        box:SetBackdropColor(0, 0, 0, 0.35)
        box:SetBackdropBorderColor(GOLD_R, GOLD_G, GOLD_B, 0.35)
    end
    local header = box:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("TOPLEFT", 14, -12)
    header:SetText(title)
    local line = box:CreateTexture(nil, "ARTWORK")
    line:SetColorTexture(GOLD_R, GOLD_G, GOLD_B, 0.4)
    line:SetHeight(1)
    line:SetPoint("TOPLEFT", 14, -34)
    line:SetPoint("TOPRIGHT", -14, -34)
    box.y = -42
    return box
end

local function BoxRow(box, i)
    local row = CreateFrame("Frame", nil, box)
    row:SetHeight(ROW_H)
    row:SetPoint("TOPLEFT", 6, box.y)
    row:SetPoint("TOPRIGHT", -6, box.y)
    if i % 2 == 0 then
        local stripe = row:CreateTexture(nil, "BACKGROUND", nil, 1)
        stripe:SetAllPoints()
        stripe:SetColorTexture(1, 1, 1, 0.04)
    end
    box.y = box.y - ROW_H
    return row
end

local function CloseBox(box) box:SetHeight(-box.y + 10) end

local function Note(row, anchor, text)
    local fs = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    fs:SetPoint("LEFT", anchor, "RIGHT", 10, 0)
    fs:SetPoint("RIGHT", -8, 0)
    fs:SetJustifyH("LEFT")
    fs:SetWordWrap(false)
    fs:SetText(text)
    return fs
end

-- Ligne « libellé  [-] valeur [+]  note »
local function Stepper(box, i, label, onMinus, onPlus, note, tip)
    local row = BoxRow(box, i)
    local l = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    l:SetPoint("LEFT", 36, 0)
    l:SetText(label)
    local minus = Button(row, "-", 24, onMinus)
    minus:SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    local value = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    value:SetPoint("LEFT", minus, "RIGHT", 6, 0)
    value:SetWidth(40)
    local plus = Button(row, "+", 24, onPlus)
    plus:SetPoint("LEFT", value, "RIGHT", 6, 0)
    if note then Note(row, plus, note) end
    if tip then Tooltip(minus, label, tip); Tooltip(plus, label, tip) end
    return value
end

local function Changed()
    ns.ApplyLayout()
    ns.ResetText()
    ns.Refresh()
    ns.RefreshOptions()
end

function ns.RefreshOptions()
    if not panel.built or not ns.db then return end
    local db = ns.db
    ui.toggle:SetText(db.enabled and "Affichage en combat : |cff00ff00activé|r" or "Affichage en combat : |cffff4040désactivé|r")
    ui.unlock:SetChecked(not db.locked)
    ui.count:SetChecked(db.showCount)
    ui.threshold:SetText(db.threshold)
    ui.scale:SetText(string.format("%.1f", db.scale))
    ui.preview1:SetText("|cff40ff40SINGLE TARGET|r")
    ui.preview2:SetText("|cffff4020MULTI TARGET|r" .. (db.showCount and (" |cffffffff(" .. db.threshold .. ")|r") or ""))
end

local function Build()
    if panel.built then return end
    panel.built = true

    local scroll = CreateFrame("ScrollFrame", nil, panel, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", -26, 4)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetSize(600, 1)
    scroll:SetScrollChild(content)
    scroll:SetScript("OnSizeChanged", function(_, w) content:SetWidth(w) end)

    -- Bloc du haut : logo + nom de l'addon
    local head = CreateFrame("Frame", nil, content)
    head:SetSize(1, 72)
    head:SetPoint("TOP", 0, -36)

    local logo = head:CreateTexture(nil, "ARTWORK")
    logo:SetSize(64, 64)
    logo:SetTexture(LOGO)

    local title = head:CreateFontString(nil, "OVERLAY", "GameFontNormalHuge")
    if not title:SetFont(TITLE_FONT, 46, "") then
        title:SetFontObject("GameFontNormalHuge")
    end
    title:SetText("ForeverTargetMode")
    title:SetTextColor(GOLD_R, GOLD_G, GOLD_B)
    title:SetShadowOffset(2, -2)
    title:SetShadowColor(0, 0, 0, 1)

    local gap = 16
    head:SetWidth(64 + gap + title:GetStringWidth())
    logo:SetPoint("LEFT", head, "LEFT", 0, 0)
    title:SetPoint("LEFT", logo, "RIGHT", gap, -2)

    local version = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    version:SetPoint("TOP", head, "BOTTOM", 0, -14)
    version:SetText("Version : " .. ns.Version())

    local hint = content:CreateFontString(nil, "OVERLAY", "GameFontHighlightLarge")
    hint:SetPoint("TOP", version, "BOTTOM", 0, -10)
    hint:SetText("Indique en combat si tu es en mono-cible ou en multi-cibles")

    -- Gros bouton : activer / désactiver
    local toggle = CreateFrame("Button", nil, content, "UIPanelButtonTemplate")
    toggle:SetSize(300, 34)
    toggle:SetPoint("TOP", hint, "BOTTOM", 0, -20)
    toggle:SetNormalFontObject("GameFontNormalLarge")
    toggle:SetHighlightFontObject("GameFontHighlightLarge")
    toggle:SetScript("OnClick", function()
        ns.db.enabled = not ns.db.enabled
        Changed()
    end)
    ui.toggle = toggle

    -- Encadré « Réglages »
    local opts = Box(content, toggle, "Réglages", 28)

    local r1 = BoxRow(opts, 1)
    ui.unlock = Check(r1, "Déverrouiller pour déplacer", function(v) ns.db.locked = not v; Changed() end)
    ui.unlock:SetPoint("LEFT", 6, 0)
    local n1 = r1:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    n1:SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    n1:SetPoint("RIGHT", -8, 0)
    n1:SetJustifyH("LEFT")
    n1:SetWordWrap(false)
    n1:SetText("Le texte apparaît : fais-le glisser à la souris")

    local r2 = BoxRow(opts, 2)
    ui.count = Check(r2, "Afficher le nombre d'ennemis", function(v) ns.db.showCount = v; Changed() end)
    ui.count:SetPoint("LEFT", 6, 0)
    local n2 = r2:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
    n2:SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    n2:SetPoint("RIGHT", -8, 0)
    n2:SetJustifyH("LEFT")
    n2:SetWordWrap(false)
    n2:SetText("Ex. : MULTI TARGET (3)")

    ui.threshold = Stepper(opts, 3, "Seuil multi-cibles",
        function() ns.db.threshold = math.max(2, ns.db.threshold - 1); Changed() end,
        function() ns.db.threshold = math.min(20, ns.db.threshold + 1); Changed() end,
        "ennemis ou plus = MULTI",
        "Nombre d'ennemis en combat contre toi ou ton groupe à partir duquel le texte passe en MULTI TARGET.")

    ui.scale = Stepper(opts, 4, "Taille du texte",
        function() ns.db.scale = math.max(0.5, math.floor(ns.db.scale * 10 - 1 + 0.5) / 10); Changed() end,
        function() ns.db.scale = math.min(3, math.floor(ns.db.scale * 10 + 1 + 0.5) / 10); Changed() end,
        "de 0.5 à 3")

    local r5 = BoxRow(opts, 5)
    local reset = Button(r5, "Position par défaut", 160, function()
        ns.db.point = CopyTable(ns.DEFAULTS.point)
        ns.db.scale = ns.DEFAULTS.scale
        Changed()
    end)
    reset:SetPoint("LEFT", 36, 0)
    CloseBox(opts)

    -- Encadré « Aperçu »
    local prev = Box(content, opts, "Aperçu")
    local p1 = BoxRow(prev, 1)
    ui.preview1 = p1:CreateFontString(nil, "OVERLAY")
    ui.preview1:SetFont(STANDARD_TEXT_FONT, 18, "THICKOUTLINE")
    ui.preview1:SetPoint("LEFT", 36, 0)
    Note(p1, ui.preview1, "|cffaaaaaamoins d'ennemis que le seuil|r"):SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    local p2 = BoxRow(prev, 2)
    ui.preview2 = p2:CreateFontString(nil, "OVERLAY")
    ui.preview2:SetFont(STANDARD_TEXT_FONT, 18, "THICKOUTLINE")
    ui.preview2:SetPoint("LEFT", 36, 0)
    Note(p2, ui.preview2, "|cffaaaaaaseuil atteint ou dépassé|r"):SetPoint("LEFT", 14 + LABEL_W + 10, 0)
    local warn = prev:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    warn:SetPoint("TOPLEFT", 14, prev.y - 6)
    warn:SetPoint("RIGHT", -14, 0)
    warn:SetJustifyH("LEFT")
    warn:SetText("Les ennemis sont comptés grâce à leurs barres d'info : active les barres d'info ennemies (touche V).")
    prev.y = prev.y - 24
    CloseBox(prev)

    -- Encadré « Commandes »
    local cmds = Box(content, prev, "Commandes")
    local COMMANDS = {
        { "/ftm", "Ouvrir ce panneau d'options" },
        { "/ftm unlock  |  /ftm lock", "Déverrouiller / verrouiller la position" },
        { "/ftm seuil <n>", "Ennemis nécessaires pour MULTI" },
        { "/ftm scale <0.5-3>", "Taille du texte" },
        { "/ftm count", "Afficher / masquer le nombre d'ennemis" },
        { "/ftm toggle", "Activer / désactiver l'addon" },
        { "/ftm reset", "Remettre la position par défaut" },
        { "/ftm help", "Afficher l'aide dans le tchat" },
    }
    for i, c in ipairs(COMMANDS) do
        local row = BoxRow(cmds, i)
        local cmd = row:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        cmd:SetPoint("LEFT", 8, 0)
        cmd:SetWidth(LABEL_W)
        cmd:SetJustifyH("LEFT")
        cmd:SetText(c[1])
        local desc = row:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        desc:SetPoint("LEFT", 14 + LABEL_W + 4, 0)
        desc:SetPoint("RIGHT", -8, 0)
        desc:SetJustifyH("LEFT")
        desc:SetWordWrap(false)
        desc:SetText(c[2])
    end
    CloseBox(cmds)

    C_Timer.After(0, function()
        local top, bottom = content:GetTop(), cmds:GetBottom()
        if top and bottom then content:SetHeight(top - bottom + 30) end
    end)
    content:SetHeight(1000)
end

panel:SetScript("OnShow", function()
    Build()
    ns.RefreshOptions()
end)

-- Enregistrement dans le menu Options
local category
if Settings and Settings.RegisterCanvasLayoutCategory then
    category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
elseif InterfaceOptions_AddCategory then
    InterfaceOptions_AddCategory(panel)
end

function ForeverTargetMode_OpenOptions()
    if category and Settings and Settings.OpenToCategory then
        Settings.OpenToCategory(category.GetID and category:GetID() or category.ID)
    elseif InterfaceOptionsFrame_OpenToCategory then
        InterfaceOptionsFrame_OpenToCategory(panel)
        InterfaceOptionsFrame_OpenToCategory(panel)
    end
end
