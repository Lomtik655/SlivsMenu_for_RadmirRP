-- Script head
script_name('SlivsMenu for RadmirRP')
script_author('SlivaTech Studio')

require "lib.moonloader"
require "lib.sampfuncs"
local dlstatus = require('moonloader').download_status

--Проверка и загрузка зависимостей
if not doesDirectoryExist(getWorkingDirectory() .. "/SlivsMenuFolder") then
    print("Папка SlivsMenuFolder не найдена, создаем...")
	local result = createDirectory(getWorkingDirectory() .. "/SlivsMenuFolder")
	if result then
		print("Папка moonloader/SlivsMenuFolder успешно создана")
	else
		print("Не удалось создать папку moonloader/SlivsMenuFolder")
		sampAddChatMessage("Не удалось создать папку moonloader/SlivsMenuFolder", -1)
		thisScript():unload()
	end
end
if not doesFileExist(getWorkingDirectory() .. "/SlivsMenuFolder/SlivsMenuFont.png") then
	print("Картинка moonloader/SlivsMenuFolder/SlivsMenuFont.png не найдена, начинаю загрузку...")
	local dw_url = "https://github.com/Lomtik655/SlivsMenu_for_RadmirRP/blob/main/SlivsMenuFolder/SlivsMenuFont.png?raw=true"
	local dw_path = getWorkingDirectory() .. "/SlivsMenuFolder/SlivsMenuFont.png"
	downloadUrlToFile(dw_url, dw_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			print("Картинка moonloader/SlivsMenuFolder/SlivsMenuFont.png успешно загружена.")
			thisScript():reload()
		end
	end)
end
if not doesFileExist(getWorkingDirectory() .. "/ChaposNops.lua") then
	print("moonloader/ChaposNops.lua не найден, начинаю загрузку...")
	local dw_url = "https://github.com/Lomtik655/SlivsMenu_for_RadmirRP/raw/refs/heads/main/ChaposNops.lua"
	local dw_path = getWorkingDirectory() .. "/ChaposNops.lua"
	downloadUrlToFile(dw_url, dw_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			print("moonloader/ChaposNops.lua успешно загружен.")
			reloadScripts()
		end
	end)
end

-- Include
local sampEvents = require 'lib.samp.events'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = "CP1251"
u8 = encoding.UTF8
local vkeys = require 'vkeys'
local gkeys = require 'game.keys'
local vector3d = require 'vector3d'
local inicfg = require 'inicfg'
local memory = require 'memory'
local ffi = require 'ffi'
local winmm = ffi.load("Winmm.dll")
ffi.cdef[[
   typedef unsigned long DWORD;

   DWORD __stdcall timeGetTime();
]]
math.randomseed(os.time())

-- Шрифты
imgui.GetIO().Fonts:Clear() -- очищаем шрифт имгуя
imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\arial.ttf', 16, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) -- ставим свой шрифт
local sizeHead = nil
local sizeMainButton = nil
local sizeCheatMenuHead = nil
-- Картинки
local fontimg = imgui.CreateTextureFromFile(getGameDirectory() .. "\\moonloader\\SlivsMenuFolder\\SlivsMenuFont.png")

-- Переменные
local ImVec2 = imgui.ImVec2
local ImVec4 = imgui.ImVec4
local ImGuiStyle = imgui.GetStyle()
local ImGuiColors = ImGuiStyle.Colors
local ImGuiClr = imgui.Col

local getBonePosition = ffi.cast("int (__thiscall*)(void*, float*, int, bool)", 0x5E4280)
function GetBodyPartCoordinates(id, handle)
    local pedptr = getCharPointer(handle)
    local vec = ffi.new("float[3]")
    getBonePosition(ffi.cast("void*", pedptr), vec, id, true)
    return vec[0], vec[1], vec[2]
end

--Типо "классы"
local Clicker = {}
function Clicker:new(Button, Sleep)
	local obj = {}
	obj.Button = Button
	obj.Sleep = Sleep
	obj.Allow = false
	obj.thread = nil
	
	function obj:Start()
		self.Allow = true
		self.thread = lua_thread.create(function()	
			while self.Allow do
				setVirtualKeyDown(self.Button, true)
				wait(100)
				setVirtualKeyDown(self.Button, false)
				wait(self.Sleep)
			end
			self.thread = nil
		end)
	end
	
	function obj:Stop()
		self.Allow = false
	end
	

	setmetatable(obj, self)
	self.__index = self; return obj
end

local SlivsMenu = {
	windowState = imgui.ImBool(false);
	windowMenu = 1;
}

local Credits_menu = {
	windowState = imgui.ImBool(false);
}

local Ohota = {
	WhOhota = imgui.ImBool(false);
	HeadDotLes = imgui.ImBool(false);
	Players = imgui.ImBool(false);
	AimOhota = imgui.ImBool(false);
	AimHandle = nil;
	ClearGhosts = imgui.ImBool(false);
	AutoY = imgui.ImBool(false);
	WhDuck = imgui.ImBool(false);
	WhDuck_traser = imgui.ImBool(false);
	AutoTakeDuck = imgui.ImBool(false);
	AimDuck = imgui.ImBool(false);
	AimDuck_silent = imgui.ImBool(false);
}
local MoveMode = {
	Auto = 0;
	Walk = 1;
	Run = 2;
	RunOnJump = 3;
}
local Bots = {
	Etap = 0; -- Этап
	Stop = imgui.ImBool(false);
	
	Metka = false;
	MetkaXYZ = vector3d();
	MetkaText = false;
	MetkaTextT = "";
	MetkaTextXYZ = vector3d();
	
	Clicker_Alt = Clicker:new(vkeys.VK_MENU, 500);
	Shahta = imgui.ImBool(false);
	ZavodAutoSkip = imgui.ImBool(false);
	ZavodMenuSkip = imgui.ImBool(false);
}
local AutoLogin = {
	Password = imgui.ImBuffer(256);
	Status = imgui.ImBool(false);
	AutoPoevlenie = imgui.ImBool(false);
	HideNickname = imgui.ImBool(false);
	HideNickname_ChatName = imgui.ImBuffer(256);
	MainName = nil;
}
local Daiving = {
	WH = imgui.ImBool(false);
	Tracer = imgui.ImBool(false);
	Clicker_Y = Clicker:new(vkeys.VK_Y, 600);
}
local Shahta = {
	Clicker_Y_CheckBox = imgui.ImBool(false);
	Clicker_Y = Clicker:new(vkeys.VK_Y, 700);
	Wh = imgui.ImBool(false);
}
local Fishing = {
	Helper = imgui.ImBool(false);
	Helper_buffer = imgui.ImBuffer(256);
	Helper_bot = imgui.ImBool(false);
	Fish_value = 0;
	Combo = imgui.ImInt(0);
	Array = {u8"Спиннинг", u8"Поплавочная удочка", u8"Улучшенная удочка"};
	Bot = imgui.ImBool(false);
	Bot_key = imgui.ImBool(false);
	Clicker_Alt = Clicker:new(vkeys.VK_MENU, 500);
	Bot_tunecOff = imgui.ImBool(false);
}
Fishing.Helper_buffer.v = tostring(0);
local Pilot = {
	SkipTable = imgui.ImBool(false);
	AutoEngine = imgui.ImBool(false);
}

local config = inicfg.load({
  AutoLogin =
  {
	Status=false,
	Password="pass",
	AutoPoevlenie=false,
	HideNickname_ChatName="Nickname"
  },
  Ohota = 
  {
	Players=false,
	HeadDotLes=false,
	ClearGhosts=false
  }
})
AutoLogin.Status.v = config.AutoLogin.Status
if AutoLogin.Status.v then
	AutoLogin.Password.v = u8"Я вас знаю! :P"
else
	AutoLogin.Password.v = u8"ваш пароль сэр"
end
AutoLogin.AutoPoevlenie.v = config.AutoLogin.AutoPoevlenie
AutoLogin.HideNickname_ChatName.v = config.AutoLogin.HideNickname_ChatName
Ohota.Players.v = config.Ohota.Players
Ohota.HeadDotLes.v = config.Ohota.HeadDotLes
Ohota.ClearGhosts.v = config.Ohota.ClearGhosts

-- Версия
local AutoUpdate = {
	script_vers = 200;
	script_vers_text = "2.00";
	
	update_url = "https://github.com/Lomtik655/SlivsMenu_for_RadmirRP/raw/refs/heads/main/update.ini";
	update_path = getWorkingDirectory() .. "/SlivsMenu.ini";
	script_url = "https://github.com/Lomtik655/SlivsMenu_for_RadmirRP/raw/refs/heads/main/SlivsMenu%20for%20RadmirRP.lua";
	script_path = thisScript().path;
	
	update_state = false;
}

-- Functions
function main()
	if not isSampLoaded() or not isSampfuncsLoaded then return end
	while not isSampAvailable() do wait(100) end
	
	-- Обновление скрипта
	downloadUrlToFile(AutoUpdate.update_url, AutoUpdate.update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, AutoUpdate.update_path)
			if tonumber(updateIni.info.vers) > AutoUpdate.script_vers then
				sampAddChatMessage("Вышла обнова {00ff00}SlivsMenu {00b7ff}for RadmirRP{FFFFFF}! {FFFFFF}Начинаю загрузку...", -1)
				AutoUpdate.update_state = true
			end
			os.remove(AutoUpdate.update_path)
		end
	end)
	
	if not AutoUpdate.update_state then
		sampAddChatMessage("{00ff00}SlivsMenu {ffffff}[v".. AutoUpdate.script_vers_text .. "] - {eefa05}/sm, {ffffff}релоад - {fffb00}/smr", -1)
	end

	--Потоки
		--thread = lua_thread.create_suspended(thread_func) | thread:run() - выполнить
	Ohota_AutoTakeDuck_thread = lua_thread.create_suspended(Ohota_AutoTakeDuck_thread_Func)
	
	-- Команды
	sampRegisterChatCommand("sm", imgui_SlivsMenu_windowState)
	sampRegisterChatCommand("smr", function() thisScript():reload() end)
	sampRegisterChatCommand("sm.tpc", function(arg)
		local xStr, yStr, zStr = string.match(arg, "(.+) (.+) (.+)")
		local x, y, z
		if xStr == nil or xStr == "" then
			sampAddChatMessage("Введены не все корды, надо: x y z", -1)
		else
			x = tonumber(xStr); y = tonumber(yStr); z = tonumber(zStr);
			setCharCoordinates(PLAYER_PED, x, y, z)
		end
	end)
	sampRegisterChatCommand("sm.spawn", function(arg)
		sampSendSpawn()
	end)

	--Фонты
	font = renderCreateFont('Verdana', 10, 9)
	font_whGreen = renderCreateFont('Arial', 7, 13)
	fish_font = renderCreateFont('Arial', 15, 13)
	fish_font_2 = renderCreateFont('Arial', 15, 8)
	fish_font_warn = renderCreateFont('Arial', 35, 13)

	imgui.Process = true
	imgui.ShowCursor = false
    while true do
        wait(0)
		
		-- Обновление скрипта
		if AutoUpdate.update_state then
			downloadUrlToFile(AutoUpdate.script_url, AutoUpdate.script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage("{00ff00}SlivsMenu {00b7ff}for RadmirRP {0bff00}успешно обновлен :P", -1)
				end
			end)
			break
		end

		-- Охота
		if Ohota.WhOhota.v then
			for pairsId, value in pairs(getAllChars()) do
				if doesCharExist(value) and value ~= PLAYER_PED and isCharOnScreen(value) and getCharHealth(value) > 0 then
					local modelid = getCharModel(value)
					local posX, posY, posZ = getCharCoordinates(value)
					local _X, _Y = convert3DCoordsToScreen(posX, posY, posZ)
					local x,y,z = getCharCoordinates(PLAYER_PED)
					local X,Y = convert3DCoordsToScreen(x, y, z)
					
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x,y,z, posX, posY, posZ))
					
					local health = getCharHealth(value)
					
					local hx, hy, hz = GetBodyPartCoordinates(8, value)
					local hxx, hyy = convert3DCoordsToScreen(hx, hy, hz)
					
					if Ohota.HeadDot.v then
						renderDrawBoxWithBorder(hxx, hyy, 3, 3, 0xFF00FF00, 1, 0xFF00FF00)
					end
					
					if modelid == 15555 then
						if health == 100 then
							renderFontDrawText(font_whGreen, 'Олень(3)', _X, _Y, 0xFF00FF00)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFF00FF00)
							end
						elseif health == 65 then
							renderFontDrawText(font_whGreen, 'Олень(2)', _X, _Y, 0xFFFF9D00)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFFF9D00)
							end
						elseif health == 30 then
							renderFontDrawText(font_whGreen, 'Олень(1)', _X, _Y, 0xFFFF0000)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFFF0000)
							end
						end
					elseif modelid == 15556 then					
						if health == 100 then
							renderFontDrawText(font_whGreen, 'Медведь(7)', _X, _Y, 0xFF00FF00)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFF00FF00)
							end
						elseif health == 85 then
							renderFontDrawText(font_whGreen, 'Медведь(6)', _X, _Y, 0xFF55E100)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFF55E100)
							end
						elseif health == 70 then
							renderFontDrawText(font_whGreen, 'Медведь(5)', _X, _Y, 0xFFAAC300)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFAAC300)
							end
						elseif health == 55 then
							renderFontDrawText(font_whGreen, 'Медведь(4)', _X, _Y, 0xFFFFA500)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFFFA500)
							end
						elseif health == 40 then
							renderFontDrawText(font_whGreen, 'Медведь(3)', _X, _Y, 0xFFFF6E00)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFFF6E00)
							end
						elseif health == 25 then
							renderFontDrawText(font_whGreen, 'Медведь(2)', _X, _Y, 0xFFFF3700)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFFF3700)
							end
						elseif health == 10 then
							renderFontDrawText(font_whGreen, 'Медведь(1)', _X, _Y, 0xFFFF0000)
							if doesCharExist(Ohota.AimHandle) and Ohota.AimHandle == value then
								renderDrawLine(X, Y, hxx, hyy, 1.0, 0xFFFF0000)
							end
						end
					end
					
					if Ohota.Players.v then
						local resultPlayerId, playerId = sampGetPlayerIdByCharHandle(value)
						if resultPlayerId then
							renderFontDrawText(font_whGreen, "Игрок", _X, _Y, 0xFF8C8C8C)
						end
					end
				end
			end
		end
		if Ohota.ClearGhosts.v then
			if not animalLastState then
				animalLastState = {}
			end
			for _, value in pairs(getAllChars()) do
				if value ~= PLAYER_PED and doesCharExist(value) then
					local modelid = getCharModel(value)					
					if (modelid == 15555 or modelid == 15556) then
						local curX, curY, curZ = getCharCoordinates(value)
						local state = animalLastState[value]
						local now = os.time()
						if not state then
							animalLastState[value] = {x = curX, y = curY, z = curZ, lastMoveTime = now}
						else
							if (math.abs(curX - state.x) > 0.01 or math.abs(curY - state.y) > 0.01 or math.abs(curZ - state.z) > 0.01) then
								state.x = curX
								state.y = curY
								state.z = curZ
								state.lastMoveTime = now
							else
								if now - state.lastMoveTime >= 20 then
									deleteChar(value)
									animalLastState[value] = nil
								end
							end
						end
					end
				end
			end
		end
		if Ohota.WhDuck.v then
			for _, v in pairs(getAllObjects()) do
				if isObjectOnScreen(v) then
					local _, x, y, z = getObjectCoordinates(v)
					local x1, y1 = convert3DCoordsToScreen(x,y,z)
					local model = getObjectModel(v)
					local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
					local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
					local QuaternionX, QuaternionY, QuaternionZ, QuaternionW = getObjectQuaternion(v)
					if model == 10809 then
						if (QuaternionX == 0) then
							renderFontDrawText(font_whGreen, "Утка".." "..distance, x1, y1, 0xFF00FF00)
							if Ohota.WhDuck_traser.v then
								renderDrawLine(x10, y10, x1, y1, 1.0, 0xFF00FF00)
							end
						elseif not(QuaternionX == 0) then
							renderFontDrawText(font_whGreen, "Мертвая утка", x1, y1, 0xFF00FF00)
							if Ohota.WhDuck_traser.v then
								renderDrawLine(x10, y10, x1, y1, 1.0, 0xFF00FF00)
							end
						end
					end
				end
			end
		end
		local camMode = readMemory(0xB6F1A8, 1, false)
		if camMode == 53 or camMode == 55 or camMode == 7 or camMode == 8 then
			local width, heigth = getScreenResolution()
			local fov = getCameraFov() * 0.0174530
			local coeficent = width / fov
			local distance = 0.025 * coeficent
			local width_crosshair, heigth_crosshair = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
			if Ohota.AimDuck.v then
				renderDrawBoxWithBorder(width_crosshair-(distance/2), heigth_crosshair-(distance/2), distance, distance, nil, 2, 0xFF5AE053)
				for _, v in pairs(getAllObjects()) do
					if checkObject_duck(v) then
						local _, x, y, z = getObjectCoordinates(v)
						local wposX, wposY = convert3DCoordsToScreen(x, y, z+0.2)
						if (wposX > width_crosshair-(distance/2)) and (wposX < width_crosshair+(distance/2)) and (wposY > heigth_crosshair-(distance/2)) and (wposY < heigth_crosshair+(distance/2)) then
							targetAtCoords(x, y, z)
							break
						end
					end
				end
			end
		end
		if (camMode == 53 or camMode == 55 or camMode == 7 or camMode == 8) and (Ohota.AimHandle == nil) then
			local width, heigth = getScreenResolution()
			local fov = getCameraFov() * 0.0174530
			local coeficent = width / fov
			local distance = 0.025 * coeficent
			local width_crosshair, heigth_crosshair = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
			if Ohota.AimOhota.v then
				renderDrawBoxWithBorder(width_crosshair-(distance/2), heigth_crosshair-(distance/2), distance, distance, nil, 2, 0xFF5AE053)
				local candidates = {}  -- таблица {char, screenDist, dist3D, x, y, z}
				local maxScreenDist = 0
				local max3DDist = 0
				for _, v in pairs(getAllChars()) do
					if doesCharExist(v) and isCharOnScreen(v) then
						local x, y, z = GetBodyPartCoordinates(8, v)
						local wposX, wposY = convert3DCoordsToScreen(x, y, z)
						
						local inBox = (wposX > width_crosshair - distance/2 and wposX < width_crosshair + distance/2 and wposY > heigth_crosshair - distance/2 and wposY < heigth_crosshair + distance/2)
						if inBox then
							local screenDist = math.sqrt((wposX - width_crosshair)^2 + (wposY - heigth_crosshair)^2)
							local charX, charY, charZ = getCharCoordinates(v)
							local playerX, playerY, playerZ = getCharCoordinates(playerPed)
							local dist3D = math.sqrt((charX - playerX)^2 + (charY - playerY)^2 + (charZ - playerZ)^2)
							
							table.insert(candidates, {v, screenDist, dist3D, x, y, z})
							if screenDist > maxScreenDist then maxScreenDist = screenDist end
							if dist3D > max3DDist then max3DDist = dist3D end
						end
					end
				end
				
				local bestScore = math.huge
				for _, cand in ipairs(candidates) do
					local scrNorm = (maxScreenDist > 0) and (cand[2] / maxScreenDist) or 0
					local distNorm = (max3DDist > 0) and (cand[3] / max3DDist) or 0
					local score = scrNorm + distNorm
					
					if score < bestScore then
						bestScore = score
						Ohota.AimHandle = cand[1]
					end
				end
			end
		elseif (camMode == 53 or camMode == 55 or camMode == 7 or camMode == 8) and (Ohota.AimHandle ~= nil) then
			if Ohota.AimOhota.v then
				local width, heigth = getScreenResolution()
				local fov = getCameraFov() * 0.0174530
				local coeficent = width / fov
				local distance = 0.025 * coeficent
				local width_crosshair, heigth_crosshair = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
				local x, y, z = GetBodyPartCoordinates(8, Ohota.AimHandle)
				local wposX, wposY = convert3DCoordsToScreen(x, y, z)
				
				renderDrawBoxWithBorder(width_crosshair-(distance/2), heigth_crosshair-(distance/2), distance, distance, nil, 2, 0xFF5AE053)
				local inBox = (wposX > width_crosshair - distance/2 and wposX < width_crosshair + distance/2 and wposY > heigth_crosshair - distance/2 and wposY < heigth_crosshair + distance/2)
				if inBox and doesCharExist(Ohota.AimHandle) and isCharOnScreen(Ohota.AimHandle) then
					targetAtCoords(x, y, z)
				end
				if not doesCharExist(Ohota.AimHandle) then
					Ohota.AimHandle = nil
				end
			end
		else
			Ohota.AimHandle = nil
		end
		if Ohota.AutoTakeDuck.v then
			for _, v in pairs(getAllObjects()) do
				if sampGetObjectSampIdByHandle(v) ~= -1 then
					asd = sampGetObjectSampIdByHandle(v)
				end
				if isObjectOnScreen(v) then
					local _, x, y, z = getObjectCoordinates(v)
					local x1, y1 = convert3DCoordsToScreen(x,y,z)
					local model = getObjectModel(v)
					local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
					local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
					local QuaternionX, QuaternionY, QuaternionZ, QuaternionW = getObjectQuaternion(v)
					if model == 10809 then
						if (QuaternionX ~= 0) then
							if (getDistanceBetweenCoords3d(x, y, z, x2, y2, z2) <= 2.3) and ((Ohota_AutoTakeDuck_thread:status() == "dead") or (Ohota_AutoTakeDuck_thread:status() == "suspended"))then
								Ohota_AutoTakeDuck_thread:run()
							end
						end
					end
				end
			end
		end
		
		if Shahta.Wh.v then
			for _, v in pairs(getAllObjects()) do
				if isObjectOnScreen(v) then
					local _, x, y, z = getObjectCoordinates(v)
					local x1, y1 = convert3DCoordsToScreen(x,y,z)
					local model = getObjectModel(v)
					local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
					local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
					if model == 17106 then
						renderFontDrawText(font_whGreen, "Уголь".." "..distance, x1, y1, 0xFF8F8F8F)
					elseif model == 17164 then
						renderFontDrawText(font_whGreen, "Серебро".." "..distance, x1, y1, 0xFFE6E6E6)
					elseif model == 17165 then
						renderFontDrawText(font_whGreen, "Железо".." "..distance, x1, y1, 0xFFFFFFFF)
					elseif model == 17166 then
						renderFontDrawText(font_whGreen, "Золото".." "..distance, x1, y1, 0xFFFFD000)
					end
				end
			end
		end
		
		--Дайвинг
		if Daiving.WH.v then
			for _, v in pairs(getAllObjects()) do
				if sampGetObjectSampIdByHandle(v) ~= -1 then
					asd = sampGetObjectSampIdByHandle(v)
				end
				if isObjectOnScreen(v) then
					local _, x, y, z = getObjectCoordinates(v)
					local x1, y1 = convert3DCoordsToScreen(x,y,z)
					local model = getObjectModel(v)
					local x2,y2,z2 = getCharCoordinates(PLAYER_PED)
					local x10, y10 = convert3DCoordsToScreen(x2,y2,z2)
					local distance = string.format("%.1f", getDistanceBetweenCoords3d(x, y, z, x2, y2, z2))
					if model == 16500 then
						renderFontDrawText(font_whGreen, "Сундук".." "..distance, x1, y1, 0xFF00FF00)
						if Daiving.Tracer.v then
							renderDrawLine(x10, y10, x1, y1, 1.0, 0xFF00FF00)
						end
					end
				end
			end
		end
		
		--Рыбалка
		if Fishing.Bot_key.v then
			if isKeyJustPressed(vkeys.VK_B) then
				if (Fishing.Bot.v) then
					Fishing.Bot.v = false
					sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', -1)
					Fishing.Clicker_Alt:Stop()
				else
					Fishing.Bot.v = true
					sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Бот рыбалка: {0dffdb}Начинаю работать :P', -1)
					lua_thread.create(function()
						wait(500)
						if Fishing.Bot.v then
							Fishing.Clicker_Alt:Start()
						end
					end)
				end
			end
		end
		if Fishing.Helper.v then
			local resX, resY = getScreenResolution()
			if (Fishing.Fish_value < 70) then
				renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBF09ff00, 3, 0x00FF8A00) -- зеленый
				renderFontDrawText(fish_font, string.format('Износ: ' .. Fishing.Fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
			elseif (Fishing.Fish_value >= 70  and Fishing.Fish_value < 80) then
				renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBFffd600, 3, 0x00FF8A00) -- желтый
				renderFontDrawText(fish_font, string.format('Износ: ' .. Fishing.Fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
			elseif (Fishing.Fish_value >= 80 and Fishing.Fish_value < 97) then
				renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBFff8e00, 3, 0x00FF8A00) -- оранжевый
				renderFontDrawText(fish_font, string.format('Износ: ' .. Fishing.Fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
			else
				renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBFff0000, 3, 0x00FF8A00) -- красный
				renderFontDrawText(fish_font, string.format('Износ: ' .. Fishing.Fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
				renderFontDrawText(fish_font_warn, string.format('Осторожно!'), resX/2-130, resY/2-150, 0xFFFFFFFF)
			end
		end
		if not (tonumber(Fishing.Helper_buffer.v) == nil) and (tonumber(Fishing.Helper_buffer.v) < 0) then
			Fishing.Helper_buffer.v = tostring(0)
		elseif not (tonumber(Fishing.Helper_buffer.v) == nil) and (tonumber(Fishing.Helper_buffer.v) > 100) then
			Fishing.Helper_buffer.v = tostring(100)
		end
		if Fishing.Fish_value >= 98 and Fishing.Bot.v then
			Fishing.Bot.v = false
			sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Бот рыбалка: {0dffdb}Слишком большой износ', -1)
			Fishing.Clicker_Alt:Stop()
		end
		if Fishing.Bot.v then
			local resX, resY = getScreenResolution()
			renderFontDrawText(fish_font_2, "Фармим", resX/2-170, resY/2+30, 0xFFFFFFFF)
		end
		
		if Bots.Metka then
			local x1, y1 = convert3DCoordsToScreen(Bots.MetkaXYZ.x,Bots.MetkaXYZ.y,Bots.MetkaXYZ.z)
			local x, y, z = getCharCoordinates(PLAYER_PED)
			local x2, y2 = convert3DCoordsToScreen(x,y,z)
			if isPointOnScreen(Bots.MetkaXYZ.x,Bots.MetkaXYZ.y,Bots.MetkaXYZ.z, 5) then
				renderDrawLine(x1, y1, x2, y2, 1.0, 0xFF00FF00)
				if Bots.MetkaText then
					renderFontDrawText(font, Bots.MetkaTextT, x1, y1, 0xFFFFFFFF)
				end
			end
		end
		
        if not SlivsMenu.windowState.v then
            imgui.ShowCursor = false
		else
			imgui.ShowCursor = true
        end
    end
end

--ИмГуи
function imgui_SlivsMenu_windowState(arg)
	SlivsMenu.windowState.v = not SlivsMenu.windowState.v
	imgui.ShowCursor = SlivsMenu.windowState.v
end
function imgui.BeforeDrawFrame()
	-- Размер шрифта
	if sizeHead == nil then sizeHead = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '/ariblk.ttf', 45, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
	if sizeMainButton == nil then sizeMainButton = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '/comicbd.ttf', 30, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
	if sizeCheatMenuHead == nil then sizeCheatMenuHead = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '/arial.ttf', 18, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic()) end
end
function imgui.OnDrawFrame() -- Окна
	--[[imgui.SwitchContext()
    
    -- Отключаем демо-окно (если оно появляется автоматически)
    -- Эта строчка подавляет отрисовку демо-окна
    imgui.ShowDemoWindow(nil)
	-- Получаем draw_list для рисования поверх всего
    local draw = imgui.GetWindowDrawList()
    
    -- Рисуем красную линию от (100,100) до (500,100)
    draw:AddLine(ImVec2(10, 10), ImVec2(50, 10), 0xFFFF0000, 2)
    
    -- Рисуем зеленую линию по диагонали
    draw:AddLine(ImVec2(10, 20), ImVec2(50, 40), 0xFF00FF00, 3)
    
    -- Рисуем синюю линию с прозрачностью
    draw:AddLine(ImVec2(10, 30), ImVec2(50, 30), 0x80FF00FF, 2)
    
    -- Рисуем прямоугольник
    draw:AddRect(
        ImVec2(100, 400), 
        ImVec2(300, 500), 
        0xFFFFFF00,  -- желтый
        5,           -- скругление углов
        15,          -- флаги скругления
        2            -- толщина
    )
    
    -- Рисуем залитый прямоугольник
    draw:AddRectFilled(
        ImVec2(350, 400), 
        ImVec2(550, 500), 
        0x80FF0000,  -- красный полупрозрачный
        5            -- скругление углов
    )
    
    -- Рисуем круг
    draw:AddCircle(
        ImVec2(200, 600),  -- центр
        50,                 -- радиус
        0xFFFFFFFF,         -- белый цвет
        0,                  -- сегменты (0 = авто)
        3                   -- толщина
    )
    
    -- Рисуем залитый круг
    draw:AddCircleFilled(
        ImVec2(400, 600), 
        50, 
        0xFFFF0000  -- красный
    )]]--
	
	local sw, sh = getScreenResolution()
	imgui.SwitchContext()

	-- Главное окно
    if SlivsMenu.windowState.v then
		apply_custom_style()

		local mainWidth = 800
		local mainHeight = 550

		-- Настройки окна
		imgui.SetNextWindowSize(ImVec2(mainWidth, mainHeight), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, ImVec2(0.5, 0.5))
		ImGuiColors[ImGuiClr.WindowBg] = ImVec4(RGBA(255, 255, 255, 0))
		ImGuiStyle.WindowPadding = ImVec2(0.0, 0.0)
		ImGuiColors[ImGuiClr.BorderShadow] = ImVec4(RGBA(255, 255, 255, 0.00))


		-- Вывод окна
		imgui.Begin('SlivsMenuRadmirRP', SlivsMenu.windowState, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
			imgui.Image(fontimg, ImVec2(800, 550))
			
			createChild("Шапка", mainWidth, 60, 0, 0, ImVec4(RGBA(53, 255, 0, 0)))
				imgui.SetCursorPosX(mainWidth/2-88) --62
				imgui.SetCursorPosY(13)
				imgui.PushFont(sizeHead)
					imgui.Text('SlivsMenu')
				imgui.PopFont()
				imgui.SameLine()
				imgui.SetCursorPosX(760);
				imgui.SetCursorPosY(12);
				ImGuiColors[ImGuiClr.Button] = ImVec4(RGBA(255, 0, 0, 0.7))
				ImGuiColors[ImGuiClr.ButtonHovered] = ImVec4(RGBA(255, 0, 0, 0.85))
				ImGuiColors[ImGuiClr.ButtonActive]  = ImVec4(RGBA(255, 0, 0, 0.10))
				ImGuiStyle.FrameRounding = 5.0
				if imgui.Button(u8"X", ImVec2(25, 25)) then
					imgui_SlivsMenu_windowState()
				end
				ImGuiStyle.FrameRounding = 10.0
			imgui.EndChild()
			
			ImGuiColors[ImGuiClr.BorderShadow] = ImVec4(RGBA(255, 255, 255, 0.10))

			createChild("Меню чита", mainWidth-5, mainHeight-75, 5, 70, ImVec4(RGBA(0, 0, 0, 0.20)))
				createChild("Кнопочки", 150, mainHeight-75, 0, 0, ImVec4(RGBA(0, 0, 0, 0.2)))
					imgui.PushFont(sizeMainButton)
					imgui.SetCursorPosX(5)
					imgui.SetCursorPosY(5)
					ImGuiColors[ImGuiClr.Button] = ImVec4(RGBA(90, 224, 83, 0.6))
					ImGuiColors[ImGuiClr.ButtonHovered] = ImVec4(RGBA(90, 224, 83, 0.85))
					ImGuiColors[ImGuiClr.ButtonActive]  = ImVec4(RGBA(90, 224, 83, 0.10))
					if imgui.Button(u8"Читы", ImVec2(140, 65)) then SlivsMenu.windowMenu = 1 end
					imgui.SetCursorPosX(5)
					--if imgui.Button(u8"Боты", ImVec2(140, 65)) then SlivsMenu.windowMenu = 2 end
					--imgui.SetCursorPosX(5)
					if imgui.Button(u8"Настройки", ImVec2(140, 65)) then SlivsMenu.windowMenu = 3 end
					imgui.PopFont()
					
					
					imgui.SetCursorPosX(10)
					ImGuiColors[ImGuiClr.Button] = ImVec4(RGBA(255, 187, 0, 0.7))
					ImGuiColors[ImGuiClr.ButtonHovered] = ImVec4(RGBA(255, 187, 0, 0.4))
					ImGuiColors[ImGuiClr.ButtonActive]  = ImVec4(RGBA(255, 187, 0, 0.1))
					ImGuiStyle.FrameRounding = 5.0
					imgui.SetCursorPosY(mainHeight-75-30)
					if imgui.Button(u8"Кредиты", ImVec2(80, 25)) then
						Credits_menu.windowState.v = true
					end
					imgui.SameLine()
					imgui.Text("v" .. AutoUpdate.script_vers_text)
					ImGuiColors[ImGuiClr.Button] = ImVec4(RGBA(90, 224, 83, 0.6))
					ImGuiColors[ImGuiClr.ButtonHovered] = ImVec4(RGBA(90, 224, 83, 0.85))
					ImGuiColors[ImGuiClr.ButtonActive]  = ImVec4(RGBA(90, 224, 83, 0.10))
					ImGuiStyle.FrameRounding = 5.0
					
				imgui.EndChild()

				createChild("Менюшки с читами", mainWidth-155-10, mainHeight-75, 155, 0, ImVec4(RGBA(0, 0, 0, 0.10)))
					--Легит
					if SlivsMenu.windowMenu == 1 then
						ImGuiStyle.WindowPadding = ImVec2(5.0, 5.0)
						createChildCheatWindow(u8"Авто-Логин", 150, 1, 5, 110)
							--ImGuiColors[ImGuiClr.Text] = ImVec4(RGBA(255, 255, 0, 1))
							if imgui.Checkbox(u8'Включить', AutoLogin.Status) then
								config.AutoLogin.Status = AutoLogin.Status.v
								config.AutoLogin.Password = AutoLogin.Password.v
								if AutoLogin.Status.v then
									AutoLogin.Password.v = u8"пароль запомнен спс"
								end
								inicfg.save(config)
							end
							imgui.SameLine()
							imgui.TextQuestion("(?)", u8"Сначала введите пароль, потом тыкайте \"включить\" пжжпжп")
							imgui.PushItemWidth(150)
							imgui.InputText(u8'##PasswordInput', AutoLogin.Password)
							if imgui.Checkbox(u8'Авто-Появление в том же месте', AutoLogin.AutoPoevlenie) then 
								config.AutoLogin.AutoPoevlenie = AutoLogin.AutoPoevlenie.v
								inicfg.save(config)
							end
							if imgui.Checkbox(u8'Скрыть ник', AutoLogin.HideNickname) then
								if AutoLogin.HideNickname.v then
									local _, id = sampGetPlayerIdByCharHandle(PLAYER_PED)
									AutoLogin.MainName = sampGetPlayerNickname(id)
									config.AutoLogin.HideNickname_ChatName = AutoLogin.HideNickname_ChatName.v
									inicfg.save(config)
								end
							end
							imgui.SameLine()
							imgui.PushItemWidth(90)
							imgui.InputText(u8'##NicknameInput', AutoLogin.HideNickname_ChatName)
						imgui.EndChild()
						
						
						createChildCheatWindow(u8"Охота", 150, 2, 5, 130)
							if imgui.Checkbox(u8'Аим на оленей и медведей', Ohota.AimOhota) then end
							if imgui.Checkbox(u8'Вх на оленей и медведей', Ohota.WhOhota) then end
							if imgui.Checkbox(u8'Показывать игроков', Ohota.Players) then 
								config.Ohota.Players = Ohota.Players.v
								inicfg.save(config)
							end
							if imgui.Checkbox(u8'Показывать точку головы', Ohota.HeadDotLes) then 
								config.Ohota.HeadDotLes = Ohota.HeadDotLes.v
								inicfg.save(config)
							end
							if imgui.Checkbox(u8'Очистка "Призраков" каждые 20 сек', Ohota.ClearGhosts) then
								config.Ohota.ClearGhosts = Ohota.ClearGhosts.v
								inicfg.save(config)
							end
							if imgui.Checkbox(u8'Автокликер Y', Ohota.AutoY) then end
							imgui.Text("")
							if imgui.Checkbox(u8'Вх на уток', Ohota.WhDuck) then end
							imgui.SameLine()
							if imgui.Checkbox(u8'Трейсер на уток', Ohota.WhDuck_traser) then end
							if imgui.Checkbox(u8'Автоподбор уток', Ohota.AutoTakeDuck) then end
							if imgui.Checkbox(u8'Аим на уток', Ohota.AimDuck) then end
							imgui.SameLine()
							if imgui.Checkbox(u8'Сайлент аим на уток', Ohota.AimDuck_silent) then end
						imgui.EndChild()
						
						createChildCheatWindow(u8"Быстрые действия", 150, 1, 160, 80)
							if imgui.Button(u8"Починить машину(рэйдж)", imgui.ImVec2(180, 40)) then
								if isCharInAnyCar(playerPed) then
									local car = storeCarCharIsInNoSave(playerPed)
									fixCar(car)
									sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Починить машину: {0dffdb}Фиксики заспидранили твою машину за 0.0001 сек', -1)
								else
									sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Починить машину: {0dffdb}Боже, сядь в машину...', -1)
								end
							end
							if imgui.Button(u8"Расфризиться", imgui.ImVec2(110, 40)) then
								freezeCharPosition(playerPed, false)
								setPlayerControl(playerHandle, true)
								if isCharInAnyCar(playerPed) then
									local car = storeCarCharIsInNoSave(playerPed)
									freezeCarPosition(car, false)
								end
								sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Расфризиться: {0dffdb}Ура нам разрешили двигаться', -1)
							end
						imgui.EndChild()
						
						createChildCheatWindow(u8"Рыбалка", 150, 2, 160, 120)
							imgui.PushItemWidth(150)
							imgui.Combo(" ", Fishing.Combo, Fishing.Array, #Fishing.Array)

							if imgui.Checkbox(u8 'Износ', Fishing.Helper) then
								if Fishing.Helper.v then
									if (tonumber(Fishing.Helper_buffer.v) == nil) then
										sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Помощник для рыбалки: {0dffdb}Эээээ, введи норм число! :P', -1)
									elseif (tonumber(Fishing.Helper_buffer.v) >= 0) and (tonumber(Fishing.Helper_buffer.v) <= 100) then
										Fishing.Fish_value = tonumber(Fishing.Helper_buffer.v)
										sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Помощник для рыбалки: Запомнил, у вас - {0dffdb}' .. tostring(Fishing.Fish_value) .. '{FFFF00} :P', -1)
									else
										sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Помощник для рыбалки: {0dffdb}Эээээ, введи норм число! :P', -1)
									end
								end
							end
							imgui.SameLine()
							imgui.PushItemWidth(40)
							if imgui.InputText(u8'', Fishing.Helper_buffer) then end
							
							--Бот рыбалка
							if imgui.Checkbox(u8 'Бот рыбалка(вылетает)', Fishing.Bot) then
								if Fishing.Bot.v then
									sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Бот рыбалка: {0dffdb}Начинаю работать :P', -1)
									Fishing.Clicker_Alt:Start()
								else
									sampAddChatMessage('{00ff00}SlivsMenu {FFFF00}Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', -1)
									Fishing.Clicker_Alt:Stop()
								end
							end
							if imgui.Checkbox(u8'Бинд бота на B', Fishing.Bot_key) then end
							if imgui.Checkbox(u8'Выключить Тунца', Fishing.Bot_tunecOff) then end
						imgui.EndChild()
						
						createChildCheatWindow(u8"Пилот", 90, 1, 315, 120)
							if imgui.Checkbox(u8'Авто-продолжение работы', Pilot.SkipTable) then end
							if imgui.Checkbox(u8'Авто-вкл движка', Pilot.AutoEngine) then end
						imgui.EndChild()
						
						createChildCheatWindow(u8"Шахта", 90, 2, 315, 120)
							if imgui.Checkbox(u8'Авто Y', Shahta.Clicker_Y_CheckBox) then
								if not Shahta.Clicker_Y_CheckBox.v then
									Shahta.Clicker_Y:Stop()
								end
							end
							if imgui.Checkbox(u8'Вх на руду', Shahta.Wh) then end
						imgui.EndChild()
						
						createChildCheatWindow(u8"Завод", 90, 1, 410, 120)
							if imgui.Checkbox(u8'Авто работа(Моментально/рэйдж)', Bots.ZavodAutoSkip) then	end
							if imgui.Checkbox(u8'Меню со скипом работы', Bots.ZavodMenuSkip) then	end
							imgui.SameLine()
							imgui.TextQuestion("(?)", u8"Вы сами эмулируете конец работы, когда посчитаете нужным")
						imgui.EndChild()
						
						createChildCheatWindow(u8"Дайвинг", 90, 2, 410, 120)
							if imgui.Checkbox(u8'Вх на сундуки', Daiving.WH) then end
							if imgui.Checkbox(u8'Трейсер на сундуки', Daiving.Tracer) then end
						imgui.EndChild()
						
						ImGuiStyle.WindowPadding = ImVec2(0.0, 0.0)
					end
					--Боты
					if SlivsMenu.windowMenu == 2 then
						
					end
					--Настройки
					if SlivsMenu.windowMenu == 3 then
						ImGuiStyle.WindowPadding = ImVec2(15.0, 0.0)
						createChild("Комманды", 150, 250, 5, 5, ImVec4(RGBA(0, 0, 0, 0.40)))
							ImGuiStyle.WindowPadding = ImVec2(0.0, 0.0)
							createChild('Комманды_head', 130, 23, 10, 0, ImVec4(RGBA(255, 29, 0, 0.70)))
								imgui.SetCursorPosX(24)
								imgui.SetCursorPosY(1)
								imgui.PushFont(sizeCheatMenuHead)
								imgui.Text(u8"Комманды")
								imgui.PopFont()
							imgui.EndChild()
							
							imgui.SetCursorPosX(65)
							imgui.SetCursorPosY(25)
							if imgui.Button(u8"", ImVec2(35, 20)) then 
								thisScript():reload()
							end
							imgui.SetCursorPosY(25)
							imgui.Text(u8"Релоад /smr")
							imgui.Text(u8"Нопы /nop")
							imgui.SameLine()
							imgui.TextQuestion("(?)", u8"ChaposNops.lua")
							imgui.Text(u8"/sm.tpc x y z")
							imgui.SameLine()
							imgui.TextQuestion("(?)", u8"Обычный тп на корды без обходов")
							imgui.Text(u8"/sm.spawn")
							imgui.SameLine()
							imgui.TextQuestion("(?)", u8"Заспавниться")
						
						imgui.EndChild()
						
					end
				imgui.EndChild()


			imgui.EndChild()

        imgui.End()

		-- Окно для кредитов
		if Credits_menu.windowState.v then
			menus_style()
			-- Настройки окна
			imgui.SetNextWindowSize(ImVec2(400, 150), imgui.Cond.FirstUseEver)
			imgui.SetNextWindowPos(ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, ImVec2(0.5, 0.5))

			-- Вывод окна
			imgui.Begin(u8'SlivsMenu - Кредиты', Credits_menu.windowState, imgui.WindowFlags.NoResize)
				imgui.SetCursorPosX(5)
				imgui.SetCursorPosY(35)
				imgui.Text("QQSliverQQ:")
				imgui.SameLine()
				imgui.SetCursorPosY(30)
				if imgui.Button("YouTube", ImVec2(80, 25)) then
					lua_thread.create(function()
						os.execute("start https://youtube.com/@qqsliverqq")
					end)
				end
				imgui.SameLine()
				if imgui.Button("Tg", ImVec2(40, 25)) then
					lua_thread.create(function()
						os.execute("start https://t.me/qqsliverqqtg")
					end)
				end
				imgui.SameLine()
				if imgui.Button("GitHub", ImVec2(60, 25)) then
					lua_thread.create(function()
						os.execute("start https://github.com/Lomtik655")
					end)
				end
				imgui.SameLine()
				if imgui.Button("BlastHack", ImVec2(80, 25)) then
					lua_thread.create(function()
						os.execute("start https://www.blast.hk/members/489152/")
					end)
				end
				
			imgui.End()
		end
    end
	
	-- Скип завода
	if Bots.ZavodMenuSkip.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(ImVec2(220, 100), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin(u8'SlivsMenu - Скип завода', Bots.ZavodMenuSkip, imgui.WindowFlags.NoResize)
			imgui.SetCursorPosX(5)
			imgui.SetCursorPosY(28)
			if imgui.Button(u8"Скипнуть завод", ImVec2(120, 50)) then
				lua_thread.create(function()
					local bs = raknetNewBitStream()
					local MyPacket = {215, 2, 0, 0, 0, 0, 0, 18, 0, 0, 0, 84, 117, 114, 110, 101, 114, 95, 79, 110, 80, 108, 97, 121, 101, 114, 69, 110, 100, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
				end)
			end
			
		imgui.End()
	end
	
end
function apply_custom_style()
	--ImGuiStyle.WindowPadding = ImVec2(5.0, 5.0)
    ImGuiStyle.WindowRounding = 0.0
    ImGuiStyle.WindowTitleAlign = ImVec2(0.5, 0.84)
    ImGuiStyle.ChildWindowRounding = 10.0
    ImGuiStyle.FrameRounding = 10.0
    ImGuiStyle.ItemSpacing = ImVec2(5.0, 3.0)
    ImGuiStyle.ScrollbarSize = 13.0
    ImGuiStyle.ScrollbarRounding = 5
    ImGuiStyle.GrabMinSize = 8.0
    ImGuiStyle.GrabRounding = 1.0

	--Alpha = 0,
	--WindowPadding = 1,
	--WindowRounding = 2,
	--WindowMinSize = 3,
	--ChildWindowRounding = 4,
	--FramePadding = 5,
	--FrameRounding = 6,
	--ItemSpacing = 7,
	--ItemInnerSpacing = 8,
	--IndentSpacing = 9,
	--GrabMinSize = 10,
	--ButtonTextAlign = 11,

    ImGuiColors[ImGuiClr.FrameBg]                = ImVec4(RGBA(148, 148, 148, 0.45))
    ImGuiColors[ImGuiClr.FrameBgHovered]         = ImVec4(RGBA(148, 148, 148, 0.6))
    ImGuiColors[ImGuiClr.FrameBgActive]          = ImVec4(RGBA(0, 255, 55, 0))
    ImGuiColors[ImGuiClr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    ImGuiColors[ImGuiClr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    ImGuiColors[ImGuiClr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
    ImGuiColors[ImGuiClr.CheckMark]              = ImVec4(RGBA(0, 255, 55, 1))
    ImGuiColors[ImGuiClr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    ImGuiColors[ImGuiClr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    ImGuiColors[ImGuiClr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    ImGuiColors[ImGuiClr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    ImGuiColors[ImGuiClr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    ImGuiColors[ImGuiClr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    ImGuiColors[ImGuiClr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    ImGuiColors[ImGuiClr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    ImGuiColors[ImGuiClr.Separator]              = ImGuiColors[ImGuiClr.Border]
    ImGuiColors[ImGuiClr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    ImGuiColors[ImGuiClr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    ImGuiColors[ImGuiClr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    ImGuiColors[ImGuiClr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    ImGuiColors[ImGuiClr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    ImGuiColors[ImGuiClr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    ImGuiColors[ImGuiClr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    ImGuiColors[ImGuiClr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    ImGuiColors[ImGuiClr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    ImGuiColors[ImGuiClr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    ImGuiColors[ImGuiClr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    ImGuiColors[ImGuiClr.ComboBg]                = ImGuiColors[ImGuiClr.PopupBg]
	ImGuiColors[ImGuiClr.Border]                 = ImVec4(RGBA(255, 255, 255, 0.00))
    ImGuiColors[ImGuiClr.BorderShadow]           = ImVec4(RGBA(160, 160, 160, 0.00))
    ImGuiColors[ImGuiClr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    ImGuiColors[ImGuiClr.ScrollbarBg]            = ImVec4(RGBA(0, 0, 0, 0))
    ImGuiColors[ImGuiClr.ScrollbarGrab]          = ImVec4(RGBA(255, 255, 255, 0.4))
    ImGuiColors[ImGuiClr.ScrollbarGrabHovered]   = ImVec4(RGBA(255, 255, 255, 0.8))
    ImGuiColors[ImGuiClr.ScrollbarGrabActive]    = ImVec4(RGBA(255, 255, 255, 1))
    ImGuiColors[ImGuiClr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    ImGuiColors[ImGuiClr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    ImGuiColors[ImGuiClr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    ImGuiColors[ImGuiClr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    ImGuiColors[ImGuiClr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    ImGuiColors[ImGuiClr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    ImGuiColors[ImGuiClr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    ImGuiColors[ImGuiClr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
function menus_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

	--style.WindowPadding = imgui.ImVec2(5.0, 5.0)
    style.WindowRounding = 10.0
    style.WindowTitleAlign = imgui.ImVec2(0.5, 0.84)
    style.ChildWindowRounding = 2.0
    style.FrameRounding = 10.0
    style.ItemSpacing = imgui.ImVec2(5.0, 4.0)
    style.ScrollbarSize = 13.0
    style.ScrollbarRounding = 0
    style.GrabMinSize = 8.0
    style.GrabRounding = 1.0

	--Alpha = 0,
	--WindowPadding = 1,
	--WindowRounding = 2,
	--WindowMinSize = 3,
	--ChildWindowRounding = 4,
	--FramePadding = 5,
	--FrameRounding = 6,
	--ItemSpacing = 7,
	--ItemInnerSpacing = 8,
	--IndentSpacing = 9,
	--GrabMinSize = 10,
	--ButtonTextAlign = 11,

    colors[clr.FrameBg]                = ImVec4(0.16, 0.29, 0.48, 0.54)
    colors[clr.FrameBgHovered]         = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.FrameBgActive]          = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.TitleBg]                = ImVec4(RGBA(90, 224, 83, 1))
    colors[clr.TitleBgActive]          = ImVec4(RGBA(90, 224, 83, 1))
    colors[clr.TitleBgCollapsed]       = ImVec4(RGBA(90, 224, 83, 0.51))
    colors[clr.CheckMark]              = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.SliderGrab]             = ImVec4(0.24, 0.52, 0.88, 1.00)
    colors[clr.SliderGrabActive]       = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Button]                 = ImVec4(0.26, 0.59, 0.98, 0.40)
    colors[clr.ButtonHovered]          = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ButtonActive]           = ImVec4(0.06, 0.53, 0.98, 1.00)
    colors[clr.Header]                 = ImVec4(0.26, 0.59, 0.98, 0.31)
    colors[clr.HeaderHovered]          = ImVec4(0.26, 0.59, 0.98, 0.80)
    colors[clr.HeaderActive]           = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.Separator]              = colors[clr.Border]
    colors[clr.SeparatorHovered]       = ImVec4(0.26, 0.59, 0.98, 0.78)
    colors[clr.SeparatorActive]        = ImVec4(0.26, 0.59, 0.98, 1.00)
    colors[clr.ResizeGrip]             = ImVec4(0.26, 0.59, 0.98, 0.25)
    colors[clr.ResizeGripHovered]      = ImVec4(0.26, 0.59, 0.98, 0.67)
    colors[clr.ResizeGripActive]       = ImVec4(0.26, 0.59, 0.98, 0.95)
    colors[clr.TextSelectedBg]         = ImVec4(0.26, 0.59, 0.98, 0.35)
    colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
    colors[clr.TextDisabled]           = ImVec4(0.50, 0.50, 0.50, 1.00)
    colors[clr.WindowBg]               = ImVec4(0.06, 0.06, 0.06, 0.94)
    colors[clr.ChildWindowBg]          = ImVec4(1.00, 1.00, 1.00, 0.00)
    colors[clr.PopupBg]                = ImVec4(0.08, 0.08, 0.08, 0.94)
    colors[clr.ComboBg]                = colors[clr.PopupBg]
    --colors[clr.Border]                 = ImVec4(0.43, 0.43, 0.50, 0.50)
	colors[clr.Border]                 = ImVec4(RGBA(4, 212, 28, 1))
	--colors[clr.Border]                 = ImVec4(MenuRgb_R, MenuRgb_G, MenuRgb_B, 0.50)
    colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
    colors[clr.MenuBarBg]              = ImVec4(0.14, 0.14, 0.14, 1.00)
    colors[clr.ScrollbarBg]            = ImVec4(0.02, 0.02, 0.02, 0.53)
    colors[clr.ScrollbarGrab]          = ImVec4(0.31, 0.31, 0.31, 1.00)
    colors[clr.ScrollbarGrabHovered]   = ImVec4(0.41, 0.41, 0.41, 1.00)
    colors[clr.ScrollbarGrabActive]    = ImVec4(0.51, 0.51, 0.51, 1.00)
    colors[clr.CloseButton]            = ImVec4(0.41, 0.41, 0.41, 0.50)
    colors[clr.CloseButtonHovered]     = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.CloseButtonActive]      = ImVec4(0.98, 0.39, 0.36, 1.00)
    colors[clr.PlotLines]              = ImVec4(0.61, 0.61, 0.61, 1.00)
    colors[clr.PlotLinesHovered]       = ImVec4(1.00, 0.43, 0.35, 1.00)
    colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
    colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
    colors[clr.ModalWindowDarkening]   = ImVec4(0.80, 0.80, 0.80, 0.35)
end
function createChild(windowName, x, y, posX, posY, color) -- менюшка
	imgui.SetCursorPosX(posX)
	imgui.SetCursorPosY(posY)
	ImGuiColors[ImGuiClr.ChildWindowBg] = color
	imgui.BeginChild(windowName, ImVec2(x, y), true)
end
function createChildCheatWindow(windowName, y, colum, posY, textX) -- менюшка для читов
	local x = 303 -- статичный размер менюшки по x
	--colum
	if colum == 1 then
		imgui.SetCursorPosX(5)
	elseif colum == 2 then
		imgui.SetCursorPosX(312)
	end
	imgui.SetCursorPosY(posY)
	ImGuiColors[ImGuiClr.ChildWindowBg] = ImVec4(RGBA(0, 0, 0, 0.40))
	imgui.BeginChild(windowName, ImVec2(x, y), true)
	createChild('CheatName', x-10, 23, 5, 0, ImVec4(RGBA(255, 29, 0, 0.80)))
		imgui.SetCursorPosX(textX)
		imgui.SetCursorPosY(1)
		imgui.PushFont(sizeCheatMenuHead)
		imgui.Text(windowName)
		imgui.PopFont()
	imgui.EndChild()
end
function imgui.TextQuestion(label, description) -- создание подсказки имгуи
    imgui.Text(label)
    if imgui.IsItemHovered() then
        imgui.BeginTooltip()
            imgui.PushTextWrapPos(600)
                imgui.TextUnformatted(description)
            imgui.PopTextWrapPos()
        imgui.EndTooltip()
    end
end

function RGBA(r, g, b, a)
	r = r / 255
	g = g / 255
	b = b / 255
	return r, g, b, a
end

-- Эвенты
function sampEvents.onSendPlayerSync(data)
	--sampAddChatMessage("animationId: " .. data.animationId .. " animationFlags:" .. data.animationFlags .. " specialAction:" .. data.specialAction, -1)
	
	return true
end

function sampEvents.onSendBulletSync(data)
	if Ohota.AimDuck_silent.v then
		for _, handle in pairs(getAllObjects()) do
			local model = getObjectModel(handle)
			if model == 10809 and isObjectOnScreen(handle) then
				local QuaternionX, QuaternionY, QuaternionZ, QuaternionW = getObjectQuaternion(handle)
				if (QuaternionX == 0) then
					local result, positionX_duck, positionY_duck, positionZ_duck = getObjectCoordinates(handle)
					local width, heigth = getScreenResolution()
					local fov = getCameraFov() * 0.0174530
					local coeficent = width / fov
					local distance = 0.025 * coeficent
					local width_crosshair, heigth_crosshair = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
					local wposX, wposY = convert3DCoordsToScreen(positionX_duck, positionY_duck, positionZ_duck+0.2)
					if Ohota.AimDuck.v then
						if (wposX > width_crosshair-(distance/2)) and (wposX < width_crosshair+(distance/2)) and (wposY > heigth_crosshair-(distance/2)) and (wposY < heigth_crosshair+(distance/2)) then
							data.targetType = 3
							data.targetId = sampGetObjectSampIdByHandle(handle)
							data.target.x = positionX_duck
							data.target.y = positionY_duck
							data.target.z = positionZ_duck+0.2
							data.center.x = 0
							data.center.y = 0
							data.center.z = 0
							break
						end
					else
						data.targetType = 3
						data.targetId = sampGetObjectSampIdByHandle(handle)
						data.target.x = positionX_duck
						data.target.y = positionY_duck
						data.target.z = positionZ_duck+0.2
						data.center.x = 0
						data.center.y = 0
						data.center.z = 0
						break
					end
				end
			end
		end
	end

end

-- Получение сообщений от сервера
function sampEvents.onServerMessage(color, text)
	-- Рыбалка
	if Fishing.Helper.v then
		if (Fishing.Combo.v == 0) then
			if string.find(text, 'Вы словили рыбу', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 0.5
			end
			if string.find(text, 'Рыба сорвалась с крючка.', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 1
			end
			if string.find(text, 'Угорь ударил вас током и уплыл.', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 0.5
			end
		elseif (Fishing.Combo.v == 1) then
			if string.find(text, 'Вы словили рыбу', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 2
			end
			if string.find(text, 'Рыба сорвалась с крючка.', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 3
			end
		elseif (Fishing.Combo.v == 2) then
			if string.find(text, 'Вы словили рыбу', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 1
			end
			if string.find(text, 'Рыба сорвалась с крючка.', 1, true) then
				Fishing.Fish_value = Fishing.Fish_value + 2
			end
		end
	end
	if Fishing.Bot.v then
		if string.find(text, 'Подсечка не удалась, рыба съела наживку и уплыла.', 1, true) then
			lua_thread.create(function()
				wait(3000)
				Fishing.Clicker_Alt:Start()
			end)
		end
		if string.find(text, 'У вас недостаточно свободного веса в инвентаре чтобы забрать рыбу.', 1, true) or string.find(text, 'У вас недостаточно места в инвентаре чтобы забрать рыбу.', 1, true) then
			Fishing.Bot.v = false
			sampAddChatMessage('{FFFF00}Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', -1)
			Fishing.Clicker_Alt:Stop()
		end
		if string.find(text, 'У вас закончилась наживка', 1, true) then
			Fishing.Bot.v = false
			sampAddChatMessage('{FFFF00}Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', -1)
			Fishing.Clicker_Alt:Stop()
		end
	end
	
	-- Боты	
	if Pilot.AutoEngine.v then
		if string.find(text, 'Посадка пассажиров завершена, можете выдвигаться.', 1, true) then
			lua_thread.create(function()
				wait(100)
				sampSendChat("/e")
			end)
		end
	end
	
	if AutoLogin.HideNickname.v then
		if string.find(text, AutoLogin.MainName, 1, true) then
			s = string.find(text, AutoLogin.MainName, 1, true)
			text = string.gsub(text, AutoLogin.MainName, AutoLogin.HideNickname_ChatName.v)
			sampAddChatMessage(text, -1)
			return false
		end
	end
end

function onReceivePacket(id, bs)
	if id == 215 then
		local _style = raknetBitStreamReadInt16(bs)
		local _type = raknetBitStreamReadInt32(bs)
		local l = raknetBitStreamReadInt8(bs)
		local style3 = raknetBitStreamReadInt8(bs)
		local length = raknetBitStreamReadInt32(bs)
		if length > 0 and length < 10000 then
			bitstreamtext = raknetBitStreamReadString(bs,length)
		else
			bitstreamtext = nil
		end
		if _style and _type and l and style3 and length and bitstreamtext then
			--print('Packet: '.._style..'/'.._type..'/'..l..'/'..style3..'/'..length..'/'..bitstreamtext)
			
			if AutoLogin.Status.v then
				if bitstreamtext == "Authorization" then
					local Password = tostring(config.AutoLogin.Password)
					local bs = raknetNewBitStream()
					raknetBitStreamWriteInt8(bs, 215)
					raknetBitStreamWriteInt8(bs, 2)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 20)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteString(bs, "OnAuthorizationStart")
					raknetBitStreamWriteInt8(bs, 2)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 115)
					raknetBitStreamWriteInt8(bs, string.len(Password))
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteInt8(bs, 0)
					raknetBitStreamWriteString(bs, Password)
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет					
				elseif AutoLogin.AutoPoevlenie.v and string.find(bitstreamtext, 'Хотите вернуться на место последнего выхода из игры?', 1, true) then 
					local bs = raknetNewBitStream()
					local MyPacket = {215, 2, 0, 0, 0, 0, 0, 16, 0, 0, 0, 79, 110, 68, 105, 97, 108, 111, 103, 82, 101, 115, 112, 111, 110, 115, 101, 8, 0, 0, 0, 100, 0, 0, 0, 0, 100, 1, 0, 0, 0, 100, 255, 255, 255, 255, 115, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
					return false
				end
			end
			
			if Fishing.Bot.v then
				if (_style == 727) and (_type == 512) and (l == 0) and (style3 == 1) and (length == 64) then
					local fish_percent = tonumber(string.sub(bitstreamtext, #bitstreamtext-5, #bitstreamtext-3))
					if fish_percent >= 60 then
						lua_thread.create(function()
							setVirtualKeyDown(VK_SPACE, true)
							wait(100)
							setVirtualKeyDown(VK_SPACE, false)
						end)
					end
				end
				if string.find(bitstreamtext, 'Вы хотите забрать или отпустить рыбу?', 1, true) then
					--727/512/0/1/195/window.addDialogInQueue('[0,6,"Улов","","Забрать","Отпустить",0,0]', ["Вы поймали Красноперка весом 0.2 кг.<n><n>Вы хотите забрать или отпустить рыбу?", "fishing/fish/-1.png"], 0)
					if Fishing.Bot_tunecOff.v and string.find(bitstreamtext, 'Тунец', 1, true) then
						lua_thread.create(function()
							wait(500)
							setVirtualKeyDown(VK_ESCAPE, true)
							wait(100)
							setVirtualKeyDown(VK_ESCAPE, false)
							wait(3500)
							Fishing.Clicker_Alt:Start()
						end)
					else
						lua_thread.create(function()
							wait(500)
							setVirtualKeyDown(VK_RETURN, true)
							wait(100)
							setVirtualKeyDown(VK_RETURN, false)
							wait(100)
							setVirtualKeyDown(VK_RETURN, true)
							wait(100)
							setVirtualKeyDown(VK_RETURN, false)
							wait(3500)
							Fishing.Clicker_Alt:Start()
						end)
					end
				end
				if string.find(bitstreamtext, 'fishing/sfx_fishing_swish.ogg', 1, true) then
					Fishing.Clicker_Alt:Stop()
				end
			end
			
			if Pilot.SkipTable.v then
				if string.find(bitstreamtext, "window.addDialogInQueue(\'[0,0,\"{FFCD00}Выберите действие\",\"\",\"Да\",\"Нет\",0,0,\"\"]\', \"{FFFFFF}Хотите ли вы продолжить выполнять рейсы?\", 0)", 1, true) then
					local bs = raknetNewBitStream()
					--                215, 2, 0, 0, 0, 0, 0, 16, 0, 0, 0, 79, 110, 68, 105, 97, 108, 111, 103, 82, 101, 115, 112, 111, 110, 115, 101, 8, 0, 0, 0, 100, 0, 0, 0, 0, 100, (0,1), 0, 0, 0, 100, 255, 255, 255, 255, 115, 0, 0, 0, 0
					local MyPacket = {215, 2, 0, 0, 0, 0, 0, 16, 0, 0, 0, 79, 110, 68, 105, 97, 108, 111, 103, 82, 101, 115, 112, 111, 110, 115, 101, 8, 0, 0, 0, 100, 0, 0, 0, 0, 100, 1, 0, 0, 0, 100, 255, 255, 255, 255, 115, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
					return false
				end
			end
			
			if Shahta.Clicker_Y_CheckBox.v then
				if string.find(bitstreamtext, 'interface(\'ProgressBar\').getBarInfo("[["Нажимайте Y <br>с небольшим интервалом",0,1000]]")', 1, true) then
					Shahta.Clicker_Y:Start()
				elseif string.find(bitstreamtext, 'interface(\'ProgressBar\').setFill(0, 100)', 1, true) then
					Shahta.Clicker_Y:Stop()
				end
			end
			
			if Bots.ZavodAutoSkip.v then
			--ЧTurner[1, 1] | 215, 2, 0, 4, 0, 0, 0, 2, 6, 0, 0, 0, 84, 117, 114, 110, 101, 114, 6, 0, 0, 0, 91, 49, 44, 32, 49, 93
			--ЧTurner_OnPlayerEnd | 215, 2, 0, 0, 0, 0, 0, 18, 0, 0, 0, 84, 117, 114, 110, 101, 114, 95, 79, 110, 80, 108, 97, 121, 101, 114, 69, 110, 100, 0, 0, 0, 0
				if string.find(bitstreamtext, 'Turner[', 1, true) then
					--print("нашли")
					lua_thread.create(function()
						--wait(math.random(12000, 29500))
						local bs = raknetNewBitStream()
						local MyPacket = {215, 2, 0, 0, 0, 0, 0, 18, 0, 0, 0, 84, 117, 114, 110, 101, 114, 95, 79, 110, 80, 108, 97, 121, 101, 114, 69, 110, 100, 0, 0, 0, 0}
						for i=1, #MyPacket do
							raknetBitStreamWriteInt8(bs, MyPacket[i])
						end
						raknetSendBitStream(bs) -- отправляем пакет
						raknetDeleteBitStream(bs) -- удаляем пакет
					end)
				end
			end
			
		end
	end
	
	raknetBitStreamResetReadPointer(bs)
	local text, packets
	local bss = raknetNewBitStream()
	local mod_bss = false
	

	if not raknetGetPacketName(id) then
		text, packets = bitStreamStructure(bs)
		if AutoLogin.HideNickname.v then
			local searchPos = 1
			local replaceCount = 0
			
			-- Цикл while для поиска всех вхождений
			while true do
				local startPos, endPos = string.find(text, AutoLogin.MainName, searchPos, true)
				if not startPos then
					break
				end
				
				replaceCount = replaceCount + 1
				replaceBytes(packets, startPos, stringToBytes(string.rep("a", #AutoLogin.MainName)))
				searchPos = startPos + #AutoLogin.MainName
			end
			
			-- Если были замены, создаем новый битстрим
			if replaceCount > 0 then
				for i = 1, #packets do
					raknetBitStreamWriteInt8(bss, packets[i])
				end
				text, packets = bitStreamStructure(bss)
				mod_bss = true
			end
		end
	end
	if mod_bss then
		return true, id, bss
	end
end
function bitStreamStructure(bs)
    local text, array = '', {}
    for i = 1, raknetBitStreamGetNumberOfBytesUsed(bs) do
        local byte = raknetBitStreamReadInt8(bs)
        if byte >= 32 and byte <= 255 and byte ~= 37 then 
			text = text .. string.char(byte)
		else
			text = text .. "*"
		end
        table.insert(array, byte)
    end
    raknetBitStreamResetReadPointer(bs)
    return text, array
end
function replaceBytes(array, position, bytes)
    local bytes_count = #bytes
    local old_count = #array
    
    -- Определяем, сколько элементов нужно удалить/заменить
    local replace_count = math.min(bytes_count, old_count - position + 1)
    
    -- Заменяем элементы
    for i = 1, replace_count do
        array[position + i - 1] = bytes[i]
    end
    
    -- Если новых байтов больше, чем заменяемых, добавляем остальные
    if bytes_count > replace_count then
        -- Сдвигаем хвост вправо, чтобы освободить место
        local shift = bytes_count - replace_count
        for i = old_count, position + replace_count, -1 do
            array[i + shift] = array[i]
        end
        
        -- Вставляем оставшиеся байты
        for i = replace_count + 1, bytes_count do
            array[position + i - 1] = bytes[i]
        end
        
    -- Если новых байтов меньше, чем заменяемых, удаляем лишние
    elseif bytes_count < replace_count then
        local shift = replace_count - bytes_count
        for i = position + replace_count, old_count do
            array[i - shift] = array[i]
        end
        
        -- Удаляем "хвостовые" элементы
        for i = old_count - shift + 1, old_count do
            array[i] = nil
        end
    end
end
function stringToBytes(str)
    local bytes = {}
    for i = 1, #str do
        bytes[i] = string.byte(str, i)
    end
    return bytes
end

--Аим на уток
function checkObject_duck(handle)
	if not doesObjectExist(handle) then
		return false
	end
	local _, x, y, z = getObjectCoordinates(handle)
	local model = getObjectModel(handle)
	--Проверяем чтобы был на экране
	if not isObjectOnScreen(handle) then
		return false
	end

	if model ~= 10809 then
		return false
	end
	--Чекаем чтобы было не за стенами
	local pedX, pedY, pedZ = getActiveCameraCoordinates()
	local result, colPoint = processLineOfSight(pedX, pedY, pedZ, x, y, z, true, false, false, false, false, false, false, false)
	if result then
		return false
	end

	local QuaternionX, QuaternionY, QuaternionZ, QuaternionW = getObjectQuaternion(handle)
	if (QuaternionX ~= 0) then
		return false
	end

	return true
end
function targetAtCoords(x, y, z)
	if Ohota.AimDuck.v then
		z = z + 0.2
	end
    local cx, cy, cz = getActiveCameraCoordinates()

    local vect = {
        fX = cx - x,
        fY = cy - y,
        fZ = cz - z
    }

    local screenAspectRatio = representIntAsFloat(readMemory(0xC3EFA4, 4, false))
    local crosshairOffset = {
        representIntAsFloat(readMemory(0xB6EC10, 4, false)),
        representIntAsFloat(readMemory(0xB6EC14, 4, false))
    }

    -- weird shit
    local mult = math.tan(getCameraFov() * 0.5 * 0.017453292)
    fz = 3.14159265 - math.atan2(1.0, mult * ((0.5 - crosshairOffset[1]) * (2 / screenAspectRatio)))
    fx = 3.14159265 - math.atan2(1.0, mult * 2 * (crosshairOffset[2] - 0.5))

    local camMode = readMemory(0xB6F1A8, 1, false)

    if not (camMode == 53 or camMode == 55) then -- sniper rifle etc.
        fx = 3.14159265 / 2
        fz = 3.14159265 / 2
    end

    local ax = math.atan2(vect.fY, -vect.fX) - 3.14159265 / 2
    local az = math.atan2(math.sqrt(vect.fX * vect.fX + vect.fY * vect.fY), vect.fZ)

	--sampAddChatMessage(az-fz .. " | " .. fx-ax, -1)
	--renderFontDrawText(font, string.format('1: %0.4f  2: %0.4f', az-fz, fx-ax), sw/2-50, sh/2-28, 0xFFFFFFFF)
	--renderFontDrawText(font, string.format('1: %0.4f  2: %0.4f', cx, x), sw/2-50, sh/2-40, 0xFFFFFFFF)
    setCameraPositionUnfixed(az - fz, fx - ax)
end
function Ohota_AutoTakeDuck_thread_Func()
	sampSendChat("/take_duck")
	wait(1000)
end

function samp_create_sync_data(sync_type, copy_from_player)
	local ffi, sampfuncs, raknet=require("ffi"),require("sampfuncs"),require("samp.raknet")
	require("samp.synchronization")

	local sync_hooks={
		player={"PlayerSyncData",raknet.PACKET.PLAYER_SYNC,sampStorePlayerOnfootData},
		vehicle={"VehicleSyncData",raknet.PACKET.VEHICLE_SYNC,sampStorePlayerIncarData},
		passenger={"PassengerSyncData",raknet.PACKET.PASSENGER_SYNC,sampStorePlayerPassengerData},
		aim={"AimSyncData",raknet.PACKET.AIM_SYNC,sampStorePlayerAimData},
		trailer={"TrailerSyncData",raknet.PACKET.TRAILER_SYNC,sampStorePlayerTrailerData},
		unoccupied={"UnoccupiedSyncData",raknet.PACKET.UNOCCUPIED_SYNC,nil},
		bullet={"BulletSyncData",raknet.PACKET.BULLET_SYNC,nil},
		spectator={"SpectatorSyncData",raknet.PACKET.SPECTATOR_SYNC,nil}
	}
	local sync_info, data_type = sync_hooks[sync_type], "struct " .. sync_hooks[sync_type][1]
	local data = ffi.new(data_type,{})
	local raw_data_ptr = tonumber(ffi.cast("uintptr_t",ffi.new(data_type .. "*" ,data)));

	if copy_from_player ~= false then
        local copy_func = sync_info[3]
        if copy_func then
            local _, player_id = sampGetPlayerIdByCharHandle(PLAYER_PED)
            copy_func(player_id, raw_data_ptr)
        end
    end

	local func_send=function()
		local bs=raknetNewBitStream()
		raknetBitStreamWriteInt8(bs,sync_info[2])
		raknetBitStreamWriteBuffer(bs,raw_data_ptr,ffi.sizeof(data))
		raknetSendBitStreamEx(bs,sampfuncs.HIGH_PRIORITY,sampfuncs.UNRELIABLE_SEQUENCED, 1)
		raknetDeleteBitStream(bs)
	end

	return setmetatable({send=func_send},{
		__index=function(t, index) return data[index] end,
		__newindex=function(t, index, value) data[index]=value end
	})
end
--GoToPoint
do
	local sub = function(a, b)
		return vector3d(a.x - b.x, a.y - b.y, a.z - b.z)
	end
	local length = function(vec)
		return math.sqrt((vec.x*vec.x)+(vec.y*vec.y)+(vec.z*vec.z))
	end

	local _autoMode_Run_Minleght = 5
	local _jumpMinLength = 10

	local function _calcAngle(x, y)
		local px, py = getCharCoordinates(PLAYER_PED)
		local plus = 0.0
		local mode = 1
		if px < x and py > y then plus = math.pi/2; mode = 2 end
		if px < x and py < y then plus = math.pi end
		if px > x and py < y then plus = math.pi*1.5; mode = 2 end
		local lx = x - px
		local ly = y - py
		lx = math.abs(lx)
		ly = math.abs(ly)
		if mode == 1 then ly = ly/lx
		else ly = lx/ly end
		ly = math.atan(ly)
		ly = ly + plus
		return ly
	end

	local function _setAngle(x, y, distance, speed)
		setCameraPositionUnfixed(-0.3, _calcAngle(x,y))
	end

	local function _justGoToPoint(x, y, z, moveMode, runAutoMode)
		local runAutoMode = runAutoMode or MoveMode.Run

		local last_jump_time = winmm.timeGetTime()
		math.randomseed(os.time())
		local cur_jump_mul = math.random(500)

		local target = vector3d(x, y, z)

		repeat
			if Bots.Stop.v then
				setGameKeyState(gkeys.player.GOFORWARD_GOBACK, 0)
				setGameKeyState(gkeys.player.SPRINT, 0)
				setGameKeyState(gkeys.player.JUMP, 0)
				
				while Bots.Stop.v do
					wait(100)
				end
			end
			
			local ppos = vector3d(getCharCoordinates(PLAYER_PED))
			local dist_lost = length(sub(vector3d(ppos.x, ppos.y, 0), vector3d(target.x, target.y, 0)))
			local targetMoveMode = moveMode == MoveMode.Auto and (dist_lost > _autoMode_Run_Minleght and runAutoMode or MoveMode.Walk) or moveMode
			
			_setAngle(target.x, target.y, dist_lost, 0.1)

			setGameKeyState(gkeys.player.GOFORWARD_GOBACK, -255)

			if dist_lost >= _jumpMinLength and targetMoveMode == MoveMode.Run and (winmm.timeGetTime() - last_jump_time) >= 1500 + cur_jump_mul then
				setGameKeyState(gkeys.player.JUMP, 255)
				last_jump_time = winmm.timeGetTime()
				math.randomseed(os.time())
				cur_jump_mul = math.random(500)
				goto continue
			end

			if targetMoveMode == MoveMode.Run or targetMoveMode == MoveMode.RunOnJump then
				setGameKeyState(gkeys.player.SPRINT, 255)
			end
		::continue:: wait(0) until dist_lost < 0.7
	end

	GoToPoint = function(x, y, z, moveMode, runAutoMode, __nesting)
		return _justGoToPoint(x, y, z, moveMode, runAutoMode)
	end
end
WalkPath = function(path)
   for _, node in pairs(path) do
      GoToPoint(unpack(node))
   end
end
function check3dText(handle, text_to_search)
	if not sampIs3dTextDefined(handle) then
		return false
	end
	local text, color, x, y, z, distance, ignoreWalls, playerId, vehicleId = sampGet3dTextInfoById(handle)
	
	if not string.find(text, text_to_search) then
		return false
	end
	
	local pedX, pedY, pedZ = getActiveCameraCoordinates()
	local result, colPoint = processLineOfSight(pedX, pedY, pedZ, x, y, z, true, false, false, false, false, false, false, false)
	if result then
		return false
	end
	
	return true
end