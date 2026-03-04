local WindUI = loadstring(game:HttpGet("https://github.com/Footagesus/WindUI/releases/latest/download/main.lua"))()

-- ====================================================
-- SERVIÇOS
-- ====================================================
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local localPlayer = Players.LocalPlayer
local catchEvent = ReplicatedStorage:WaitForChild("Events"):WaitForChild("CatchBall")

-- ====================================================
-- ESTADO GLOBAL DO SCRIPT
-- ====================================================
local state = {
    runningSounds = false,
    flying = false,
    flySpeed = 50,
    bodyVelocity = nil,
    bodyGyro = nil,
    -- Atributos
    walkSpeed = 16,
    jumpPower = 50,
    enforceHumanoid = true,
    -- Bigfoot (Pernas Reais Expandidas)
    bigfootEnabled = false,
    hitboxSize = 10,
    hitboxTransparency = 0.7
}

-- ====================================================
-- LÓGICA DO BIGFOOT (RUNSERVICE STEPPED)
-- ====================================================
-- O Stepped roda antes da física, impedindo que a colisão gigante te empurre
RunService.Stepped:Connect(function()
    local char = localPlayer.Character
    if char and state.bigfootEnabled then
        local legs = {
            char:FindFirstChild("Left Leg"), 
            char:FindFirstChild("Right Leg"),
            char:FindFirstChild("LeftLowerLeg"), -- R15
            char:FindFirstChild("RightLowerLeg") -- R15
        }

        for _, leg in pairs(legs) do
            if leg and leg:IsA("BasePart") then
                leg.Size = Vector3.new(state.hitboxSize, state.hitboxSize, state.hitboxSize)
                leg.Transparency = state.hitboxTransparency
                leg.CanCollide = false -- Impede de bugar no chão
                leg.Massless = true    -- Tira o peso da peça gigante
            end
        end
    end
end)

-- ====================================================
-- LOOP DE PERSISTÊNCIA (HUMANOID E RESET)
-- ====================================================
task.spawn(function()
    while true do
        local char = localPlayer.Character
        if char then
            local hum = char:FindFirstChild("Humanoid")
            
            -- Mantém WalkSpeed e JumpPower
            if hum and state.enforceHumanoid then
                hum.WalkSpeed = state.walkSpeed
                hum.UseJumpPower = true
                hum.JumpPower = state.jumpPower
            end

            -- Reseta as pernas quando o Bigfoot é desligado
            if not state.bigfootEnabled then
                local legs = {
                    char:FindFirstChild("Left Leg"), char:FindFirstChild("Right Leg"),
                    char:FindFirstChild("LeftLowerLeg"), char:FindFirstChild("RightLowerLeg")
                }
                for _, leg in pairs(legs) do
                    if leg and leg:IsA("BasePart") then
                        -- Só reseta se o tamanho estiver diferente do padrão
                        if leg.Size.Y > 2.1 or leg.Size.Y < 1 then 
                            leg.Transparency = 0
                            leg.CanCollide = true
                            if leg.Name:find("Lower") then
                                leg.Size = Vector3.new(1, 1, 1)
                            else
                                leg.Size = Vector3.new(1, 2, 1)
                            end
                        end
                    end
                end
            end
        end
        task.wait(0.3)
    end
end)

-- ====================================================
-- SISTEMA DE VOO (FLY)
-- ====================================================
local function toggleFly()
    state.flying = not state.flying
    local char = localPlayer.Character
    local humRoot = char and char:FindFirstChild("HumanoidRootPart")
    if not humRoot then return end

    if state.flying then
        local bv = Instance.new("BodyVelocity", humRoot)
        bv.Name = "SamlFly_Vel"
        bv.MaxForce = Vector3.new(1, 1, 1) * math.huge
        
        local bg = Instance.new("BodyGyro", humRoot)
        bg.Name = "SamlFly_Gyro"
        bg.MaxTorque = Vector3.new(1, 1, 1) * math.huge

        task.spawn(function()
            while state.flying do
                local camera = workspace.CurrentCamera
                local moveDir = Vector3.new(0,0,0)
                if UserInputService:IsKeyDown(Enum.KeyCode.W) then moveDir += camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.S) then moveDir -= camera.CFrame.LookVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.A) then moveDir -= camera.CFrame.RightVector end
                if UserInputService:IsKeyDown(Enum.KeyCode.D) then moveDir += camera.CFrame.RightVector end
                
                bv.Velocity = moveDir * state.flySpeed
                bg.CFrame = camera.CFrame
                task.wait()
            end
            bv:Destroy()
            bg:Destroy()
        end)
    end
end

-- ====================================================
-- INTERFACE (WindUI)
-- ====================================================
WindUI:Popup({
    Title = "SAML EXPLOIT",
    Content = "Script carregado com sucesso. Use os Inputs para configurar.",
    Buttons = { { Title = "OK", Variant = "Primary" } }
})

local Window = WindUI:CreateWindow({
    Title = "Saml Exploit Ultimate",
    Icon = "shield-check",
    Author = "by galerinhadozap",
    Size = UDim2.fromOffset(580, 460),
    KeySystem = { Key = { "FriendKey" }, Note = "Key System", SaveKey = true }
})

local TabExploits = Window:Tab({ Title = "Exploits", Icon = "bird" })
local TabHitbox = Window:Tab({ Title = "Hitbox", Icon = "maximize" })
local TabPlayer = Window:Tab({ Title = "Player", Icon = "user" })
local TabSettings = Window:Tab({ Title = "Settings", Icon = "settings" })

-- --- TAB EXPLOITS ---
TabExploits:Section({ Title = "Ações da Bola" })
TabExploits:Button({ Title = "Force Catch Ball (SAML)", Callback = function()
    local ball = Workspace:FindFirstChild("Debris") and Workspace.Debris:FindFirstChild("Balls") and Workspace.Debris.Balls:FindFirstChild("SAML")
    if ball then catchEvent:FireServer(ball) end
end })

TabExploits:Section({ Title = "Sons" })
TabExploits:Button({ Title = "Play All Sounds", Callback = function()
    for _, s in ipairs(Workspace:GetDescendants()) do if s:IsA("Sound") then s.Looped = true; pcall(function() s:Play() end) end end
end })

-- --- TAB HITBOX (BIGFOOT COM INPUT) ---
TabHitbox:Section({ Title = "Configuração do Bigfoot" })
TabHitbox:Toggle({ Title = "Ativar Bigfoot", Default = false, Callback = function(t) state.bigfootEnabled = t end })
TabHitbox:Input({ Title = "Tamanho da Hitbox", Placeholder = "Padrão: 10", Callback = function(v) state.hitboxSize = tonumber(v) or 10 end })
TabHitbox:Input({ Title = "Transparência (0-100)", Placeholder = "Padrão: 70", Callback = function(v) state.hitboxTransparency = (tonumber(v) or 70) / 100 end })

-- --- TAB PLAYER (INPUTS) ---
TabPlayer:Section({ Title = "Movimentação" })
TabPlayer:Input({ Title = "WalkSpeed", Placeholder = "16", Callback = function(v) state.walkSpeed = tonumber(v) or 16 end })
TabPlayer:Input({ Title = "JumpPower", Placeholder = "50", Callback = function(v) state.jumpPower = tonumber(v) or 50 end })
TabPlayer:Section({ Title = "Voo" })
TabPlayer:Toggle({ Title = "Ativar Fly", Callback = toggleFly })
TabPlayer:Input({ Title = "Velocidade do Voo", Placeholder = "50", Callback = function(v) state.flySpeed = tonumber(v) or 50 end })

-- --- TAB SETTINGS ---
TabSettings:Keybind({ Title = "Esconder Menu", Default = Enum.KeyCode.RightControl, Callback = function() Window:Toggle() end })
TabSettings:Button({ Title = "Unload Script", Color = Color3.fromHex("#ff4444"), Callback = function()
    state.enforceHumanoid = false; state.bigfootEnabled = false; state.flying = false
    Window:Close()
end })

WindUI:Notify({ Title = "Saml Exploit", Content = "Script pronto para uso!", Duration = 5 })
