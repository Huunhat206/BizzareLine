return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local TeleportService = game:GetService("TeleportService")
    local LocalPlayer = Players.LocalPlayer

    local AutoLootActive = false
    local AutoHopActive = false

    -- Danh sach ten cac vat pham hop le trong game
    local ValidItemNames = {
        "Stand Arrow", "Stone Mask", "Rokakaka", "Pure Rokakaka", 
        "Vampire Mask", "Mysterious Bow", "Ribcage of the Saint's Corpse", 
        "Dio's Bone", "Dio's Diary", "Heart of the Saint's Corpse", 
        "Left Arm of the Saint's Corpse", "Right Arm of the Saint's Corpse"
    }

    local function isItemValid(name)
        for _, v in ipairs(ValidItemNames) do
            if v == name then return true end
        end
        return false
    end

    local function getItemAmount(itemName)
        local amount = "Khong ro"
        pcall(function()
            local pData = LocalPlayer:FindFirstChild("PlayerData")
            if not pData then return end
            local invValue = pData.SlotData.Inventory.Value
            local inventoryData = HttpService:JSONDecode(invValue)
            for _, item in ipairs(inventoryData) do
                if type(item) == "table" and item.Name == itemName then
                    amount = item.Amount
                    break
                end
            end
        end)
        return amount
    end

    local function sendItemWebhook(itemName)
        local whUrl = getgenv().NthucHub_ItemWebhook
        if not whUrl or whUrl == "" or whUrl == "YOUR_WEBHOOK_URL_HERE" then return end

        local currentAmount = getItemAmount(itemName)
        local data = {
            ["content"] = "",
            ["embeds"] = {{
                ["title"] = "[ LOOT THANH CONG ]",
                ["description"] = "Vua nhat duoc: **" .. itemName .. "**\nSo luong " .. itemName .. " hien co: **" .. tostring(currentAmount) .. "**",
                ["color"] = 65280
            }}
        }

        local req = (syn and syn.request) or (http and http.request) or http_request or (fluxus and fluxus.request) or request
        if req then
            pcall(req, {
                Url = whUrl,
                Method = "POST",
                Headers = {["Content-Type"] = "application/json"},
                Body = HttpService:JSONEncode(data)
            })
        end
    end

    local function getTargetCFrame(itemObj)
        if itemObj:IsA("Model") then return itemObj:GetPivot() end
        if itemObj:IsA("BasePart") then return itemObj.CFrame end
        return nil
    end

    local function interactWithItem(itemObj)
        local prompt = itemObj:FindFirstChildWhichIsA("ProximityPrompt", true)
        if prompt then
            if fireproximityprompt then
                pcall(fireproximityprompt, prompt, 1, true)
            else
                pcall(function() prompt:InputHoldBegin() end)
                task.wait(prompt.HoldDuration > 0 and prompt.HoldDuration or 5.2)
                pcall(function() prompt:InputHoldEnd() end)
            end
        end
    end

    local function hopServer()
        local placeId = game.PlaceId
        local jobId = game.JobId
        local url = "https://games.roblox.com/v1/games/" .. tostring(placeId) .. "/servers/Public?sortOrder=Asc&limit=100"

        local success, result = pcall(function() return game:HttpGet(url) end)
        if success and result then
            local data = HttpService:JSONDecode(result)
            if data and data.data then
                for _, server in ipairs(data.data) do
                    if server.playing > 0 and server.playing < server.maxPlayers and server.id ~= jobId then
                        TeleportService:TeleportToPlaceInstance(placeId, server.id, LocalPlayer)
                        task.wait(5)
                        break
                    end
                end
            end
        end
    end

    local function processAutoLoot()
        while AutoLootActive do
            task.wait(1)
            local foundItem = false
            
            local char = LocalPlayer.Character
            if not char or not char:FindFirstChild("HumanoidRootPart") then
                pcall(function() game:GetService("ReplicatedStorage").requests.character.spawn:FireServer() end)
                task.wait(3)
                char = LocalPlayer.Character
            end

            local rootPart = char and char:FindFirstChild("HumanoidRootPart")
            if not rootPart then continue end

            for _, descendant in ipairs(workspace:GetDescendants()) do
                if not AutoLootActive then break end
                
                if isItemValid(descendant.Name) then
                    -- Chi chap nhan Item co ProximityPrompt (khong phai Item rong)
                    local prompt = descendant:FindFirstChildWhichIsA("ProximityPrompt", true)
                    if prompt then
                        foundItem = true
                        local targetCF = getTargetCFrame(descendant)
                        if targetCF then
                            rootPart.CFrame = targetCF
                            task.wait(0.5)
                            interactWithItem(descendant)
                            task.wait(1)
                            
                            -- Ban webhook
                            task.spawn(function() sendItemWebhook(descendant.Name) end)
                        end
                    end
                end
            end

            if not foundItem then
                if AutoHopActive then
                    Fluent:Notify({ Title = "Auto Hop", Content = "Da nhat het Item, dang chuyen Server...", Duration = 3 })
                    hopServer()
                    task.wait(10)
                else
                    -- Neu chi bat Auto Loot ma khong bat Hop, cho 2 giay roi quet tiep
                    task.wait(2)
                end
            end
        end
    end

    Tabs.Items:AddSection("TU DONG NHAT ITEM")
    
    Tabs.Items:AddToggle("Toggle_AutoLoot", {
        Title = "Auto Loot Items",
        Description = "Tu dong tim va nhat cac item (Bo qua item rong)",
        Default = false,
        Callback = function(Value)
            AutoLootActive = Value
            if Value then task.spawn(processAutoLoot) end
        end
    })

    Tabs.Items:AddToggle("Toggle_AutoHop", {
        Title = "Auto Hop (Khi het Item)",
        Description = "Chuyen sang Server khac neu Server hien tai da bi nhat sach Item",
        Default = false,
        Callback = function(Value)
            AutoHopActive = Value
        end
    })

    -- Bo sung o nhap Webhook rieng cho phan Item vao tab Webhook
    Tabs.Webhook:AddSection("WEBHOOK THONG BAO ITEM")
    Tabs.Webhook:AddInput("Input_ItemWebhook", {
        Title = "Discord Webhook (Loot Items)",
        Default = getgenv().NthucHub_ItemWebhook,
        Placeholder = "Nhap Webhook URL vao day...",
        Numeric = false, Finished = false,
        Callback = function(Value) getgenv().NthucHub_ItemWebhook = Value end
    })
end
