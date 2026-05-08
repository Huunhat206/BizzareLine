return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local RunService = game:GetService("RunService") -- Dung de khoa Title muot hon
    local LocalPlayer = Players.LocalPlayer

    local TitleLoopActive = false
    local TitleLoopSpeed = 1.5 
    
    local CustomTitleActive = false
    local CustomTitleText = "TRÙM SERVER VIP"
    local titleConn = nil -- Ket noi de khoa Title

    -- =============================================
    -- LOGIC 1: TITLE LOOP (DANH HIEU CO SAN)
    -- =============================================
    local function ProcessTitleLoop()
        local currentIndex = 1
        local requests = ReplicatedStorage:FindFirstChild("requests")
        local showTitles = requests and requests:FindFirstChild("character") and requests.character:FindFirstChild("ShowTitles")
        local lastJsonString = ""
        local cachedTitles = {}
        
        while TitleLoopActive do
            if CustomTitleActive then break end -- Uu tien Custom Title neu dang bat
            pcall(function()
                local pData = LocalPlayer:FindFirstChild("PlayerData")
                if pData and pData:FindFirstChild("Titles") then
                    local currentJson = tostring(pData.Titles.Value)
                    if currentJson ~= lastJsonString then
                        local success, decodedTitles = pcall(HttpService.JSONDecode, HttpService, currentJson)
                        if success and type(decodedTitles) == "table" then
                            cachedTitles = decodedTitles
                            lastJsonString = currentJson
                        end
                    end
                    if #cachedTitles > 0 then
                        if currentIndex > #cachedTitles then currentIndex = 1 end
                        if showTitles then showTitles:FireServer(cachedTitles[currentIndex]) end
                        currentIndex = currentIndex + 1
                    end
                end
            end)
            task.wait(math.max(TitleLoopSpeed, 0.05))
        end
    end

    -- =============================================
    -- LOGIC 2: KHOA CUSTOM TITLE (CLIENT-SIDE)
    -- =============================================
    local function LockTitle()
        if titleConn then titleConn:Disconnect() end
        
        -- Dung RenderStepped de khoa ngay truoc khi khung hinh duoc ve ra
        titleConn = RunService.RenderStepped:Connect(function()
            if not CustomTitleActive then 
                if titleConn then titleConn:Disconnect() titleConn = nil end
                return 
            end

            local char = LocalPlayer.Character
            if char then
                for _, desc in ipairs(char:GetDescendants()) do
                    if desc:IsA("TextLabel") and desc.Text ~= "" then
                        local billboard = desc:FindFirstAncestorOfClass("BillboardGui")
                        if billboard then
                            -- Ep text luon la CustomTitleText
                            if desc.Text ~= CustomTitleText then
                                desc.Text = CustomTitleText
                            end
                        end
                    end
                end
            end
        end)
    end

    Tabs.Misc:AddSection("TU DONG DOI DANH HIEU (TITLE LOOP)")

    Tabs.Misc:AddToggle("Toggle_TitleLoop", {
        Title = "Kich hoat Title Loop",
        Description = "Xoay vong cac danh hieu ban dang so huu",
        Default = false,
        Callback = function(Value)
            TitleLoopActive = Value
            if Value then
                CustomTitleActive = false -- Tat Custom Title neu bat Loop
                task.spawn(ProcessTitleLoop)
            end
        end
    })

    Tabs.Misc:AddSlider("Slider_TitleSpeed", {
        Title = "Toc do doi (Giay)",
        Min = 0.1, Max = 5.0, Default = 1.5, Rounding = 1,
        Callback = function(Value) TitleLoopSpeed = Value end
    })

    Tabs.Misc:AddSection("DANH HIEU TUY CHINH (CLIENT-ONLY)")

    Tabs.Misc:AddInput("Input_CustomTitle", {
        Title = "Nhap ten danh hieu muon hien",
        Default = "TRÙM SERVER VIP",
        Callback = function(Value) CustomTitleText = Value end
    })

    Tabs.Misc:AddToggle("Toggle_LockTitle", {
        Title = "Khoa Custom Title",
        Description = "Ep danh hieu luon hien thi (Chi minh ban thay)",
        Default = false,
        Callback = function(Value)
            CustomTitleActive = Value
            if Value then
                TitleLoopActive = false -- Tat Loop neu bat Custom
                LockTitle()
            else
                if titleConn then titleConn:Disconnect() titleConn = nil end
            end
        end
    })
end
