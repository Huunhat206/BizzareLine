return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local UserInputService = game:GetService("UserInputService")
    local LocalPlayer = Players.LocalPlayer

    -- DATA
    local RarityOrder = {"Common", "Uncommon", "Rare", "Legendary", "Mythical"}
    local StandData = {
        Common = {"Anubis", "Red Hot Chili Pepper", "Silver Chariot", "The Hand"},
        Uncommon = {"Crazy Diamond", "Magician's Red", "Purple Haze"},
        Rare = {"Gold Experience", "Killer Queen", "Stone Free", "Weather Report"},
        Legendary = {"King Crimson", "Planet Waves", "Star Platinum", "Star Platinum, The World", "The World", "The World, High Voltage"},
        Mythical = {"Diver Down", "Whitesnake"}
    }
    local TraitData = {
        Common = {"Arrogant", "Cowardly", "Energetic", "Erratic", "Firm", "Happy"},
        Uncommon = {"Astute", "Curious", "Kind", "Predictive"},
        Rare = {"Compassionate", "Determined", "Durable", "Fearful", "Furious", "Slugger"},
        Legendary = {"Artistic", "Cursed", "Dominant", "Methodical", "Rhythmic", "Suffocating"},
        Mythical = {"Demonic", "Elegant", "Feral", "Transcendent"}
    }
    local SkinData = {
        "C-Moon (Blue)", "C-Moon (Deimos)", "C-Moon (Greyscale)", "C-Moon (Momo)", "C-Moon (Tatsumaki)",
        "Crazy Diamond (Dark Armored)", "Crazy Diamond (Greyscale)", "Crazy Diamond (Light Armored)", "Crazy Diamond (Luffy)", "Crazy Diamond (Reverso)",
        "Death 13 (King of Spades)", "Death 13 (Maka)", "Death 13 (Reaper 13)",
        "Diver Down (Fox Demon)", "Diver Down (Greyscale)", "Diver Down (Highlighter)",
        "Gold Experience (Atom Eve)", "Gold Experience (Green)", "Gold Experience (Greyscale)",
        "Killer Queen (Bomb Devil)", "Killer Queen (Greyscale)", "Killer Queen (One Who Laughs)", "Killer Queen (Tan)",
        "King Crimson (Blue)", "King Crimson (Deimos)", "King Crimson (Igris)", "King Crimson (Kawaii)", "King Crimson (Omni Man)", "King Crimson (Sukuna)",
        "Made in Heaven (Greyscale)",
        "Magician's Red (Greyscale)", "Magician's Red (King)", "Magician's Red (Orange)", "Magician's Red (Sun Deity)",
        "Planet Waves (Escanor)", "Planet Waves (Greyscale)",
        "Purple Haze (Greyscale)", "Purple Haze (Poison)", "Purple Haze (Purple Monarch)",
        "Red Hot Chili Pepper (Greyscale)", "Red Hot Chili Pepper (Purple)", "Red Hot Chili Pepper (Yoruichi)",
        "Silver Chariot (Cyborg Samurai)", "Silver Chariot (Silver Floridian)",
        "Silver Chariot Requiem (Comic Omni Man)", "Silver Chariot Requiem (The Knight)",
        "Star Platinum (Deimos)", "Star Platinum (Galaxy Garou)", "Star Platinum (Greyscale)", "Star Platinum (Holiday)", "Star Platinum (Kawaii)",
        "Star Platinum, The World (Greyscale)", "Star Platinum, The World (Invincible)", "Star Platinum, The World (The Strongest)",
        "Stone Free (Carnage)", "Stone Free (Greyscale)", "Stone Free (Makima)", "Stone Free (Turqoise)", "Stone Free (Ultimate Makima)",
        "The Hand (Greyscale)", "The Hand (Purple)",
        "The World (Dark)", "The World (Egyptian)", "The World (Goku)", "The World (Greyscale)", "The World (Kawaii)",
        "The World Over Heaven (Above Heaven)", "The World Over Heaven (Conquest)", "The World Over Heaven (Greyscale)", "The World Over Heaven (King of Curses)",
        "The World, High Voltage (Baby SJW)", "The World, High Voltage (GOD SJW)", "The World, High Voltage (Greyscale)", "The World, High Voltage (Lima)", "The World, High Voltage (Prestige)", "The World, High Voltage (Violence)",
        "True Made in Heaven (Dullahan)", "True Made in Heaven (Greyscale)", "True Made in Heaven (High Contrast)", "True Made in Heaven (Made in Underworld)",
        "Weather Report (Esdeath)", "Weather Report (Fubuki)", "Weather Report (Greyscale)", "Weather Report (Nami)", "Weather Report (Pinky)",
        "Whitesnake (Greyscale)", "Whitesnake (Ryuk)", "Whitesnake (Velvet)"
    }

    local statMapping = { [1]="D", [2]="C", [3]="B", [4]="A", [5]="S" }
    local revStatMap = { ["D"]=1, ["C"]=2, ["B"]=3, ["A"]=4, ["S"]=5 }
    local LOGO_URL = "https://static.wikia.nocookie.net/blineage/images/e/e6/Site-logo.png/revision/latest?cb=20260310145648"

    local function GetStatChar(val) return statMapping[tonumber(val)] or "?" end
    local function GetTraitRarity(traitName)
        if not traitName or traitName == "None" then return nil end
        for rarity, traits in pairs(TraitData) do
            for _, t in ipairs(traits) do if t == traitName then return rarity end end
        end
        return nil
    end

    local function SendWebhook(standName, traitName, skinName, rollCount)
        local whUrl = getgenv().NthucHub_WebhookURL
        if not whUrl or whUrl == "" then return end

        local rarityFound = "Unknown"
        for _, r in ipairs(RarityOrder) do
            if StandData[r] then
                for _, s in ipairs(StandData[r]) do
                    if s == standName then rarityFound = r break end
                end
            end
        end

        local rarityColorNum = { Common=0xB4B4B4, Uncommon=0x50D282, Rare=0x5096FF, Legendary=0xFFAA1E, Mythical=0xD250FF }
        local embedData = {
            username = "Nthuc Hub | Auto Arrow",
            avatar_url = LOGO_URL,
            embeds = {{
                title = "[ ROLL THANH CONG ]",
                color = rarityColorNum[rarityFound] or 0x7B68EE,
                fields = {
                    { name="[ Stand ]", value="```\n" .. standName .. "\n```", inline=true },
                    { name="[ Trait ]", value="```\n" .. traitName .. "\n```", inline=true },
                    { name="[ Skin ]", value="```\n" .. skinName .. "\n```", inline=true },
                    { name="[ Rarity ]", value="```\n" .. rarityFound .. "\n```", inline=true },
                    { name="[ So lan ]", value="```\n" .. tostring(rollCount) .. "\n```", inline=true },
                    { name="[ Player ]", value="```\n" .. LocalPlayer.Name .. "\n```", inline=true },
                },
                footer = { text="Nthuc Hub Auto Arrow | "..LocalPlayer.Name, icon_url=LOGO_URL },
                timestamp = DateTime.now():ToIsoDate()
            }}
        }

        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then pcall(req, { Url = whUrl, Method = "POST", Headers = { ["Content-Type"] = "application/json" }, Body = HttpService:JSONEncode(embedData) }) end
    end

    local function GetCurrentStandData()
        local pData = LocalPlayer:FindFirstChild("PlayerData")
        if not pData then return nil end
        local slot = pData:FindFirstChild("SlotData")
        if not slot then return nil end
        local sv = slot:FindFirstChild("Stand")
        if not sv then return nil end
        local ok, dec = pcall(HttpService.JSONDecode, HttpService, tostring(sv.Value))
        return (ok and type(dec) == "table") and dec or nil
    end

    local guiTarget = pcall(function() return gethui() end) and gethui() or game:GetService("CoreGui")
    local function MakeDraggable(guiObj)
        local dragging, dragInput, dragStart, startPos
        guiObj.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true; dragStart = input.Position; startPos = guiObj.Position
                input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
            end
        end)
        guiObj.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
        UserInputService.InputChanged:Connect(function(input)
            if input == dragInput and dragging then
                local delta = input.Position - dragStart
                guiObj.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
            end
        end)
    end

    local StatGui = Instance.new("ScreenGui")
    StatGui.Name = "NthucHub_StatBoard"
    StatGui.ResetOnSpawn = false
    StatGui.DisplayOrder = 999998
    StatGui.Parent = guiTarget
    StatGui.Enabled = false 

    local StatFrame = Instance.new("Frame")
    StatFrame.Size = UDim2.new(0, 250, 0, 200)
    StatFrame.Position = UDim2.new(0.05, 0, 0.4, 0)
    StatFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    StatFrame.Parent = StatGui
    Instance.new("UICorner", StatFrame).CornerRadius = UDim.new(0, 6)
    Instance.new("UIStroke", StatFrame).Color = Color3.fromRGB(80, 80, 80)
    MakeDraggable(StatFrame)

    local StatLayout = Instance.new("UIListLayout", StatFrame)
    StatLayout.Padding = UDim.new(0, 8); StatLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left; StatLayout.SortOrder = Enum.SortOrder.LayoutOrder
    local StatPadding = Instance.new("UIPadding", StatFrame)
    StatPadding.PaddingTop = UDim.new(0, 15); StatPadding.PaddingBottom = UDim.new(0, 15); StatPadding.PaddingLeft = UDim.new(0, 15)
    StatLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function() StatFrame.Size = UDim2.new(0, 250, 0, StatLayout.AbsoluteContentSize.Y + 30) end)

    local function CreateStatLabel(name, order, isBold)
        local lbl = Instance.new("TextLabel")
        lbl.Size = UDim2.new(1, -10, 0, 16); lbl.BackgroundTransparency = 1; lbl.TextColor3 = Color3.fromRGB(240, 240, 240)
        lbl.Font = isBold and Enum.Font.GothamBold or Enum.Font.Gotham
        lbl.TextSize = 13; lbl.TextXAlignment = Enum.TextXAlignment.Left; lbl.LayoutOrder = order; lbl.Name = name; lbl.Parent = StatFrame
        return lbl
    end
    local function CreateDivider(order)
        local div = Instance.new("Frame")
        div.Size = UDim2.new(1, -15, 0, 1); div.BackgroundColor3 = Color3.fromRGB(80, 80, 80); div.BorderSizePixel = 0; div.LayoutOrder = order; div.Parent = StatFrame
        return div
    end

    local lblStand     = CreateStatLabel("Stand", 1, true)
    local lblSkin      = CreateStatLabel("Skin", 2, false)
    local div1         = CreateDivider(3)
    local lblStrength  = CreateStatLabel("Strength", 4, false)
    local lblSpeed     = CreateStatLabel("Speed", 5, false)
    local lblSpecialty = CreateStatLabel("Specialty", 6, false)
    local div2         = CreateDivider(7)
    local lblTrait     = CreateStatLabel("Trait", 8, false)
    local lblWorthiness= CreateStatLabel("Worthiness", 9, false)

    local function UpdateStatBoard()
        local worthinessVal = "0"
        pcall(function() worthinessVal = LocalPlayer.PlayerGui.menu.stat_frame.character_info.holder.Frame.Worthiness.stat_amount.Text end)
        local data = GetCurrentStandData()
        if data then
            lblStand.Text = "Stand : " .. tostring(data.Name or "None")
            if data.Skin and data.Skin ~= "None" and data.Skin ~= "" then
                lblSkin.Text = "Stand Skin : " .. tostring(data.Skin); lblSkin.Visible = true
            else lblSkin.Visible = false end
            lblStrength.Text = "  - Strength : " .. GetStatChar(data.Strength)
            lblSpeed.Text = "  - Speed : " .. GetStatChar(data.Speed)
            lblSpecialty.Text = "  - Specialty : " .. GetStatChar(data.Specialty)
            local traitRarity = GetTraitRarity(data.Trait)
            lblTrait.Text = traitRarity and ("Trait : " .. tostring(data.Trait) .. " (" .. traitRarity .. ")") or ("Trait : " .. tostring(data.Trait or "None"))
        else
            lblStand.Text = "Stand : None"; lblSkin.Visible = false; lblStrength.Text = "  - Strength : ?"; lblSpeed.Text = "  - Speed : ?"; lblSpecialty.Text = "  - Specialty : ?"; lblTrait.Text = "Trait : None"
        end
        lblWorthiness.Text = "Worthiness : " .. tostring(worthinessVal)
    end

    task.spawn(function()
        while task.wait(0.5) do if StatGui.Enabled then pcall(UpdateStatBoard) end end
    end)

    -- ARROW UI LOGIC
    local flatStands = {"Bo chon"}; for _, r in ipairs(RarityOrder) do if StandData[r] then table.insert(flatStands, "--- " .. string.upper(r) .. " ---"); for _, s in ipairs(StandData[r]) do table.insert(flatStands, s) end end end
    local flatTraits = {"Bo chon"}; for _, r in ipairs(RarityOrder) do if TraitData[r] then table.insert(flatTraits, "--- " .. string.upper(r) .. " ---"); for _, t in ipairs(TraitData[r]) do table.insert(flatTraits, t) end end end
    local flatSkins = {"Bo chon"}; for _, s in ipairs(SkinData) do table.insert(flatSkins, s) end
    local targetVals = {"Bo chon", "D", "C", "B", "A", "S"}

    local TargetStand, TargetTrait, TargetSkin = nil, nil, nil
    local TargetStr, TargetSpd, TargetSpec = nil, nil, nil
    local TargetAllStat = nil

    local isRolling = false; local rolls = 0; local StatusPara
    local function UpdateStatus(text) if StatusPara then StatusPara:SetDesc(text) end end

    local function StartRollingProcess(mode)
        if isRolling then return end
        if mode == "Target" and TargetStand == nil and TargetTrait == nil and TargetSkin == nil then UpdateStatus("Vui long chon Stand, Trait hoac Skin!"); return
        elseif mode == "CustomStat" and TargetStr == nil and TargetSpd == nil and TargetSpec == nil then UpdateStatus("Vui long chon it nhat 1 chi so!"); return
        elseif mode == "AllStat" and TargetAllStat == nil then UpdateStatus("Vui long chon muc Stat dong nhat!"); return end

        isRolling = true; rolls = 0
        UpdateStatus("Dang kiem tra du lieu hien tai...")

        task.spawn(function()
            local StandValueObj = LocalPlayer:WaitForChild("PlayerData"):WaitForChild("SlotData"):WaitForChild("Stand")
            while isRolling do
                local currentData = GetCurrentStandData()
                local currentStandName = currentData and currentData.Name or "None"
                local currentTraitName = currentData and currentData.Trait or "None"
                local currentSkinVal   = currentData and currentData.Skin or "None"
                local gotName  = string.match(tostring(currentStandName), "^%s*(.-)%s*$") or "?"
                local gotTrait = string.match(tostring(currentTraitName), "^%s*(.-)%s*$") or "None"
                local gotSkin  = string.match(tostring(currentSkinVal), "^%s*(.-)%s*$") or "None"

                local isMatch = false
                if mode == "AnySkin" then
                    if gotSkin ~= "None" and gotSkin ~= "" and gotSkin ~= "?" then isMatch = true end
                elseif mode == "Target" then
                    if TargetSkin ~= nil then
                        local selStand, selSkin = TargetSkin:match("^(.-) %((.-)%)$")
                        if selStand and selSkin and gotName == selStand and string.find(gotSkin, selSkin, 1, true) then isMatch = true end
                    else
                        local matchStand = (TargetStand == nil or gotName == TargetStand)
                        local matchTrait = (TargetTrait == nil or gotTrait == TargetTrait)
                        if matchStand and matchTrait then isMatch = true end
                    end
                elseif mode == "CustomStat" then
                    if currentData then
                        local cStr, cSpd, cSpec = currentData.Strength, currentData.Speed, currentData.Specialty
                        local matchStr  = (TargetStr == nil) or (cStr == revStatMap[TargetStr])
                        local matchSpd  = (TargetSpd == nil) or (cSpd == revStatMap[TargetSpd])
                        local matchSpec = (TargetSpec == nil) or (cSpec == revStatMap[TargetSpec])
                        if matchStr and matchSpd and matchSpec then isMatch = true end
                    end
                elseif mode == "AllStat" then
                    if currentData and TargetAllStat then
                        local targetNum = revStatMap[TargetAllStat]
                        if currentData.Strength == targetNum and currentData.Speed == targetNum and currentData.Specialty == targetNum then isMatch = true end
                    end
                end

                if isMatch and gotName ~= "None" and gotName ~= "" and gotName ~= "?" then
                    isRolling = false
                    local successText = "[ Thanh cong ] " .. gotName .. " [" .. gotTrait .. "]"
                    if gotSkin ~= "None" then successText = successText .. " | Skin: " .. gotSkin end
                    UpdateStatus(successText)
                    task.spawn(function() SendWebhook(gotName, gotTrait, gotSkin, rolls) end)
                    break
                end
                
                local currentString = tostring(StandValueObj.Value)
                UpdateStatus("Dang dung Arrow... (So lan: " .. rolls .. ")")
                rolls = rolls + 1
                local waitTime = 0
                local successChange = false
                
                while isRolling and waitTime < 20 do
                    pcall(function() ReplicatedStorage.requests.character.use_item:FireServer("Stand Arrow") end)
                    local t0 = os.clock()
                    while isRolling and (os.clock() - t0 < 0.25) do
                        if tostring(StandValueObj.Value) ~= currentString then successChange = true; break end
                        task.wait() 
                    end
                    if successChange then break end
                    waitTime = waitTime + 0.25
                end

                if not isRolling then break end
                if not successChange then UpdateStatus("Loi mang hoac da het item Arrow!"); isRolling = false; break end

                task.wait(0.5) 
                local newData = GetCurrentStandData()
                local newName = string.match(tostring(newData and newData.Name or "?"), "^%s*(.-)%s*$") or "?"
                local newTrait = string.match(tostring(newData and newData.Trait or "?"), "^%s*(.-)%s*$") or "None"
                local newSkin = string.match(tostring(newData and newData.Skin or "None"), "^%s*(.-)%s*$") or "None"
                
                local displayInfo = string.format("Lan #%d: %s [%s]", rolls, newName, newTrait)
                if newSkin ~= "None" then displayInfo = displayInfo .. " | Skin: " .. newSkin end
                UpdateStatus(displayInfo)
            end
        end)
    end

    Tabs.AutoRoll:AddSection("1. ROLL THEO STAND / TRAIT / SKIN")
    local Drop_Stand = Tabs.AutoRoll:AddDropdown("Drop_Stand", {
        Title = "Target Stand", Values = flatStands, Default = 1,
        Callback = function(Value) if string.find(Value, "^%-%-%-") then Drop_Stand:SetValue(TargetStand or "Bo chon") return end; TargetStand = (Value == "Bo chon") and nil or Value end
    })
    local Drop_Trait = Tabs.AutoRoll:AddDropdown("Drop_Trait", {
        Title = "Target Trait", Values = flatTraits, Default = 1,
        Callback = function(Value) if string.find(Value, "^%-%-%-") then Drop_Trait:SetValue(TargetTrait or "Bo chon") return end; TargetTrait = (Value == "Bo chon") and nil or Value end
    })
    local Drop_Skin = Tabs.AutoRoll:AddDropdown("Drop_Skin", {
        Title = "Target Skin (Uu tien nhat)", Values = flatSkins, Default = 1,
        Callback = function(Value) TargetSkin = (Value == "Bo chon" or Value == nil) and nil or Value end
    })
    local Input_SkinSearch = Tabs.AutoRoll:AddInput("Input_SkinSearch", {
        Title = "Tim kiem Skin nhanh", Default = "", Placeholder = "Go ten Skin vao day de loc...",
        Callback = function(Value)
            local filtered = {"Bo chon"}
            for _, s in ipairs(SkinData) do if Value == "" or string.find(string.lower(s), string.lower(Value), 1, true) then table.insert(filtered, s) end end
            if Drop_Skin then Drop_Skin:SetValues(filtered) end
        end
    })
    Tabs.AutoRoll:AddToggle("Toggle_AutoRollTarget", {
        Title = "Auto Roll (Theo muc tieu Stand/Trait/Skin)", Default = false,
        Callback = function(Value) if Value then StartRollingProcess("Target") else isRolling = false; UpdateStatus("Da dung he thong.") end end
    })
    Tabs.AutoRoll:AddToggle("Toggle_AutoRollAnySkin", {
        Title = "Auto Roll Any Skin", Default = false,
        Callback = function(Value) if Value then StartRollingProcess("AnySkin") else isRolling = false; UpdateStatus("Da dung he thong.") end end
    })

    Tabs.AutoRoll:AddSection("2. ROLL THEO CHI SO (TUY CHON TUNG MUC)")
    Tabs.AutoRoll:AddDropdown("Drop_Str", { Title = "Target Strength", Values = targetVals, Default = 1, Callback = function(Value) TargetStr = (Value == "Bo chon") and nil or Value end })
    Tabs.AutoRoll:AddDropdown("Drop_Spd", { Title = "Target Speed", Values = targetVals, Default = 1, Callback = function(Value) TargetSpd = (Value == "Bo chon") and nil or Value end })
    Tabs.AutoRoll:AddDropdown("Drop_Spec", { Title = "Target Specialty", Values = targetVals, Default = 1, Callback = function(Value) TargetSpec = (Value == "Bo chon") and nil or Value end })
    Tabs.AutoRoll:AddToggle("Toggle_AutoRollCustomStat", {
        Title = "Auto Roll Stat (Tuy chon)", Default = false,
        Callback = function(Value) if Value then StartRollingProcess("CustomStat") else isRolling = false; UpdateStatus("Da dung he thong.") end end
    })

    Tabs.AutoRoll:AddSection("3. ROLL THEO CHI SO (DONG NHAT)")
    Tabs.AutoRoll:AddDropdown("Drop_AllStat", { Title = "Target All Stats (Dong nhat 3 muc)", Values = targetVals, Default = 1, Callback = function(Value) TargetAllStat = (Value == "Bo chon") and nil or Value end })
    Tabs.AutoRoll:AddToggle("Toggle_AutoRollAllStat", {
        Title = "Auto Roll Stat (Dong nhat)", Default = false,
        Callback = function(Value) if Value then StartRollingProcess("AllStat") else isRolling = false; UpdateStatus("Da dung he thong.") end end
    })

    Tabs.AutoRoll:AddSection("4. TRANG THAI & HIEN THI")
    Tabs.AutoRoll:AddToggle("Toggle_StatBoard", {
        Title = "Hien thi Bang Stat Nhan Vat", Default = false,
        Callback = function(Value) StatGui.Enabled = Value end
    })
    StatusPara = Tabs.AutoRoll:AddParagraph({ Title = "Trang Thai He Thong", Content = "Dang cho thiet lap..." })
end
