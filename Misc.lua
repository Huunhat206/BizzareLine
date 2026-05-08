return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local HttpService = game:GetService("HttpService")
    local ReplicatedStorage = game:GetService("ReplicatedStorage")
    local LocalPlayer = Players.LocalPlayer

    local TitleLoopActive = false
    local TitleLoopSpeed = 1.5 
    local CustomTitleText = "Hacker Chua" -- Mac dinh

    local function ProcessTitleLoop()
        local currentIndex = 1
        local requests = ReplicatedStorage:FindFirstChild("requests")
        local showTitles = requests and requests:FindFirstChild("character") and requests.character:FindFirstChild("ShowTitles")
        
        local lastJsonString = ""
        local cachedTitles = {}
        
        while TitleLoopActive do
            pcall(function()
                local pData = LocalPlayer:FindFirstChild("PlayerData")
                if not pData then return end
                
                local titlesObj = pData:FindFirstChild("Titles")
                if titlesObj and titlesObj.Value then
                    local currentJson = tostring(titlesObj.Value)
                    
                    if currentJson ~= lastJsonString then
                        local success, decodedTitles = pcall(HttpService.JSONDecode, HttpService, currentJson)
                        if success and type(decodedTitles) == "table" and #decodedTitles > 0 then
                            cachedTitles = decodedTitles
                            lastJsonString = currentJson
                        end
                    end
                    
                    if #cachedTitles > 0 then
                        if currentIndex > #cachedTitles then
                            currentIndex = 1
                        end
                        
                        local currentTitle = cachedTitles[currentIndex]
                        
                        if showTitles then
                            showTitles:FireServer(currentTitle)
                        end
                        
                        currentIndex = currentIndex + 1
                    end
                end
            end)
            
            task.wait(math.max(TitleLoopSpeed, 0.05))
        end
    end

    -- =============================================
    -- SECTION 1: TITLE LOOP (Da toi uu chong lag)
    -- =============================================
    Tabs.Misc:AddSection("TU DONG DOI DANH HIEU (TITLE LOOP)")

    Tabs.Misc:AddToggle("Toggle_TitleLoop", {
        Title = "Kich hoat Title Loop",
        Description = "Tu dong xoay vong cac danh hieu ban dang so huu tren dau",
        Default = false,
        Callback = function(Value)
            TitleLoopActive = Value
            if Value then
                task.spawn(ProcessTitleLoop)
            end
        end
    })

    Tabs.Misc:AddSlider("Slider_TitleSpeed", {
        Title = "Toc do doi danh hieu (Giay)",
        Description = "Khoang thoi gian giua 2 lan doi (Khuyen nghi: 1.5s - 2s)",
        Min = 0.1,
        Max = 5.0,
        Default = 1.5,
        Rounding = 1,
        Callback = function(Value)
            TitleLoopSpeed = Value
        end
    })

    -- =============================================
    -- SECTION 2: CUSTOM TITLE (Tu tao danh hieu)
    -- =============================================
    Tabs.Misc:AddSection("DANH HIEU TUY CHINH (CUSTOM TITLE)")

    Tabs.Misc:AddInput("Input_CustomTitle", {
        Title = "Nhap ten danh hieu muon tao",
        Default = "Hacker Chua",
        Placeholder = "Nhap chu gi do vao day...",
        Numeric = false,
        Finished = false,
        Callback = function(Value)
            CustomTitleText = Value
        end
    })

    Tabs.Misc:AddButton({
        Title = "Cai dat Custom Title",
        Description = "Test xem server co cho phep tao danh hieu ao khong",
        Callback = function()
            pcall(function()
                local requests = ReplicatedStorage:FindFirstChild("requests")
                if requests and requests:FindFirstChild("character") then
                    local showTitles = requests.character:FindFirstChild("ShowTitles")
                    if showTitles then
                        -- Gui text tu che len server
                        showTitles:FireServer(CustomTitleText)
                    end
                end
            end)
        end
    })
end
