local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- SERVIÇOS
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local lp = Players.LocalPlayer
local catchEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CatchBall")

local state = {
    speed = 16, jump = 50,
    fly = false, flySpd = 50,
    bigfoot = false, bfSize = 10, bfTrans = 0.7
}

RunService.Stepped:Connect(function()
    local char = lp.Character
    if not char then return end
    
    local hum = char:FindFirstChildOfClass("Humanoid")
    if hum then
        hum.WalkSpeed = state.speed
        hum.JumpPower = state.jump
        hum.UseJumpPower = true
    end

    if state.bigfoot then
        for _, v in ipairs(char:GetChildren()) do
            if v:IsA("BasePart") and (v.Name:find("Leg") or v.Name:find("Foot")) then
                v.Size = Vector3.new(state.bfSize, state.bfSize, state.bfSize)
                v.Transparency = state.bfTrans
                v.CanCollide = false
                v.Massless = true
            end
        end
    end
end)

-- SISTEMA DE VOO
local function handleFly()
    local root = lp.Character and lp.Character:FindFirstChild("HumanoidRootPart")
    if not root or not state.fly then return end
    
    local bv = Instance.new("BodyVelocity", root)
    local bg = Instance.new("BodyGyro", root)
    bv.MaxForce, bg.MaxTorque = Vector3.new(1,1,1)*1e6, Vector3.new(1,1,1)*1e6

    task.spawn(function()
        while state.fly and root.Parent do
            local cam = workspace.CurrentCamera.CFrame
            local dir = Vector3.zero
            if UserInputService:IsKeyDown("W") then dir += cam.LookVector end
            if UserInputService:IsKeyDown("S") then dir -= cam.LookVector end
            if UserInputService:IsKeyDown("A") then dir -= cam.RightVector end
            if UserInputService:IsKeyDown("D") then dir += cam.RightVector end
            
            bv.Velocity = dir * state.flySpd
            bg.CFrame = cam
            task.wait()
        end
        bv:Destroy(); bg:Destroy()
    end)
end

local Window = WindUI:CreateWindow({
    Title = "MPS ULTIMATE EXPLOIT TOOL",
    Icon = "zap",
    Author = "by galerinhadozap",
    Size = UDim2.fromOffset(550, 500)
})

-- ABAS
local TabCBM = Window:Tab({ Title = "CBM", Icon = "target" })
local TabSAML = Window:Tab({ Title = "SAML", Icon = "box" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

TabCBM:Section({ Title = "Módulo CBM" })
TabCBM:Paragraph({ Title = "Aguardando Implementação", Content = "Esta categoria está pronta para novos scripts CBM." })

TabSAML:Section({ Title = "Ações Automáticas" })
TabSAML:Button({ Title = "Force Catch Ball", Callback = function()
    local ball = workspace:FindFirstChild("SAML", true) or workspace:FindFirstChild("Ball", true)
    if ball then catchEvent:FireServer(ball) end
end })

TabSAML:Button({ Title = "Play All Sounds (Troll)", Callback = function()
    for _, s in ipairs(workspace:GetDescendants()) do 
        if s:IsA("Sound") then s.Looped = true; pcall(function() s:Play() end) end 
    end
end })

TabSAML:Section({ Title = "Visual & Hitbox" })
TabSAML:Toggle({ Title = "Bigfoot Mode", Callback = function(v) state.bigfoot = v end })
TabSAML:Slider({ Title = "Tamanho Hitbox", Min = 2, Max = 50, Default = 10, Callback = function(v) state.bfSize = v end })

TabSettings:Section({ Title = "Movimentação" })
TabSettings:Slider({ Title = "WalkSpeed", Min = 16, Max = 200, Default = 16, Callback = function(v) state.speed = v end })
TabSettings:Slider({ Title = "JumpPower", Min = 50, Max = 300, Default = 50, Callback = function(v) state.jump = v end })

TabSettings:Section({ Title = "Voo (Fly)" })
TabSettings:Toggle({ Title = "Ativar Fly", Callback = function(v) state.fly = v; if v then handleFly() end end })
TabSettings:Slider({ Title = "Velocidade Fly", Min = 10, Max = 300, Default = 50, Callback = function(v) state.flySpd = v end })

TabSettings:Section({ Title = "Menu Config" })
TabSettings:Keybind({ Title = "Esconder Menu", Default = Enum.KeyCode.RightControl, Callback = function() Window:Toggle() end })
TabSettings:Button({ Title = "Unload Script", Color = Color3.fromHex("#ff4444"), Callback = function() Window:Close() end })

WindUI:Notify({ Title = "Carregado", Content = "Script SAML pronto!", Duration = 3 })
