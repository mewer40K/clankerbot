-- Invisible FOV Lock-On Script

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")

local player = Players.LocalPlayer
local camera = workspace.CurrentCamera

local LOCK_KEY = Enum.KeyCode.Q
local FOV_RADIUS = 150 -- pixels (bigger = wider lock-on)
local lockedCharacter = nil
local lockConnection = nil

-- Get closest character inside FOV circle
local function getTargetInFOV()
	local viewportSize = camera.ViewportSize
	local screenCenter = Vector2.new(viewportSize.X / 2, viewportSize.Y / 2)

	local closestTarget = nil
	local shortestDistance = FOV_RADIUS

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= player and plr.Character and plr.Character:FindFirstChild("HumanoidRootPart") then
			local hrp = plr.Character.HumanoidRootPart
			local screenPos, onScreen = camera:WorldToViewportPoint(plr.Character.Head.Position)


			if onScreen then
				local distanceFromCenter = (Vector2.new(screenPos.X, screenPos.Y) - screenCenter).Magnitude

				if distanceFromCenter <= shortestDistance then
					shortestDistance = distanceFromCenter
					closestTarget = plr.Character
				end
			end
		end
	end

	return closestTarget
end

-- Lock camera
local function lockOn(target)
	camera.CameraType = Enum.CameraType.Scriptable

	lockConnection = RunService.RenderStepped:Connect(function()
		if not target or not target:FindFirstChild("HumanoidRootPart") then
			return
		end

		local camPos = camera.CFrame.Position
		local targetPos = target.Head.Position

		camera.CFrame = CFrame.new(camPos, targetPos)
	end)
end

-- Unlock camera
local function unlock()
	if lockConnection then
		lockConnection:Disconnect()
		lockConnection = nil
	end

	camera.CameraType = Enum.CameraType.Custom
	lockedCharacter = nil
end

-- Input
UserInputService.InputBegan:Connect(function(input, processed)
	if processed then return end

	if input.KeyCode == LOCK_KEY then
		if lockedCharacter then
			unlock()
		else
			local target = getTargetInFOV()
			if target then
				lockedCharacter = target
				lockOn(target)
			end
		end
	end
end)
