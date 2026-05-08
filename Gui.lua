-- ==========================================
-- 1. TU TAT BANG CU VA TAO MOI TRUONG
-- ==========================================
if getgenv().NthucHub_UI then pcall(function() getgenv().NthucHub_UI:Destroy() end) end

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- ANTI-AFK
LocalPlayer.Idled:Connect(function()
    VirtualUser:CaptureController()
    VirtualUser:ClickButton2(Vector2.new())
end)

-- GETGENV Bien dung chung cho tat ca Module
if not getgenv().NthucHub_WebhookURL then getgenv().NthucHub_WebhookURL = "https://discord.com/api/webhooks/1498312008041496677/bwkREm2-7DhiHjn70oMAIzHyxij6rplXnvg2GmtHTCGfxKlbyGn7iKWNEy7qW0G1cETh" end
if not getgenv().NthucHub_ItemWebhook then getgenv().NthucHub_ItemWebhook = "https://discord.com/api/webhooks/1477932375320297533/H0fl2KAjMQgaVRAK7tDnPszEOI9FpuUhfeU7Wa_jnft6XtBmzeKEsXyWAqzrZ3O-xsmN" end

-- ==========================================
-- 2. LOAD FLUENT UI KICH THUOC TOI UU DPI
-- ==========================================
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()

getgenv().NthucHub_UI = Fluent

local Window = Fluent:CreateWindow({
    Title = "Nthuc Hub",
    SubTitle = "Auto Arrow & PvP Hunter",
    TabWidth = 140,
    Size = UDim2.fromOffset(500, 380),
    Acrylic = true,
    Theme = "Dark"
})

local Tabs = {
    AutoRoll = Window:AddTab({ Title = "Auto Arrow", Icon = "target" }),
    Items    = Window:AddTab({ Title = "Auto Items", Icon = "box" }),
    Event    = Window:AddTab({ Title = "World Event", Icon = "star" }),
    PvP      = Window:AddTab({ Title = "PvP Queue", Icon = "swords" }),
    Teleport = Window:AddTab({ Title = "Teleport", Icon = "map" }),
    Webhook  = Window:AddTab({ Title = "Webhook", Icon = "link" }),
    Settings = Window:AddTab({ Title = "Cai Dat Hub", Icon = "settings" })
}

-- NUT TOGGLE KEO THA (N BUTTON)
local guiTarget = pcall(function() return gethui() end) and gethui() or game:GetService("CoreGui")

local ToggleGui = Instance.new("ScreenGui")
ToggleGui.Name = "NthucHub_Toggle"
ToggleGui.ResetOnSpawn = false
ToggleGui.DisplayOrder = 999999
ToggleGui.Parent = guiTarget
getgenv().NthucHub_ToggleButton = ToggleGui

local Btn = Instance.new("TextButton")
Btn.Size = UDim2.new(0, 45, 0, 45)
Btn.Position = UDim2.new(0.5, -22.5, 0, 10)
Btn.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Btn.Text = "N"
Btn.Font = Enum.Font.GothamBold
Btn.TextSize = 22
Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
Btn.AutoButtonColor = true
Btn.Parent = ToggleGui
Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
local stroke = Instance.new("UIStroke")
stroke.Color = Color3.fromRGB(150, 150, 150)
stroke.Thickness = 1.5
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Parent = Btn

local dragging, dragInput, dragStart, startPos
Btn.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
        dragging = true; dragStart = input.Position; startPos = Btn.Position
        input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
    end
end)
Btn.InputChanged:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
end)
UserInputService.InputChanged:Connect(function(input)
    if input == dragInput and dragging then
        local delta = input.Position - dragStart
        Btn.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
end)

local clickTime = 0
Btn.MouseButton1Down:Connect(function() clickTime = tick() end)
Btn.MouseButton1Up:Connect(function()
    if tick() - clickTime < 0.2 then
        VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.LeftControl, false, game)
        task.wait(0.05)
        VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.LeftControl, false, game)
    end
end)

-- ==========================================
-- 3. CHINH SUA TAB WEBHOOK
-- ==========================================
Tabs.Webhook:AddSection("WEBHOOK AUTO ARROW & PVP")
Tabs.Webhook:AddInput("Input_MainWebhook", {
    Title = "Discord Webhook (Arrow/PvP)",
    Default = getgenv().NthucHub_WebhookURL,
    Placeholder = "Nhap Webhook URL vao day...",
    Numeric = false, Finished = false,
    Callback = function(Value) getgenv().NthucHub_WebhookURL = Value end
})

-- ==========================================
-- 4. HE THONG TAI MODULE TU GITHUB
-- ==========================================
local repoBaseUrl = "https://raw.githubusercontent.com/Huunhat206/BizzareLine/main/"

-- Ham ho tro tai module
local function LoadModule(fileName)
    local success, moduleLogic = pcall(function()
        return loadstring(game:HttpGet(repoBaseUrl .. fileName))()
    end)
    
    if success and moduleLogic then
        pcall(function() moduleLogic(Fluent, Window, Tabs) end)
    else
        warn("[Nthuc Hub] Khong the tai module: " .. fileName)
    end
end

-- Tai cac module chuc nang
LoadModule("Autoarrow.lua")
LoadModule("AutoItems.lua")
LoadModule("AutoEvent.lua")
LoadModule("AutoQueue.lua")
LoadModule("Teleport.lua")

-- ==========================================
-- 5. SETUP HE THONG LUU CONFIG
-- ==========================================
SaveManager:SetLibrary(Fluent)
InterfaceManager:SetLibrary(Fluent)
SaveManager:IgnoreThemeSettings()
SaveManager:SetIgnoreIndexes({})
InterfaceManager:SetFolder("NthucHub")
SaveManager:SetFolder("NthucHub/GameConfig")

InterfaceManager:BuildInterfaceSection(Tabs.Settings)
SaveManager:BuildConfigSection(Tabs.Settings)

local isAutoSaving = false
Tabs.Settings:AddToggle("Toggle_AutoSave", {
    Title = "Tu dong luu Config (Auto Save)", Default = false,
    Callback = function(Value) isAutoSaving = Value end
})

task.spawn(function()
    while task.wait(30) do
        if isAutoSaving then
            local configName = SaveManager.CurrentConfig
            if not configName or configName == "" then configName = "AutoSave_Default" end
            pcall(function() SaveManager:Save(configName) end)
        end
    end
end)

Window:SelectTab(1)
SaveManager:LoadAutoloadConfig()
Fluent:Notify({ Title = "Nthuc Hub", Content = "Da tai giao dien thanh cong!", Duration = 3 })
