local name, ns = ...
local category, canvas
local modules = {}
local function open()
    Settings.OpenToCategory(category:GetID())
end

local function atlas()
    return LockpickAtlas and LockpickAtlas.DB and LockpickAtlas
end

local function satchel()
    return PoisonSatchel and PoisonSatchel.db and PoisonSatchel
end

local function ledger()
    return ComboPointLedger
end

local function menu(owner)
    MenuUtil.CreateContextMenu(owner, function(_, root)
        root:CreateTitle("|T" .. ns.icon .. ":16|t Rogue Toolkit")
        for _, module in ipairs(modules) do
            local addon = module.get()
            if addon then
                module.menu(addon, root:CreateButton(module.title))
            end
        end
        root:CreateDivider()
        root:CreateButton("Toolkit settings", open)
    end)
end

local function card(parent, y, title, icon, installed)
    local c = CreateFrame("Frame", nil, parent, "BackdropTemplate")
    c:SetPoint("TOPLEFT", 12, -y)
    c:SetPoint("TOPRIGHT", -24, -y)
    c:SetHeight(78)
    c:SetBackdrop({bgFile="Interface\\Buttons\\WHITE8X8"})
    c:SetBackdropColor(0.09, 0.085, 0.105, 0.9)
    local art = c:CreateTexture(nil, "ARTWORK")
    art:SetSize(32,32)
    art:SetPoint("TOPLEFT", 12,-10)
    art:SetTexture(installed and icon or ns.icon)
    local header = c:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    header:SetPoint("LEFT", art, "RIGHT", 10, 0)
    header:SetText(title)
    if not installed then
        local hint = c:CreateFontString(nil, "OVERLAY", "GameFontDisable")
        hint:SetPoint("TOPLEFT", 14,-49)
        hint:SetText("Install " .. title .. " to use these tools.")
    end
    return c
end

local function check(c, y, label, get, set)
    local b = CreateFrame("CheckButton", nil, c, "UICheckButtonTemplate")
    b:SetSize(24,24)
    b:SetPoint("TOPLEFT", 12,-y)
    b.Text:SetText(label)
    b:SetChecked(get())
    b:SetScript("OnShow", function() b:SetChecked(get()) end)
    b:SetScript("OnClick", function() set(b:GetChecked() and true or false) end)
end

local function action(c, x, y, width, label, fn)
    local b = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
    b:SetPoint("TOPLEFT", x, -y)
    b:SetSize(width, 24)
    b:SetText(label)
    b:SetScript("OnClick", fn)
end

modules[1] = {
    id = "PoisonSatchel", title = "Poison Satchel", get = satchel, height = 148,
    menu = function(v, submenu)
        if v.buildMenu then
            v.buildMenu(submenu)
        else
            submenu:CreateButton("Poison manager", v.open)
            submenu:CreateCheckbox("Open at poison vendors", function() return v.db.autoOpen end,
                function() v.db.autoOpen = not v.db.autoOpen end)
        end
    end,
    launcher = function(v) return v.button end,
    settings = function(poison, v)
        check(poison, 50, "Open at poison vendors", function() return v.db.autoOpen end,
            function(on) v.db.autoOpen = on end)
        action(poison, 14, 96, 130, "Poison manager", function()
            HideUIPanel(SettingsPanel)
            C_Timer.After(0, v.open)
        end)
    end,
}
modules[2] = {
    id = "LockpickAtlas", title = "Lockpick Atlas", get = atlas, height = 178,
    menu = function(a, submenu)
        if a.BuildMinimapMenu then
            a.BuildMinimapMenu(submenu)
            return
        end
        submenu:CreateButton("Add coordinates", a.OpenAddCoords)
        submenu:CreateDivider()
        for _, entry in ipairs({
            {"showWorldMapPins", "World map markers"},
            {"showMinimapPins", "Minimap markers"},
        }) do
            local setting = Settings.GetSetting("LockpickAtlas_" .. entry[1])
            if setting then
                submenu:CreateCheckbox(entry[2], function() return setting:GetValue() end,
                    function() setting:SetValue(not setting:GetValue()) end)
            end
        end
        submenu:CreateDivider()
        submenu:CreateButton("Settings", a.OpenOptions)
    end,
    launcher = function(a) return a.minimapButton end,
    settings = function(pins, a)
        for i, entry in ipairs({
            {"showWorldMapPins","World map markers"},
            {"showMinimapPins","Minimap markers"},
            {"warnAtSkillCap","Skill cap warning"},
        }) do
            local key = entry[1]
            local setting = Settings.GetSetting("LockpickAtlas_" .. key)
            if setting then
                check(pins, 44+i*23-23, entry[2], function() return setting:GetValue() end,
                    function(value) setting:SetValue(value) end)
            end
        end
        action(pins, 14, 132, 130, "Atlas menu", function(self) a.OpenMinimapMenu(self) end)
        action(pins, 150, 132, 130, "Atlas settings", a.OpenOptions)
    end,
}
modules[3] = {
    id = "ComboPointLedger", title = "Combo Point Ledger", get = ledger, height = 122,
    icon = "Interface\\AddOns\\RogueToolkit\\Textures\\ComboPointLedger",
    menu = function(v, submenu) v.BuildMinimapMenu(submenu) end,
    launcher = function(v) return v.button end,
    settings = function(hud, v)
        check(hud, 50, "Show HUD", v.IsHUDShown, v.SetHUDShown)
        action(hud, 14, 84, 130, "HUD settings", v.OpenOptions)
    end,
}

local function makeCards()
    local scroll = CreateFrame("ScrollFrame", nil, canvas, "UIPanelScrollFrameTemplate")
    scroll:SetPoint("TOPLEFT", 0, -4)
    scroll:SetPoint("BOTTOMRIGHT", -30, 6)
    local content = CreateFrame("Frame", nil, scroll)
    content:SetWidth(math.max(1, scroll:GetWidth()))
    scroll:SetScrollChild(content)
    scroll:HookScript("OnSizeChanged", function(_, width) content:SetWidth(width) end)
    local character = UnitGUID("player") or UnitName("player")
    local y = 12
    for _, module in ipairs(modules) do
        local id = module.id
        local installed = C_AddOns.DoesAddOnExist(id)
        local addon = module.get()
        local icon = module.icon or "Interface\\AddOns\\" .. id .. "\\Textures\\Logo"
        local c = card(content, y, module.title, icon, installed)
        if installed then
            local function enabled()
                return C_AddOns.GetAddOnEnableState(id, character) > 0
            end
            local toggle = CreateFrame("CheckButton", nil, c, "UICheckButtonTemplate")
            toggle:SetPoint("TOPRIGHT", -12, -12)
            toggle:SetSize(24,24)
            toggle.Text:ClearAllPoints()
            toggle.Text:SetPoint("RIGHT", toggle, "LEFT", -4, 0)
            toggle.Text:SetText("Enabled")
            local reload = CreateFrame("Button", nil, c, "UIPanelButtonTemplate")
            reload:SetSize(94, 22)
            reload:SetPoint("TOPRIGHT", -12, -46)
            reload:SetText("Reload UI")
            reload:SetScript("OnClick", ReloadUI)
            local function refresh()
                toggle:SetChecked(enabled())
                reload:SetShown(enabled() ~= (C_AddOns.IsAddOnLoaded(id) and true or false))
            end
            toggle:SetScript("OnClick", function()
                local requested = not enabled()
                local change = requested and C_AddOns.EnableAddOn or C_AddOns.DisableAddOn
                change(id, character)
                refresh()
                if enabled() ~= requested then
                    print("Rogue Toolkit: Change " .. module.title .. " in the game menu under AddOns.")
                end
            end)
            toggle:SetScript("OnShow", refresh)
            refresh()
        end
        if addon then
            c:SetHeight(module.height)
            module.settings(c, addon)
        end
        y = y + c:GetHeight() + 12
    end
    content:SetHeight(y)
end

local function takeLauncher(button)
    if not button then return end
    button:Hide()
    button:HookScript("OnShow", function(self) self:Hide() end)
end

local events = CreateFrame("Frame")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self)
    self:UnregisterEvent("PLAYER_LOGIN")
    RogueToolkitDB = RogueToolkitDB or {}
    canvas = CreateFrame("Frame")
    canvas:Hide()
    canvas:SetScript("OnShow", function(self)
        self:SetScript("OnShow", nil)
        makeCards()
    end)
    category = Settings.RegisterCanvasLayoutCategory(canvas, "Rogue Toolkit")
    Settings.RegisterAddOnCategory(category)
    ns.button = ns.launcher("Rogue Toolkit", RogueToolkitDB, open, menu)
    -- Companions can finish initializing in their own PLAYER_LOGIN handlers.
    C_Timer.After(0, function()
        for _, module in ipairs(modules) do
            local addon = module.get()
            if addon then takeLauncher(module.launcher(addon)) end
        end
    end)
    SLASH_ROGUETOOLKIT1 = "/rtk"
    SlashCmdList.ROGUETOOLKIT = open
end)
