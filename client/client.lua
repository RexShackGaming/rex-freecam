local Cam = nil
local Controller = nil
local StartingFov = 0.0
local ShowHud = true
local Speed = Config.Speed
local CameraLocked = false
local Timecycle = 1
local FilterEnabled = false
local GridEnabled = false
local AttachedCamEntity = nil
local FollowCam = false

RegisterNetEvent('freecam:toggle')
RegisterNetEvent('freecam:toggleLock')
RegisterNetEvent('freecam:toggleAttached')

function LoadModel(model)
	if IsModelInCdimage(model) then
		RequestModel(model)

		while not HasModelLoaded(model) do
			Wait(0)
		end

		return true
	else
		return false
	end
end

function AttachCam(entity, followCam)
	local entPos = GetEntityCoords(entity)
	local camPos

	if Cam then
		camPos = GetCamCoord(Cam)
	else
		camPos = GetGameplayCamCoord()

		EnableFreeCam()
	end

	if followCam then
		local y = #(camPos.xy - entPos.xy)
		local z = camPos.z - entPos.z
		AttachCamToEntity(Cam, entity, 0.0, -y, z, true)
	else
		AttachCamToEntity(Cam, entity, camPos - entPos, false)
	end

	AttachedCamEntity = entity
	FollowCam = followCam
end

function EnableFreeCam()
	local x, y, z = table.unpack(GetGameplayCamCoord())
	local pitch, roll, yaw = table.unpack(GetGameplayCamRot(2))
	local fov = GetGameplayCamFov()

	LoadModel(Config.ControllerModel)
	Controller = CreateObjectNoOffset(Config.ControllerModel, x, y, z, false, false, false, false)
	FreezeEntityPosition(Controller, true)
	SetEntityVisible(Controller, false)

	Cam = CreateCam("DEFAULT_SCRIPTED_CAMERA", true)
	SetCamRot(Cam, pitch, roll, yaw, 2)
	SetCamFov(Cam, fov)
	RenderScriptCams(true, true, 500, true, true)
	StartingFov = fov

	AttachCamToEntity(Cam, Controller, 0.0, 0.0, 0.0, true)

	if FilterEnabled then
		SetTimecycleModifier(Timecycles[Timecycle])
	end

	if GridEnabled then
		AnimpostfxPlay("CameraViewFinder")
	end
end

function DisableFreeCam()
	RenderScriptCams(false, true, 500, true, true)
	SetCamActive(Cam, false)
	DetachCam(Cam)
	DestroyCam(Cam, true)
	Cam = nil

	DeleteObject(Controller)

	AttachedCamEntity = nil

	if FilterEnabled then
		ClearTimecycleModifier()
	end

	if GridEnabled then
		AnimpostfxStop("CameraViewFinder")
	end
end

function ToggleFreeCam()
	if Cam then
		DisableFreeCam()
	else
		EnableFreeCam()
	end
end

function ToggleFreeCamLock()
	if not Cam then
		EnableFreeCam()
	end

	CameraLocked = not CameraLocked
end

function NextFilter()
	Timecycle = Timecycle == #Timecycles and 1 or Timecycle + 1
	SetTimecycleModifier(Timecycles[Timecycle])
	FilterEnabled = true
end

function PrevFilter()
	Timecycle = Timecycle == 1 and #Timecycles or Timecycle - 1
	SetTimecycleModifier(Timecycles[Timecycle])
	FilterEnabled = true
end

function ToggleFilter()
	if FilterEnabled then
		ClearTimecycleModifier()
		FilterEnabled = false
	else
		SetTimecycleModifier(Timecycles[Timecycle])
		FilterEnabled = true
	end
end

function ToggleGrid()
	if GridEnabled then
		AnimpostfxStop('CameraViewFinder')
		GridEnabled = false
	else
		AnimpostfxPlay('CameraViewFinder')
		GridEnabled = true
	end
end

function ToggleAttachedOrFollowCam(followCam)
	if AttachedCamEntity then
		SetEntityCoordsNoOffset(Controller, GetCamCoord(Cam))
		AttachCamToEntity(Cam, Controller, 0.0, 0.0, 0.0, true)
		AttachedCamEntity = nil
		FollowCam = false
	else
		AttachCam(PlayerPedId(), followCam)
	end
end

function ToggleAttachedCam()
	if FollowCam then
		ToggleFollowCam()
	end

	ToggleAttachedOrFollowCam(false)
end

function ToggleFollowCam()
	if AttachedCamEntity and not FollowCam then
		ToggleAttachedCam()
	end

	ToggleAttachedOrFollowCam(true)
end

function CheckControls(func, pad, controls)
	if type(controls) == 'number' then
		return func(pad, controls)
	end

	for _, control in ipairs(controls) do
		if func(pad, control) then
			return true
		end
	end

	return false
end

-- NEW: Function to print coordinates to F8 Console
function CopyCameraDetails()
	if Cam then
		local x, y, z = table.unpack(GetCamCoord(Cam))
		local pitch, roll, yaw = table.unpack(GetCamRot(Cam, 2))
		local fov = GetCamFov(Cam)

		local coordsString = string.format("X: %.2f, Y: %.2f, Z: %.2f, Pitch: %.2f, Roll: %.2f, Yaw: %.2f, FOV: %.2f", x, y, z, pitch, roll, yaw, fov)
		lib.setClipboard(string.format("X: %.2f, Y: %.2f, Z: %.2f, Pitch: %.2f, Roll: %.2f, Yaw: %.2f, FOV: %.2f", x, y, z, pitch, roll, yaw, fov))
		
		print("^2[Freecam Coords]^7 " .. coordsString)
		
		TriggerEvent('chat:addMessage', {
			color = {255, 255, 255},
			multiline = true,
			args = { 'Freecam', 'Coordinates printed to F8 console and added top clipboard!' }
		})
	end
end

RegisterCommand('freecam', ToggleFreeCam)
RegisterCommand('lockcam', ToggleFreeCamLock)
RegisterCommand('attachcam', ToggleAttachedCam)
RegisterCommand('followcam', ToggleFollowCam)
RegisterCommand('copycam', CopyCameraDetails) -- NEW COMMAND

AddEventHandler('freecam:toggle', ToggleFreeCam)
AddEventHandler('freecam:toggleLock', ToggleFreeCamLock)
AddEventHandler('freecam:toggleAttached', ToggleAttachedCam)
AddEventHandler('freecam:toggleFollow', ToggleFollowCam)

function DrawText(text, x, y, centred)
	SetTextScale(0.35, 0.35)
	SetTextColor(255, 255, 255, 255)
	SetTextCentre(centred)
	SetTextDropshadow(1, 0, 0, 0, 200)
	SetTextFontForCurrentCommand(0)
	DisplayText(CreateVarString(10, "LITERAL_STRING", text), x, y)
end

AddEventHandler('onResourceStop', function(resourceName)
	if GetCurrentResourceName() == resourceName and Cam then
		DisableFreeCam()
	end
end)

CreateThread(function()
	TriggerEvent('chat:addSuggestion', '/freecam', 'Toggle freecam mode')
	TriggerEvent('chat:addSuggestion', '/lockcam', 'Lock/unlock the freecam')
	TriggerEvent('chat:addSuggestion', '/attachcam', 'Attach/detach camera in place')
	TriggerEvent('chat:addSuggestion', '/followcam', 'Follow behind player ped')
	TriggerEvent('chat:addSuggestion', '/copycam', 'Print current cam coordinates to F8 console')

	while true do
		Wait(0)

		if Cam then
			local x, y, z = table.unpack(GetCamCoord(Cam))
			local pitch, roll, yaw = table.unpack(GetCamRot(Cam, 2))
			local fov = GetCamFov(Cam)

			if ShowHud then
				DrawText('Camera Mode:', 0.5, 0.01, true)
				if CameraLocked then
					DrawText('Locked', 0.5, 0.03, true)
				elseif AttachedCamEntity then
					if FollowCam then
						DrawText('Follow', 0.5, 0.03, true)
					else
						DrawText('Attached', 0.5, 0.03, true)
					end
				else
					DrawText('Free', 0.5, 0.03, true)
				end

				DrawText(string.format('Coordinates:\nX: %.2f\nY: %.2f\nZ: %.2f\nPitch: %.2f\nRoll: %.2f\nYaw: %.2f\nFOV: %.0f\nFilter: %s', x, y, z, pitch, roll, yaw, fov, FilterEnabled and Timecycles[Timecycle] or 'None'), 0.01, 0.3, false)

				if CameraLocked or AttachedCamEntity then
					DrawText('Return to Free mode - V', 0.5, 0.96)
				else
					DrawText(string.format('FreeCam Speed: %.3f', Speed), 0.5, 0.87, true)
					DrawText('W/A/S/D - Move, Spacebar/Shift - Up/Down, Page Up/Page Down - Speed, Z/X - Zoom, C/V - Roll', 0.5, 0.90, true)
					DrawText('F/G - Filter, H - Toggle Filter, J - Grid, [ENTER] - Copy Coords, B - Reset, Q - Hide HUD', 0.5, 0.93, true)
				end
			else
				HideHudAndRadarThisFrame()
			end

			DisableFirstPersonCamThisFrame()

			if CameraLocked or AttachedCamEntity then
				DisableControlAction(0, Config.ExitLockedCamControl, true)

				if CheckControls(IsDisabledControlJustReleased, 0, Config.ExitLockedCamControl) then
					if CameraLocked then
						ToggleFreeCamLock()
					elseif FollowCam then
						ToggleFollowCam()
					else
						ToggleAttachedCam()
					end
				end

				if FollowCam then
					SetCamRot(Cam, GetEntityRotation(AttachedCamEntity))
				end
			else
				DisableAllControlActions(0)
				EnableControlAction(0, `INPUT_FRONTEND_PAUSE_ALTERNATE`)
				EnableControlAction(0, `INPUT_MP_TEXT_CHAT_ALL`)

				if Speed < Config.MinSpeed then Speed = Config.MinSpeed end
				if Speed > Config.MaxSpeed then Speed = Config.MaxSpeed end
				if fov < Config.MinFov then fov = Config.MinFov end
				if fov > Config.MaxFov then fov = Config.MaxFov end

				-- Toggle HUD
				if CheckControls(IsDisabledControlJustPressed, 0, Config.ToggleHudControl) then
					ShowHud = not ShowHud
				end

				-- NEW: Copy Coords (Mapped to 'ENTER')
				if IsDisabledControlJustPressed(0, 0xC7B5340A) then 
					CopyCameraDetails()
				end

				-- Reset camera
				if CheckControls(IsDisabledControlJustPressed, 0, Config.ResetCamControl) then
					roll = 0.0
					fov = StartingFov
				end

				-- Speed and Movement controls
				if CheckControls(IsDisabledControlPressed, 0, Config.IncreaseSpeedControl) then Speed = Speed + Config.SpeedIncrement end
				if CheckControls(IsDisabledControlPressed, 0, Config.DecreaseSpeedControl) then Speed = Speed - Config.SpeedIncrement end
				if CheckControls(IsDisabledControlPressed, 0, Config.UpControl) then z = z + Speed end
				if CheckControls(IsDisabledControlPressed, 0, Config.DownControl) then z = z - Speed end

				-- Mouse rotation
				local axisX = GetDisabledControlNormal(0, 0xA987235F)
				local axisY = GetDisabledControlNormal(0, 0xD2047988)
				if axisX ~= 0.0 or axisY ~= 0.0 then
					yaw = yaw + axisX * -1.0 * Config.SpeedUd * 1.0
					pitch = math.max(math.min(89.9, pitch + axisY * -1.0 * Config.SpeedLr * 1.0), -89.9)
				end

				-- Roll and Zoom
				if CheckControls(IsDisabledControlPressed, 0, Config.RollLeftControl) then roll = roll - Config.RollSpeed end
				if CheckControls(IsDisabledControlPressed, 0, Config.RollRightControl) then roll = roll + Config.RollSpeed end
				if CheckControls(IsDisabledControlPressed, 0, Config.IncreaseFovControl) then fov = fov + Config.ZoomSpeed end
				if CheckControls(IsDisabledControlPressed, 0, Config.DecreaseFovControl) then fov = fov - Config.ZoomSpeed end

				-- Directional movement
				local r1 = -yaw * math.pi / 180
				local dx1 = Speed * math.sin(r1)
				local dy1 = Speed * math.cos(r1)
				local r2 = math.floor(yaw + 90.0) % 360 * -1.0 * math.pi / 180
				local dx2 = Speed * math.sin(r2)
				local dy2 = Speed * math.cos(r2)

				if CheckControls(IsDisabledControlPressed, 0, Config.ForwardControl) then x = x + dx1 y = y + dy1 end
				if CheckControls(IsDisabledControlPressed, 0, Config.BackwardControl) then x = x - dx1 y = y - dy1 end
				if CheckControls(IsDisabledControlPressed, 0, Config.LeftControl) then x = x + dx2 y = y + dy2 end
				if CheckControls(IsDisabledControlPressed, 0, Config.RightControl) then x = x - dx2 y = y - dy2 end

				-- Visual Filters
				if CheckControls(IsDisabledControlJustPressed, 0, Config.NextFilterControl) then NextFilter() end
				if CheckControls(IsDisabledControlJustPressed, 0, Config.PrevFilterControl) then PrevFilter() end
				if CheckControls(IsDisabledControlJustPressed, 0, Config.ToggleFilterControl) then ToggleFilter() end
				if CheckControls(IsDisabledControlJustPressed, 0, Config.ToggleGridControl) then ToggleGrid() end

				SetEntityCoordsNoOffset(Controller, x, y, z)
				SetCamRot(Cam, pitch, roll, yaw, 2)
				SetCamFov(Cam, fov)
			end
		end
	end
end)

CreateThread(function()
	while true do
		if AttachedCamEntity and not DoesEntityExist(AttachedCamEntity) then
			AttachCam(PlayerPedId(), FollowCam)
		end
		Wait(500)
	end
end)
