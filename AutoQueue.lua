return function(Fluent, Window, Tabs)
    local Players = game:GetService("Players")
    local LocalPlayer = Players.LocalPlayer
    local Camera = workspace.CurrentCamera

    local PvP_MainActive = false
    local PvP_AltActive = false
    local PvP_TargetName = ""
    local camLockConn = nil
    local camLockEnabled = false
    local fixedCamCF = nil   
    local currentBoard = nil
    local blacklistedBoards = {}
    local SetPvPStatus = function() end 

    local function ResetCharacter()
        pcall(function()
            local char = LocalPlayer.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then hum.Health = 0 end
        end)
    end

    local function StartCameraLock(board, boardCF)
        if not camLockEnabled then return end
        if camLockConn then camLockConn:Disconnect() camLockConn = nil end

        local boardCenter = boardCF.Position + Vector3.new(0, 1.5, 0)
        local bestCamPos = boardCenter + Vector3.new(0, 15, 0) 

        local params = RaycastParams.new()
        params.FilterType = Enum.RaycastFilterType.Exclude
        local ignoreList = {LocalPlayer.Character}
        if board then table.insert(ignoreList, board) end
        params.FilterDescendantsInstances = ignoreList

        local offsets = {
            boardCF.LookVector * 12 + Vector3.new(0, 10, 0),    
            -boardCF.LookVector * 12 + Vector3.new(0, 10, 0),   
            boardCF.RightVector * 12 + Vector3.new(0, 10, 0),   
            -boardCF.RightVector * 12 + Vector3.new(0, 10, 0),  
            Vector3.new(10, 12, 10),                            
            Vector3.new(-10, 12, 10),                           
            Vector3.new(10, 12, -10),                           
            Vector3.new(-10, 12, -10)                           
        }

        for _, offset in ipairs(offsets) do
            local testPos = boardCenter + offset
            local ray = workspace:Raycast(boardCenter, testPos - boardCenter, params)
            if not ray then bestCamPos = testPos break end
        end

        fixedCamCF = CFrame.lookAt(bestCamPos, boardCenter)
        Camera.CameraType = Enum.CameraType.Scriptable
        Camera.CFrame = fixedCamCF
    end

    local function StopCameraLock()
        if camLockConn then camLockConn:Disconnect() camLockConn = nil end
        fixedCamCF = nil; Camera.CameraType = Enum.CameraType.Custom
    end

    local function GetBoardCFrame(board)
        if board:IsA("Model") then return board:GetPivot() end
        if board:IsA("BasePart") then return board.CFrame end
        return nil
    end

    local function GetClosestBoard()
        if currentBoard and currentBoard.Parent and not blacklistedBoards[currentBoard] then return currentBoard end
        local root = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if not root then return nil end
        local closest = nil; local minDist = math.huge
        local searchArea = workspace:FindFirstChild("Map") or workspace
        for _, obj in ipairs(searchArea:GetDescendants()) do
            if obj.Name == "PvP Mission Board" and (obj:IsA("Model") or obj:IsA("BasePart")) and not blacklistedBoards[obj] then
                local cf = GetBoardCFrame(obj)
                if cf then
                    local dist = (root.Position - cf.Position).Magnitude
                    if dist < minDist then minDist = dist; closest = obj end
                end
            end
        end
        currentBoard = closest; return closest
    end

    local function PressBoard(board, rootPart)
        local cf = GetBoardCFrame(board)
        if not cf then return end
        if (rootPart.Position - cf.Position).Magnitude > 5 then
            rootPart.CFrame = cf * CFrame.new(0, 0, 0)
            rootPart.Velocity = Vector3.zero; task.wait(0.3)
        end
        local prompt = board:FindFirstChildWhichIsA("ProximityPrompt", true)
        if not prompt then return end
        if fireproximityprompt then
            pcall(fireproximityprompt, prompt); task.wait(0.3)
        else
            local oldH, oldD = prompt.HoldDuration, prompt.MaxActivationDistance
            pcall(function() prompt.HoldDuration = 0; prompt.MaxActivationDistance = 32 end)
            task.wait(); pcall(function() prompt:InputHoldBegin() end); task.wait(); pcall(function() prompt:InputHoldEnd() end)
            pcall(function() prompt.HoldDuration = oldH; prompt.MaxActivationDistance = oldD end)
        end
    end

    local function ProcessPvPQueue(mode)
        while (mode == "Main" and PvP_MainActive) or (mode == "Alt" and PvP_AltActive) do
            SetPvPStatus(mode .. ": chuan bi...")
            local char = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
            local root = char:WaitForChild("HumanoidRootPart", 10)
            local hum  = char:WaitForChild("Humanoid", 10)
            if not root or not hum or hum.Health <= 0 then task.wait(1) continue end
            local board = GetClosestBoard()
            if not board then SetPvPStatus("[ Loi ] Khong tim thay Board"); task.wait(3) continue end
            local boardCF = GetBoardCFrame(board)
            if board and boardCF then StartCameraLock(board, boardCF) end

            local joined = false; local conn
            local pg = LocalPlayer:FindFirstChild("PlayerGui")
            local holder = pg and pg:FindFirstChild("Notifications") and pg.Notifications:FindFirstChild("holder")
            if holder then
                conn = holder.ChildAdded:Connect(function(child)
                    local text = child.Name
                    local lbl = child:FindFirstChild("title")
                    if lbl and lbl:IsA("TextLabel") then text = lbl.Text end
                    if text:find("Joined PvP", 1, true) then joined = true end
                    if text:find("already in an active mission", 1, true) then ResetCharacter() end
                    if PvP_TargetName ~= "" and text:match("Your opponent is <font.->(.-)</font>") then
                        local opp = text:match("Your opponent is <font.->(.-)</font>")
                        if string.lower(opp) ~= string.lower(PvP_TargetName) then ResetCharacter() end
                    end
                end)
            end

            local attempt = 0
            while (mode == "Main" and PvP_MainActive or mode == "Alt" and PvP_AltActive) and not joined do
                if not root or hum.Health <= 0 then break end
                attempt = attempt + 1
                if attempt > 8 then SetPvPStatus("[ Canh bao ] Bang loi, doi bang..."); blacklistedBoards[board] = true; currentBoard = nil; break end
                SetPvPStatus(string.format("%s: an E... (lan %d)", mode, attempt))
                PressBoard(board, root); task.wait(0.5)
            end
            if conn then conn:Disconnect() end
            StopCameraLock()
            if not joined then continue end
            SetPvPStatus("[ Thanh cong ] " .. mode .. ": da vao hang!")

            local left = false
            local stopConn = (holder and holder.ChildAdded:Connect(function(child)
                local text = child.Name; local lbl = child:FindFirstChild("title")
                if lbl and lbl:IsA("TextLabel") then text = lbl.Text end
                if text:find("Left PvP", 1, true) then left = true end
            end))

            local elapsed = 0
            while (mode == "Main" and PvP_MainActive or mode == "Alt" and PvP_AltActive) and not left do
                if not root or hum.Health <= 0 then break end
                if (root.Position - boardCF.Position).Magnitude > 50 then left = true end
                task.wait(0.5); elapsed = elapsed + 0.5
                if elapsed > 120 then ResetCharacter(); break end
            end
            if stopConn then stopConn:Disconnect() end
            if mode == "Alt" and left then
                SetPvPStatus("[ Alt ] Thua - dang respawn...")
                task.wait(3); ResetCharacter()
            end
            task.wait(2)
        end
    end

    Tabs.PvP:AddSection("1. CHON CHE DO CAY PVP")
    local PvPStatusPara = Tabs.PvP:AddParagraph({ Title = "Trang Thai PvP", Content = "Cho bat..." })
    SetPvPStatus = function(txt) PvPStatusPara:SetDesc(txt) end

    Tabs.PvP:AddToggle("Toggle_PvPMain", {
        Title = "Main (Ben Thang)", Default = false,
        Callback = function(Value) PvP_MainActive = Value; if Value then task.spawn(ProcessPvPQueue, "Main") else SetPvPStatus("Main tat") end end
    })

    Tabs.PvP:AddToggle("Toggle_PvPAlt", {
        Title = "Alt (Ben Thua)", Default = false,
        Callback = function(Value) PvP_AltActive = Value; if Value then task.spawn(ProcessPvPQueue, "Alt") else SetPvPStatus("Alt tat") end end
    })

    Tabs.PvP:AddSection("2. CAI DAT MUC TIEU VA CAMERA")
    Tabs.PvP:AddInput("Input_PvPTarget", {
        Title = "Ten Muc Tieu", Default = "", Placeholder = "De trong = Ai cung ban", Numeric = false, Finished = false,
        Callback = function(Value) PvP_TargetName = Value end
    })

    Tabs.PvP:AddToggle("Toggle_PvPCamLock", {
        Title = "Lock Camera vao Board", Default = false,
        Callback = function(Value)
            camLockEnabled = Value
            if not Value then StopCameraLock() else
                local board = GetClosestBoard()
                local cf = board and GetBoardCFrame(board)
                if board and cf then StartCameraLock(board, cf) end
            end
        end
    })
end
