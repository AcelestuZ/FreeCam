-- File: Freecam.lua
-- Powered by Main.gui Universal Library

local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/YOUR_USERNAME/YOUR_REPO/main/Main.gui"))()

local Players = game:GetService("Players")
local LP = Players.LocalPlayer
local Cam = workspace.CurrentCamera
local RS = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local StarterGui = game:GetService("StarterGui")

_G.A = _G.A or {}
local A = _G.A

A.SavedGuis = {}
A.SavedCoreGuis = {}
A.SavedJumpButtons = {}
A.SavedThumbsticks = {}
A.HideEverything = false
A.Enabled = false
A.Speed = 1
A.Smoothness = 12
A.Rot = Vector2.new(0, 0)
A.Velocity = Vector3.new(0, 0, 0)
A.StartPos = nil
A.CurrentMovePos = nil
A.CurrentMoveVec = Vector2.new(0, 0)
A.VerticalMove = 0
A.TargetFOV = 70
A.DefaultFOV = Cam and Cam.FieldOfView or 70

if not A.OrigLighting then
	A.OrigLighting = {
		Brightness = Lighting.Brightness,
		GlobalShadows = Lighting.GlobalShadows,
		FogEnd = Lighting.FogEnd,
		Ambient = Lighting.Ambient,
		OutdoorAmbient = Lighting.OutdoorAmbient
	}
end

local Window = Library:CreateWindow({
	Title = "FREECAM",
	Name = "Freecam_AcelestuZ_V0.5",
	ToggleKey = Enum.KeyCode.H,
	FloatingButton = UIS.TouchEnabled,
	FloatText = "FC",
	StartOpen = false
})

local ScreenGui = Window.ScreenGui

local MovePad = Instance.new("Frame", ScreenGui)
MovePad.Size = UDim2.new(0.45, 0, 1, 0)
MovePad.BackgroundTransparency = 1
MovePad.Visible = false

local JoystickOuter = Instance.new("Frame", MovePad)
JoystickOuter.Size = UDim2.new(0, 110, 0, 110)
JoystickOuter.AnchorPoint = Vector2.new(0.5, 0.5)
JoystickOuter.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
JoystickOuter.BackgroundTransparency = 0.5
JoystickOuter.Visible = false
Instance.new("UICorner", JoystickOuter).CornerRadius = UDim.new(1, 0)
local joyStroke = Instance.new("UIStroke", JoystickOuter)
joyStroke.Color = Color3.fromRGB(0, 170, 255)
joyStroke.Thickness = 1.5
joyStroke.Transparency = 0.3

local JoystickKnob = Instance.new("Frame", JoystickOuter)
JoystickKnob.Size = UDim2.new(0, 44, 0, 44)
JoystickKnob.AnchorPoint = Vector2.new(0.5, 0.5)
JoystickKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
JoystickKnob.BackgroundColor3 = Color3.fromRGB(0, 170, 255)
JoystickKnob.BackgroundTransparency = 0.2
Instance.new("UICorner", JoystickKnob).CornerRadius = UDim.new(1, 0)

local VertPad = Instance.new("Frame", ScreenGui)
VertPad.Size = UDim2.new(0, 50, 0, 110)
VertPad.Position = UDim2.new(1, -70, 0.65, -55)
VertPad.BackgroundTransparency = 1
VertPad.Visible = false

local function CreateVertBtn(text, posY)
	local b = Instance.new("TextButton", VertPad)
	b.Size = UDim2.new(1, 0, 0, 48)
	b.Position = UDim2.new(0, 0, 0, posY)
	b.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
	b.BackgroundTransparency = 0.3
	b.Text = text
	b.TextColor3 = Color3.new(1, 1, 1)
	b.Font = Enum.Font.GothamBold
	b.TextSize = 14
	Instance.new("UICorner", b).CornerRadius = UDim.new(0, 10)
	local st = Instance.new("UIStroke", b)
	st.Color = Color3.fromRGB(0, 170, 255)
	st.Thickness = 1
	st.Transparency = 0.4
	return b
end

local UpBtn = CreateVertBtn("UP", 0)
local DownBtn = CreateVertBtn("DN", 60)

function A.SetGameUIHidden(hide)
	local pGui = LP:FindFirstChildOfClass("PlayerGui")
	local coreTypes = {
		Enum.CoreGuiType.PlayerList,
		Enum.CoreGuiType.Health,
		Enum.CoreGuiType.Backpack,
		Enum.CoreGuiType.Chat,
		Enum.CoreGuiType.EmotesMenu
	}

	if hide then
		A.SavedGuis = {}
		A.SavedCoreGuis = {}
		A.SavedJumpButtons = {}
		A.SavedThumbsticks = {}

		if pGui then
			for _, desc in pairs(pGui:GetDescendants()) do
				if not (ScreenGui and desc:IsDescendantOf(ScreenGui)) then
					if desc.Name == "JumpButton" and (desc:IsA("ImageButton") or desc:IsA("ImageLabel")) then
						A.SavedJumpButtons[desc] = desc.ImageTransparency
						desc.ImageTransparency = 1
					elseif desc.Name == "DynamicThumbstickFrame" and desc:IsA("GuiObject") then
						if desc.Visible == true then
							A.SavedThumbsticks[desc] = true
							desc.Visible = false
						end
					end
				end
			end

			for _, gui in pairs(pGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui ~= ScreenGui then
					local hasMobileControls = (gui.Name == "TouchGui")
						or (gui:FindFirstChild("JumpButton", true) ~= nil)
						or (gui:FindFirstChild("DynamicThumbstickFrame", true) ~= nil)

					if not hasMobileControls and gui.Enabled == true then
						A.SavedGuis[gui] = true
						gui.Enabled = false
					end
				end
			end
		end

		for _, cType in ipairs(coreTypes) do
			pcall(function()
				if StarterGui:GetCoreGuiEnabled(cType) then
					A.SavedCoreGuis[cType] = true
					StarterGui:SetCoreGuiEnabled(cType, false)
				end
			end)
		end
	else
		for btn, origTrans in pairs(A.SavedJumpButtons) do
			if btn and btn.Parent then btn.ImageTransparency = origTrans end
		end
		A.SavedJumpButtons = {}

		for frame, wasVisible in pairs(A.SavedThumbsticks) do
			if wasVisible and frame and frame.Parent then frame.Visible = true end
		end
		A.SavedThumbsticks = {}

		for gui, wasVisible in pairs(A.SavedGuis) do
			if wasVisible and gui and gui.Parent then gui.Enabled = true end
		end
		A.SavedGuis = {}

		for cType, wasEnabled in pairs(A.SavedCoreGuis) do
			if wasEnabled then
				pcall(function() StarterGui:SetCoreGuiEnabled(cType, true) end)
			end
		end
		A.SavedCoreGuis = {}
	end
end

function A.SetCharacterControls(enabled)
	local pGui = LP:FindFirstChildOfClass("PlayerGui")
	local touchGui = pGui and pGui:FindFirstChild("TouchGui")
	if touchGui then
		if not enabled then
			A.TouchGuiWasEnabled = touchGui.Enabled
			touchGui.Enabled = false
		else
			if A.TouchGuiWasEnabled ~= false then
				touchGui.Enabled = true
			end
		end
	end

	local char = LP.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")
	if hum then
		if not enabled then
			A.SavedWalkSpeed = (hum.WalkSpeed > 0) and hum.WalkSpeed or 16
			hum.WalkSpeed = 0
		else
			hum.WalkSpeed = A.SavedWalkSpeed or 16
		end
	end
end

function A.TeleportToGround(targetPos)
	local char = LP.Character
	local hrp = char and char:FindFirstChild("HumanoidRootPart")
	if hrp then
		local rayParams = RaycastParams.new()
		rayParams.FilterDescendantsInstances = {char, Cam}
		rayParams.FilterType = Enum.RaycastFilterType.Exclude
		local res = workspace:Raycast(targetPos, Vector3.new(0, -500, 0), rayParams)
		local rot = hrp.CFrame - hrp.CFrame.Position
		if res then
			hrp.CFrame = CFrame.new(res.Position + Vector3.new(0, 3.5, 0)) * rot
		else
			hrp.CFrame = CFrame.new(targetPos) * rot
		end
		hrp.AssemblyLinearVelocity = Vector3.new(0, 0, 0)
		hrp.AssemblyAngularVelocity = Vector3.new(0, 0, 0)
	end
end

local StatusToggle

function A.Reset()
	A.Enabled = false
	A.StartPos = nil
	A.CurrentMovePos = nil
	A.CurrentMoveVec = Vector2.new(0, 0)
	A.VerticalMove = 0
	A.Velocity = Vector3.new(0, 0, 0)

	if UIS.MouseBehavior == Enum.MouseBehavior.LockCurrentPosition then
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end

	if StatusToggle then
		StatusToggle:Set(false, false)
	end

	MovePad.Visible = false
	VertPad.Visible = false

	pcall(function() A.SetCharacterControls(true) end)

	Cam = workspace.CurrentCamera
	if Cam then
		Cam.CameraType = Enum.CameraType.Custom
		Cam.FieldOfView = A.DefaultFOV or 70
	end

	if LP.Character then
		local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
		if hrp then hrp.Anchored = false end
		local animate = LP.Character:FindFirstChild("Animate")
		if animate then animate.Enabled = true end
	end
end

local function GetPCMoveVector()
	if UIS:GetFocusedTextBox() then
		return Vector3.new(0, 0, 0), 1
	end
	local x, y, z = 0, 0, 0
	if UIS:IsKeyDown(Enum.KeyCode.D) or UIS:IsKeyDown(Enum.KeyCode.Right) then x = x + 1 end
	if UIS:IsKeyDown(Enum.KeyCode.A) or UIS:IsKeyDown(Enum.KeyCode.Left) then x = x - 1 end
	if UIS:IsKeyDown(Enum.KeyCode.W) or UIS:IsKeyDown(Enum.KeyCode.Up) then z = z + 1 end
	if UIS:IsKeyDown(Enum.KeyCode.S) or UIS:IsKeyDown(Enum.KeyCode.Down) then z = z - 1 end
	if UIS:IsKeyDown(Enum.KeyCode.E) or UIS:IsKeyDown(Enum.KeyCode.Space) then y = y + 1 end
	if UIS:IsKeyDown(Enum.KeyCode.Q) or UIS:IsKeyDown(Enum.KeyCode.LeftControl) then y = y - 1 end

	local boost = (UIS:IsKeyDown(Enum.KeyCode.LeftShift) or UIS:IsKeyDown(Enum.KeyCode.RightShift)) and 2.5 or 1
	return Vector3.new(x, y, z), boost
end

function A.UpdateCamera(dt)
	if not A.Enabled then return end
	Cam = workspace.CurrentCamera
	if not Cam then return end

	Cam.CameraType = Enum.CameraType.Scriptable

	if A.StartPos and A.CurrentMovePos then
		local diff = A.CurrentMovePos - A.StartPos
		if diff.Magnitude > 2 then
			A.CurrentMoveVec = diff.Unit * (math.min(diff.Magnitude, 60) / 60)
		else
			A.CurrentMoveVec = Vector2.new(0, 0)
		end
	else
		A.CurrentMoveVec = Vector2.new(0, 0)
	end

	local pcVec, boost = GetPCMoveVector()
	local moveX = math.clamp(pcVec.X + A.CurrentMoveVec.X, -1, 1)
	local moveZ = math.clamp(pcVec.Z - A.CurrentMoveVec.Y, -1, 1)
	local moveY = math.clamp(pcVec.Y + A.VerticalMove, -1, 1)

	local targetInput = Vector3.new(moveX, moveY, moveZ)
	if targetInput.Magnitude > 1 then
		targetInput = targetInput.Unit
	end

	local alpha = math.clamp(dt * (A.Smoothness or 12), 0, 1)
	A.Velocity = A.Velocity:Lerp(targetInput * boost, alpha)

	local pitch = math.clamp(A.Rot.X, -math.rad(89), math.rad(89))
	A.Rot = Vector2.new(pitch, A.Rot.Y)

	local rotCFrame = CFrame.fromEulerAnglesYXZ(A.Rot.X, A.Rot.Y, 0)
	local cf = Cam.CFrame
	local moveDir = (rotCFrame.LookVector * A.Velocity.Z)
		+ (rotCFrame.RightVector * A.Velocity.X)
		+ (Vector3.new(0, 1, 0) * A.Velocity.Y)

	local newPos = cf.Position + (moveDir * (A.Speed * dt * 60))
	Cam.CFrame = CFrame.new(newPos) * rotCFrame
	Cam.FieldOfView = A.TargetFOV
end

Window:OnDestroy(function()
	if A.IdleTrack then
		pcall(function() A.IdleTrack:Stop() end)
		A.IdleTrack = nil
	end
	if A.HideEverything then
		A.HideEverything = false
		pcall(function() A.SetGameUIHidden(false) end)
	end
	A.Reset()
end)

local MainTab = Window:CreateTab("MAIN")

StatusToggle = MainTab:CreateToggle({
	Name = "STATUS",
	Default = false,
	Height = 32,
	Callback = function(state)
		A.Enabled = state
		local isTouchDevice = UIS.TouchEnabled
		MovePad.Visible = A.Enabled and isTouchDevice
		VertPad.Visible = A.Enabled and isTouchDevice

		if A.Enabled then
			Cam = workspace.CurrentCamera
			A.DefaultFOV = Cam.FieldOfView
			local x, y, _ = Cam.CFrame:ToEulerAnglesYXZ()
			A.Rot = Vector2.new(x, y)
			pcall(function() A.SetCharacterControls(false) end)

			if LP.Character then
				local humanoid = LP.Character:FindFirstChildOfClass("Humanoid")
				if humanoid then
					local animator = humanoid:FindFirstChildOfClass("Animator")
					if animator then
						for _, track in pairs(animator:GetPlayingAnimationTracks()) do
							track:Stop()
						end
						local animate = LP.Character:FindFirstChild("Animate")
						if animate then
							animate.Enabled = false
							local idleTarget = animate:FindFirstChild("idle")
							local idleAnim = idleTarget and idleTarget:FindFirstChildOfClass("Animation")
							if idleAnim then
								A.IdleTrack = animator:LoadAnimation(idleAnim)
							end
						end
						if not A.IdleTrack then
							local fallbackIdle = Instance.new("Animation")
							fallbackIdle.AnimationId = humanoid.RigType == Enum.HumanoidRigType.R15
								and "rbxassetid://507766388" or "rbxassetid://180435571"
							A.IdleTrack = animator:LoadAnimation(fallbackIdle)
						end
						if A.IdleTrack then
							A.IdleTrack.Looped = true
							A.IdleTrack:Play()
						end
					end
				end

				task.spawn(function()
					local hrp = LP.Character:FindFirstChild("HumanoidRootPart")
					local hum = LP.Character:FindFirstChildOfClass("Humanoid")
					if hrp and hum then
						hrp.Anchored = false
						if hum.FloorMaterial == Enum.FloorMaterial.Air and hum:GetState() ~= Enum.HumanoidStateType.Swimming then
							hrp.AssemblyLinearVelocity = Vector3.new(0, hrp.AssemblyLinearVelocity.Y, 0)
							while hum.FloorMaterial == Enum.FloorMaterial.Air and A.Enabled and LP.Character and LP.Character:IsDescendantOf(workspace) do
								task.wait()
							end
						end
						if A.Enabled and LP.Character and LP.Character:IsDescendantOf(workspace) then
							A.TeleportToGround(hrp.Position)
							hrp.Anchored = true
						end
					end
				end)
			end
		else
			if A.IdleTrack then
				A.IdleTrack:Stop()
				A.IdleTrack = nil
			end
			A.Reset()
		end
	end
})

MainTab:CreateCycle({
	Name = "SPEED",
	Options = {0.25, 0.5, 1, 2, 5, 10, 20},
	DefaultIndex = 3,
	Suffix = "x",
	Callback = function(val)
		A.Speed = val
	end
})

MainTab:CreateButton({
	Name = "TELEPORT HERE",
	Callback = function()
		Cam = workspace.CurrentCamera
		if LP.Character and Cam then
			A.TeleportToGround(Cam.CFrame.Position)
		end
	end
})

MainTab:CreateSlider({
	Name = "FOV",
	Min = 20,
	Max = 120,
	Default = 70,
	Callback = function(val)
		A.TargetFOV = val
	end
})

MainTab:CreateSlider({
	Name = "SMOOTHNESS",
	Min = 2,
	Max = 25,
	Default = 12,
	Callback = function(val)
		A.Smoothness = val
	end
})

MainTab:CreateLabel({
	Text = "PC: WASD + E/Q + RightClick | Mobile: Dual Touch",
	Height = 32,
	TextSize = 9,
	Color = Color3.fromRGB(140, 140, 140)
})

MainTab:CreateLabel({
	Text = "made by AcelestuZ",
	Height = 20,
	Font = Enum.Font.GothamMedium,
	TextSize = 10,
	Color = Color3.fromRGB(120, 120, 120)
})

local SettingsTab = Window:CreateTab("SETTINGS")

SettingsTab:CreateSection("VISUAL & RENDERING")

SettingsTab:CreateToggle({
	Name = "FULL BRIGHT",
	Default = false,
	Callback = function(state)
		A.FullBright = state
		if A.FullBright then
			Lighting.Brightness = 3
			Lighting.GlobalShadows = false
			Lighting.Ambient = Color3.fromRGB(178, 178, 178)
			Lighting.OutdoorAmbient = Color3.fromRGB(178, 178, 178)
		else
			Lighting.Brightness = A.OrigLighting.Brightness
			Lighting.GlobalShadows = A.OrigLighting.GlobalShadows
			Lighting.Ambient = A.OrigLighting.Ambient
			Lighting.OutdoorAmbient = A.OrigLighting.OutdoorAmbient
		end
	end
})

SettingsTab:CreateToggle({
	Name = "NO FOG",
	Default = false,
	Callback = function(state)
		A.NoFog = state
		Lighting.FogEnd = A.NoFog and 100000 or A.OrigLighting.FogEnd
	end
})

SettingsTab:CreateSection("INTERFACE & STEALTH")

SettingsTab:CreateToggle({
	Name = "HIDDEN NAMES",
	Default = false,
	Callback = function(state)
		A.HideNames = state
		for _, v in pairs(Players:GetPlayers()) do
			if v.Character and v.Character:FindFirstChildOfClass("Humanoid") then
				v.Character:FindFirstChildOfClass("Humanoid").DisplayDistanceType = A.HideNames
					and Enum.HumanoidDisplayDistanceType.None
					or Enum.HumanoidDisplayDistanceType.Viewer
			end
		end
	end
})

local HideUIToggle = SettingsTab:CreateToggle({
	Name = "HIDE GAME UI",
	Default = false,
	Callback = function(state)
		A.HideEverything = state
		A.SetGameUIHidden(A.HideEverything)
	end
})

SettingsTab:CreateSection("SYSTEM SETTINGS")

SettingsTab:CreateToggle({
	Name = "FLOATING BUTTON",
	Default = Window:GetFloatingButton(),
	Callback = function(state)
		Window:SetFloatingButton(state)
	end
})

local ResetGuiBtn
ResetGuiBtn = SettingsTab:CreateButton({
	Name = "FORCE RESET GUI (TAP)",
	Height = 30,
	Callback = function()
		ResetGuiBtn:SetColor(Color3.fromRGB(0, 150, 70))

		if A.HideEverything then
			A.HideEverything = false
			A.SetGameUIHidden(false)
			HideUIToggle:Set(false, false)
		end

		local pGui = LP:FindFirstChildOfClass("PlayerGui")
		if pGui then
			for _, desc in pairs(pGui:GetDescendants()) do
				if not (ScreenGui and desc:IsDescendantOf(ScreenGui)) then
					if desc.Name == "JumpButton" and (desc:IsA("ImageButton") or desc:IsA("ImageLabel")) then
						desc.ImageTransparency = 0
					elseif desc.Name == "DynamicThumbstickFrame" and desc:IsA("GuiObject") then
						desc.Visible = true
					end
				end
			end

			for _, gui in pairs(pGui:GetChildren()) do
				if gui:IsA("ScreenGui") and gui ~= ScreenGui and gui.Enabled == true then
					gui.Enabled = false
					gui.Enabled = true
				end
			end
		end

		task.wait(0.2)
		ResetGuiBtn:SetColor(Color3.fromRGB(30, 30, 30))
	end
})

SettingsTab:CreateKeybind({
	Name = "UI TOGGLE KEY",
	Default = Enum.KeyCode.H,
	IsUIToggle = true
})

Window:Bind(RS.RenderStepped, function(dt)
	A.UpdateCamera(dt)
end)

UpBtn.InputBegan:Connect(function(io)
	if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
		A.VerticalMove = 1
	end
end)
UpBtn.InputEnded:Connect(function(io)
	if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
		if A.VerticalMove > 0 then A.VerticalMove = 0 end
	end
end)
DownBtn.InputBegan:Connect(function(io)
	if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
		A.VerticalMove = -1
	end
end)
DownBtn.InputEnded:Connect(function(io)
	if io.UserInputType == Enum.UserInputType.Touch or io.UserInputType == Enum.UserInputType.MouseButton1 then
		if A.VerticalMove < 0 then A.VerticalMove = 0 end
	end
end)

local moveTouchObj = nil
local lookTouchObj = nil
local isRightMouseLooking = false

MovePad.InputBegan:Connect(function(io)
	if io.UserInputType == Enum.UserInputType.Touch and not moveTouchObj then
		moveTouchObj = io
		A.StartPos = Vector2.new(io.Position.X, io.Position.Y)
		A.CurrentMovePos = A.StartPos

		JoystickOuter.Position = UDim2.new(0, io.Position.X, 0, io.Position.Y)
		JoystickKnob.Position = UDim2.new(0.5, 0, 0.5, 0)
		JoystickOuter.Visible = true
	end
end)

Window:Bind(UIS.InputBegan, function(io, gpe)
	if not A.Enabled or gpe then return end
	if io.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseLooking = true
		UIS.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
	elseif io.UserInputType == Enum.UserInputType.Touch and io ~= moveTouchObj and not lookTouchObj then
		Cam = workspace.CurrentCamera
		if Cam and io.Position.X >= Cam.ViewportSize.X * 0.45 then
			lookTouchObj = io
		end
	end
end)

Window:Bind(UIS.InputChanged, function(io)
	if not A.Enabled then return end

	if io == moveTouchObj then
		A.CurrentMovePos = Vector2.new(io.Position.X, io.Position.Y)
		if A.StartPos then
			local diff = A.CurrentMovePos - A.StartPos
			local clamped = diff.Magnitude > 45 and (diff.Unit * 45) or diff
			JoystickKnob.Position = UDim2.new(0.5, clamped.X, 0.5, clamped.Y)
		end
		return
	end

	if io == lookTouchObj then
		A.Rot = A.Rot + Vector2.new(-io.Delta.Y * 0.005, -io.Delta.X * 0.005)
		return
	end

	if isRightMouseLooking and io.UserInputType == Enum.UserInputType.MouseMovement then
		A.Rot = A.Rot + Vector2.new(-io.Delta.Y * 0.004, -io.Delta.X * 0.004)
	end
end)

Window:Bind(UIS.InputEnded, function(io)
	if io == moveTouchObj then
		moveTouchObj = nil
		A.StartPos = nil
		A.CurrentMovePos = nil
		A.CurrentMoveVec = Vector2.new(0, 0)
		JoystickOuter.Visible = false
	elseif io == lookTouchObj then
		lookTouchObj = nil
	elseif io.UserInputType == Enum.UserInputType.MouseButton2 then
		isRightMouseLooking = false
		UIS.MouseBehavior = Enum.MouseBehavior.Default
	end
end)
