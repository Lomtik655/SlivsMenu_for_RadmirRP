-- Script head
script_name('SlivsMenu for RadmirRP by QQSliverQQ') -- название скрипта
script_author('QQSliverQQ') -- автор скрипта
script_description('SlivsMenu for RadmirRP') -- описание скрипта

require "lib.moonloader"
require "lib.sampfuncs"

-- Include
local sampev = require 'lib.samp.events'
local imgui = require 'imgui'
local encoding = require 'encoding'
encoding.default = "CP1251"
u8 = encoding.UTF8
local keys = require 'vkeys'
local vector3d = require 'vector3d'
local inicfg = require 'inicfg'
local mem = require 'memory'

local sw, sh = getScreenResolution()

-- Colors
main_color = "0xFFFFFF"
yellow_color = "0xFFFF00"
red_color = "0xFF0000"
nops_color_text = "{FFFF00}"
yellow_color_text = "{FFFF00}"

-- Peremenns
local main_window_state = imgui.ImBool(false)

--Менюшки
	local main_menu_legit = true
	local main_menu_rage = false
	local main_menu_settings = false

	--Легит
		local fishing_window_state = imgui.ImBool(false)
		local ohota_window_state = imgui.ImBool(false)
		local halloween_window_state = imgui.ImBool(false)
		local diving_window_state = imgui.ImBool(false)
		local pilot_window_state = imgui.ImBool(false)
		
		local fishing_helper = imgui.ImBool(false)
		local fishing_helper_buffer = imgui.ImBuffer(256)
		local fishing_helper_bot = imgui.ImBool(false)
		fishing_helper_buffer.v = tostring(0)
		local fish_value = 0
		local fishing_combo = imgui.ImInt(0)
		local fishing_array = {u8"Спиннинг", u8"Поплавочная удочка", u8"Улучшенная удочка"}
		local fishing_bot = imgui.ImBool(false)
		local fishing_bot_key = imgui.ImBool(false)
		local fishing_spamAlt_thread_stop = false
		local fishing_bot_tunecOff = imgui.ImBool(false)
		local legit_whohota = imgui.ImBool(false)
		local legit_whDuck = imgui.ImBool(false)
		local legit_whDuck_traser = imgui.ImBool(false)
		local legit_AutoTakeDuck = imgui.ImBool(false)
		local legit_aimDuck = imgui.ImBool(false)
		local legit_aimDuck_silent = imgui.ImBool(false)
		local legit_PilotAutoSkipTable = imgui.ImBool(false)
		local legit_whDiving = imgui.ImBool(false)
		local legit_whDiving_traser = imgui.ImBool(false)

		--Угон машин, гм
		local rage_ygonAvto = imgui.ImBool(false)
		local fun_gm_window_state = imgui.ImBool(false)
		local fun_gm = imgui.ImBool(false)
		local fun_gm1 = imgui.ImBool(false)
		--Телепорт атп
		local fun_TpOnCoord_TPshim = false
		local fun_TpOnCoord_syncPacketCount = 0
		local fun_TpOnCoord_tpWait = 1100
		local fun_TpOnCoord_tpTime
		local fun_teleport_window_state = imgui.ImBool(false)
	--Боты
		local ferma1TpPerenos = false
		local ferma2TpPerenos = false
		local fermaTpVspah = false

		local fermaCheckpointPosX = 0.0
		local fermaCheckpointPosY = 0.0
		local fermaCheckpointPosZ = 0.0
	--Настройки
		local settings_ActivationInsert = imgui.ImBool(false)
		local settings_AutoY = imgui.ImBool(false)
		local settings_AutoY_clicker = false
		
	--Хеллоуин
		local legit_halloween_sendListovka = imgui.ImBool(false)

--размер шрифта
	local headsize = nil
	local menu_buttonText_size = nil
	local menu_HeadFuncText_size = nil
	local menu_buttonCheatText_size = nil

-- Авто-логин
local autologin_window_state = imgui.ImBool(false)
local autologin_buffer = imgui.ImBuffer(256)
local config = inicfg.load({
  AutoLogin =
  {
	AutoLoginStatus=false,
	Password="pass"
  },
  Settings = {
	ActivationInsert=false,
	AutoY=false
  }
})
local AutoLoginStatus = imgui.ImBool(false)
AutoLoginStatus.v = config.AutoLogin.AutoLoginStatus
autologin_buffer.v = tostring(config.AutoLogin.Password)
settings_ActivationInsert.v = config.Settings.ActivationInsert
settings_AutoY.v = config.Settings.AutoY

-- Update
local dlstatus = require('moonloader').download_status

update_state = false

local script_vers = 162
local script_vers_text = "1.62"

local update_url = "https://github.com/Lomtik655/SlivsMenu_for_RadmirRP/raw/refs/heads/main/update.ini"
local update_path = getWorkingDirectory() .. "/radmirSlivsMenu.ini"

local script_url = "https://github.com/Lomtik655/SlivsMenu_for_RadmirRP/raw/refs/heads/main/SlivsMenu%20for%20RadmirRP.lua"
local script_path = thisScript().path

-- Functions
function main()
	if not isSampLoaded() or not isSampfuncsLoaded then return end
	while not isSampAvailable() do wait(100) end

	-- Обновление скрипта
	downloadUrlToFile(update_url, update_path, function(id, status)
		if status == dlstatus.STATUS_ENDDOWNLOADDATA then
			updateIni = inicfg.load(nil, update_path)
			if tonumber(updateIni.info.vers) > script_vers then
				sampAddChatMessage("Вышла обнова {00ff00}SlivsMenu {00b7ff}RadmirRP {f5a207}by QQSliverQQ! {FFFFFF}Начинаю загрузку...", -1)
				update_state = true
			end
			os.remove(update_path)
		end
	end)

	if not update_state then
		if settings_ActivationInsert.v then
			sampAddChatMessage("{00ff00}SlivsMenu {00b7ff}for RadmirRP {f5a207}by QQSliverQQ. {ffffff}Загружен!", -1)
			sampAddChatMessage("Активация ---> {eefa05}/sm{ffffff}, {eefa05}INSERT", -1)
		else
			sampAddChatMessage("{00ff00}SlivsMenu {00b7ff}for RadmirRP {f5a207}by QQSliverQQ. {ffffff}Загружен!", -1)
			sampAddChatMessage("Активация ---> {eefa05}/sm{ffffff}", -1)
		end
	end
	
	--Потоки
		--thread = lua_thread.create_suspended(thread_func) | thread:run() - выполнить
	fishing_spamAlt_thread = lua_thread.create_suspended(fishing_spamAlt_thread_function)
	legit_autoTakeDuck_thread = lua_thread.create_suspended(legit_autoTakeDuck_thread_function)
	ferma1TpPerenos_thread = lua_thread.create_suspended(ferma1TpPerenos_thread_function)
    ferma2TpPerenos_thread = lua_thread.create_suspended(ferma2TpPerenos_thread_function)
	fermaTpVspah_thread = lua_thread.create_suspended(fermaTpVspah_thread_function)
	
	-- Команды
	sampRegisterChatCommand("sm", imgui_main_window_state)
	sampRegisterChatCommand("rtp", function()
		local x, y, z
		--Ищем корды в памяти
		modulehandle = getModuleHandle("clientside.dll")
		fulladr = mem.getint32(modulehandle + 0x431110)
		ptr = '0x'.. string.format("%x", fulladr) --получили куда указывает указатель

		x = mem.getfloat(ptr + 0x10) --добавили к найденной памяти указателя оффсет
		y = mem.getfloat(ptr + 0x14)
		z = 1000.0
		z = getGroundZFor3dCoord(x,y,z)

		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		fun_TpOnCoord_tpTime=os.clock()
		--sampAddChatMessage("x:" .. x .. " y:" .. y, -1)
		if isCharInAnyCar(PLAYER_PED) then
			moveToBlip(x,y,z+15)
		else
			moveToBlip(x,y,z)
		end
	end)
	sampRegisterChatCommand("rtpc", function(arg)
		local carHandle
		local xStr, yStr, zStr = string.match(arg, "(.+) (.+) (.+)")
		local x, y, z
		if xStr == nil or xStr == "" then
			sampAddChatMessage("{c300ff}ATP/MTP by L.team: {ffffff}Введены не все корды, надо: x y z", -1)
		else
			x = tonumber(xStr); y = tonumber(yStr); z = tonumber(zStr);
			fun_TpOnCoord_syncPacketCount=0
			fun_TpOnCoord_TPshim = true
			fun_TpOnCoord_tpTime=os.clock()
			moveToBlip(x,y,z)
		end
	end)
	
	sampRegisterChatCommand("per1", function(arg)
		ferma1TpPerenos = not ferma1TpPerenos
		if ferma1TpPerenos then
			sampAddChatMessage("Начинаем тепаться", -1)
			ferma1TpPerenos_thread:run()
		else
			sampAddChatMessage("Дотепываемся последний раз", -1)
		end
	end)
	sampRegisterChatCommand("per2", function(arg)
		ferma2TpPerenos = not ferma2TpPerenos
		if ferma2TpPerenos then
			sampAddChatMessage("Начинаем тепаться", -1)
			ferma2TpPerenos_thread:run()
		else
			sampAddChatMessage("Дотепываемся последний раз", -1)
		end
	end)
	sampRegisterChatCommand("vspah", function(arg)
		fermaTpVspah = not fermaTpVspah
		if fermaTpVspah then
			sampAddChatMessage("Начинаем тепаться", -1)
			fermaTpVspah_thread:run()
		else
			sampAddChatMessage("Дотепываемся последний раз", -1)
		end
	end)
	sampRegisterChatCommand("grab_metka", function(arg)
		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		moveTudaObratno(fermaCheckpointPosX, fermaCheckpointPosY, fermaCheckpointPosZ) -- тп на метку
	end)
	
	--Фонты
	font = renderCreateFont('Verdana', 10, 9)
	font1 = renderCreateFont('Verdana', 6, 4)
	fish_font = renderCreateFont('Arial', 15, 13)
	fish_font_2 = renderCreateFont('Arial', 15, 8)
	fish_font_warn = renderCreateFont('Arial', 35, 13)
	font_whohota = renderCreateFont('Arial', 7, 13)

	imgui.Process = false
    while true do
        wait(0)
		-- Обновление скрипта
		if update_state then
			downloadUrlToFile(script_url, script_path, function(id, status)
				if status == dlstatus.STATUS_ENDDOWNLOADDATA then
					sampAddChatMessage("{00ff00}SlivsMenu {00b7ff}for RadmirRP {f5a207}by QQSliverQQ {0bff00}успешно обновлен :P", -1)
				end
			end)
			break
		end

		if fishing_bot_key.v then
			if isKeyJustPressed(VK_B) then
				if (fishing_bot.v) then
					fishing_bot.v = false
					sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', main_color)
					if not fishing_spamAlt_thread.dead then
						fishing_spamAlt_thread_stop = true
					end
				else
					fishing_bot.v = true
					sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Начинаю работать :P', main_color)
					lua_thread.create(function()
						wait(500)
						fishing_spamAlt_thread:run()
					end)
				end
			end
		end

		-- Легит
			-- Помощник для рыбалки
			if fishing_helper.v then
				local resX, resY = getScreenResolution()
				if (fish_value < 70) then
					renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBF09ff00, 3, 0x00FF8A00) -- зеленый
					renderFontDrawText(fish_font, string.format('Износ: ' .. fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
				elseif (fish_value >= 70  and fish_value < 80) then
					renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBFffd600, 3, 0x00FF8A00) -- желтый
					renderFontDrawText(fish_font, string.format('Износ: ' .. fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
				elseif (fish_value >= 80 and fish_value < 97) then
					renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBFff8e00, 3, 0x00FF8A00) -- оранжевый
					renderFontDrawText(fish_font, string.format('Износ: ' .. fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
				else
					renderDrawBoxWithBorder(resX/2-175, resY/2-5, 140, 40, 0xBFff0000, 3, 0x00FF8A00) -- красный
					renderFontDrawText(fish_font, string.format('Износ: ' .. fish_value), resX/2-170, resY/2, 0xFFFFFFFF)
					renderFontDrawText(fish_font_warn, string.format('Осторожно!'), resX/2-130, resY/2-150, 0xFFFFFFFF)
				end
			end

			if not (tonumber(fishing_helper_buffer.v) == nil) and (tonumber(fishing_helper_buffer.v) < 0) then
				fishing_helper_buffer.v = tostring(0)
			elseif not (tonumber(fishing_helper_buffer.v) == nil) and (tonumber(fishing_helper_buffer.v) > 100) then
				fishing_helper_buffer.v = tostring(100)
			end

			if fish_value >= 98 and fishing_bot.v then
				fishing_bot.v = false
				sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Слишком большой износ', main_color)
				if not fishing_spamAlt_thread.dead then
					fishing_spamAlt_thread_stop = true
				end
			end
			
			-- Вх на охоту
			if legit_whohota.v then
				for pairsId, value in pairs(getAllChars()) do
					if value ~= PLAYER_PED and doesCharExist(value) then
						local modelid = getCharModel(value)
						if isCharOnScreen(value) then
							local QuaternionX, QuaternionY, QuaternionZ, QuaternionW = getCharQuaternion(value)
							local x,y,z = getCharCoordinates(playerPed)
							local posX,posY,posZ = getCharCoordinates(value)
							local X,Y = convert3DCoordsToScreen(x, y, z)
							local _X,_Y = convert3DCoordsToScreen(posX, posY, posZ)
							if modelid == 15555 then
								renderFontDrawText(font_whohota,'Олень',_X,_Y, 0xFF00FF00)
							elseif modelid == 15556 then
								renderFontDrawText(font_whohota,'Медведь',_X,_Y, 0xFF00FF00)
							end
						end
					end
				end
			end
			-- Бот рыбалка
			if fishing_bot.v then
				local resX, resY = getScreenResolution()
				renderFontDrawText(fish_font_2, "Фармим", resX/2-170, resY/2+30, 0xFFFFFFFF)
			end

			--Вх на уток
			if legit_whDuck.v then
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
							if (QuaternionX == 0) then
								renderFontDrawText(font_whohota, "Утка".." "..distance, x1, y1, 0xFF00FF00)
								if legit_whDuck_traser.v then
									renderDrawLine(x10, y10, x1, y1, 1.0, 0xFF00FF00)
								end
							elseif not(QuaternionX == 0) then
								renderFontDrawText(font_whohota, "Мертвая утка", x1, y1, 0xFF00FF00)
								if legit_whDuck_traser.v then
									renderDrawLine(x10, y10, x1, y1, 1.0, 0xFF00FF00)
								end
							end
						end
					end
				end
			end
			--Если включен автоподбор
			if legit_AutoTakeDuck.v then
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
								if (getDistanceBetweenCoords3d(x, y, z, x2, y2, z2) <= 2.3) and ((legit_autoTakeDuck_thread:status() == "dead") or (legit_autoTakeDuck_thread:status() == "suspended"))then
									legit_autoTakeDuck_thread:run()
								end
							end
						end
					end
				end

			end

			--Аим на уток
			local camMode = readMemory(0xB6F1A8, 1, false)
			if camMode == 53 or camMode == 55 or camMode == 7 or camMode == 8 then
				local width, heigth = getScreenResolution()
				local fov = getCameraFov() * 0.0174530
				local coeficent = width / fov
				local distance = 0.025 * coeficent
				local width_crosshair, heigth_crosshair = convertGameScreenCoordsToWindowScreenCoords(339.1, 179.1)
				if legit_aimDuck.v then
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
			
			if fun_TpOnCoord_TPshim then
				renderFontDrawText(font, "Teleporting", sw/2-15, sh/2+50, 0xFFFFFFFF)
			end
			
			--Вх на дайвинг
			if legit_whDiving.v then
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
							renderFontDrawText(font_whohota, "Сундук".." "..distance, x1, y1, 0xFF00FF00)
							if legit_whDiving_traser.v then
								renderDrawLine(x10, y10, x1, y1, 1.0, 0xFF00FF00)
							end
						end
					end
				end
			end
			
			--Хеллоуин
			if legit_halloween_sendListovka.v then
				if isKeyDown(keys.VK_RBUTTON) and wasKeyPressed(keys.VK_B) then
					local bs = raknetNewBitStream()
					local MyPacket = {215, 2, 0, 0, 0, 0, 0, 19, 0, 0, 0, 77, 101, 110, 117, 73, 110, 116, 95, 79, 110, 80, 108, 97, 121, 101, 114, 75, 101, 121, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
					
					bs = raknetNewBitStream()
					MyPacket = {215, 2, 0, 0, 0, 0, 0, 25, 0, 0, 0, 77, 101, 110, 117, 73, 110, 116, 95, 79, 110, 80, 108, 97, 121, 101, 114, 67, 108, 105, 99, 107, 73, 116, 101, 109, 4, 0, 0, 0, 100, 1, 0, 0, 0, 100, 1, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
					
					bs = raknetNewBitStream()
					MyPacket = {215, 2, 0, 0, 0, 0, 0, 25, 0, 0, 0, 77, 101, 110, 117, 73, 110, 116, 95, 79, 110, 80, 108, 97, 121, 101, 114, 67, 108, 105, 99, 107, 73, 116, 101, 109, 4, 0, 0, 0, 100, 58, 0, 0, 0, 100, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
					
					bs = raknetNewBitStream()
					MyPacket = {215, 2, 0, 0, 0, 0, 0, 24, 0, 0, 0, 77, 101, 110, 117, 73, 110, 116, 95, 79, 110, 67, 108, 111, 115, 101, 73, 110, 116, 101, 114, 102, 97, 99, 101, 2, 0, 0, 0, 100, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
				end
			end
		
		--Активация на INSERT
		if settings_ActivationInsert.v and isKeyJustPressed(VK_INSERT) then
			imgui_main_window_state()
		end
        if not main_window_state.v then
            imgui.Process = false
		else
			imgui.Process = true
        end
    end
end

function imgui_main_window_state(arg)
	main_window_state.v = not main_window_state.v
	imgui.Process = main_window_state.v
end
-- Основная отрисовка ИмГуи
function imgui.OnDrawFrame()
	imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	-- Главное окно
    if main_window_state.v then
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(650, 450), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))
		colors[clr.WindowBg] = ImVec4(RGBA(4, 212, 28, 0.20))
		--colors[clr.WindowBg] = ImVec4(RGBA(255, 134, 5, 0.95))
		local mainColorChild = ImVec4(RGBA(245, 161, 5, 1))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP', main_window_state, imgui.WindowFlags.NoResize + imgui.WindowFlags.NoTitleBar)
		apply_custom_style()

		--Голова окна
		colors[clr.Border] = ImVec4(RGBA(4, 212, 28, 0))
		createChild("", 645, 445, 2, 2, ImVec4(RGBA(4, 212, 28, 0.30)))
			createChild("", 635, 435, 5, 5, ImVec4(RGBA(4, 212, 28, 0.6)))
				createChild("", 625, 425, 5, 5, ImVec4(RGBA(255, 255, 255, 1)))
					colors[clr.Border] = ImVec4(RGBA(255, 255, 255, 0.7))
					createChild("", 620, 420, 2, 3, ImVec4(RGBA(138, 138, 138, 0.95)))
						apply_custom_style()
							imgui.SetCursorPosX(590)

						colors[clr.Button]        = ImVec4(RGBA(255, 0, 0, 0.7))
						colors[clr.ButtonHovered] = ImVec4(RGBA(255, 0, 0, 0.5))
						colors[clr.ButtonActive]  = ImVec4(RGBA(255, 0, 0, 0.2))
							if imgui.Button("X", imgui.ImVec2(20, 20)) then
								main_window_state.v = false
								imgui.Process = main_window_state.v
							end
						apply_custom_style()
							imgui.SameLine()
							imgui.SetCursorPosX(220)
							imgui.PushFont(headsize)
								imgui.Text('Slivs Menu', main_color)
							imgui.PopFont()
							imgui.SameLine()
							imgui.Text("v" .. script_vers_text, main_color)

						imgui.Separator() -- Линия

						-- Кнопки менюшек
						imgui.SetCursorPosY(65)
						colors[clr.Button]        = ImVec4(RGBA(201, 201, 201, 0.7))
						colors[clr.ButtonHovered] = ImVec4(RGBA(201, 201, 201, 0.5))
						colors[clr.ButtonActive]  = ImVec4(RGBA(201, 201, 201, 0.2))
						imgui.PushFont(menu_buttonText_size)
						if imgui.Button(u8"Легит", imgui.ImVec2(120, 50)) then
							main_menu_exitAll()
							main_menu_legit = true
						end
						if imgui.Button(u8"Рэйдж", imgui.ImVec2(120, 50)) then
							main_menu_exitAll()
							main_menu_rage = true
						end
						if imgui.Button(u8"Настройки", imgui.ImVec2(120, 50)) then
							main_menu_exitAll()
							main_menu_settings = true
						end
						imgui.PopFont()

						apply_custom_style()
						colors[clr.Button] = ImVec4(RGBA(90, 224, 83, 0.9))
						colors[clr.ButtonHovered] = ImVec4(RGBA(90, 224, 83, 0.5))
						colors[clr.ButtonActive]  = ImVec4(RGBA(90, 224, 83, 0.2))

						--Менюшки
						if main_menu_legit then -- Легит
							createChild("1", 470, 350, 140, 65, mainColorChild)
							imgui.SetCursorPosX(25)
							imgui.SetCursorPosY(15)
							imgui.PushFont(menu_buttonCheatText_size)
							if imgui.Button(u8"Рыбалка", imgui.ImVec2(202, 50)) then
								fishing_window_state.v = true
							end
							imgui.SameLine()
							if imgui.Button(u8"Охота", imgui.ImVec2(202, 50)) then
								ohota_window_state.v = true
							end
							imgui.SetCursorPosX(25)
							if imgui.Button(u8"Дайвинг", imgui.ImVec2(202, 50)) then
								diving_window_state.v = true
							end
							imgui.SameLine()
							if imgui.Button(u8"Пилот", imgui.ImVec2(202, 50)) then
								pilot_window_state.v = true
							end
							imgui.SetCursorPosX(25)
							if imgui.Button(u8"Хеллоуин", imgui.ImVec2(202, 50)) then
								halloween_window_state.v = true
							end
							imgui.PopFont()
							
							--Авто-логин
							imgui.SetCursorPosX(25)
							if imgui.Button(u8"Авто-логин", imgui.ImVec2(100, 50)) then
								autologin_window_state.v = true
							end
							
							imgui.EndChild()
						end
						
						if main_menu_rage then -- Рэйдж
							createChild("1", 470, 350, 140, 65, mainColorChild)
							imgui.SetCursorPosX(25)
							imgui.SetCursorPosY(15)
							--Угон авто
								if imgui.Checkbox(u8'Угон авто', rage_ygonAvto) then end
							
							--Гм
								imgui.SetCursorPosX(25)
								if imgui.Button(u8"Гм", imgui.ImVec2(80, 20)) then
									fun_gm_window_state.v = true
								end
								
								imgui.Text(u8"Ферма: /per1(бусаево) /per2(батырево) /vspah(трактор) ")
								imgui.Text(u8"/grab_metka(ворует метку)")
								imgui.Text(u8"Если метки далеко, то будет видно со стороны как оттепает")
							-- Починка авто
								imgui.SameLine()
								imgui.SetCursorPosX(312)
								imgui.SetCursorPosY(15)
								if imgui.Button(u8"Починить машину", imgui.ImVec2(120, 50)) then
									if isCharInAnyCar(playerPed) then
										setCarHealth(storeCarCharIsInNoSave(playerPed), 1000.0)
										sampAddChatMessage(yellow_color_text .. 'Починить машину: {0dffdb}Теперь хп машины - 1000', main_color)
									else
										sampAddChatMessage(yellow_color_text .. 'Починить машину: {0dffdb}Боже, сядь в машину...', main_color)
									end
								end
								
							
							imgui.EndChild()
						end
						
						if main_menu_settings then -- Настройки
							createChild("1", 470, 350, 140, 65, mainColorChild)
							imgui.SetCursorPosX(25)
							imgui.SetCursorPosY(15)
								if imgui.Checkbox(u8'Активация меню на INSERT', settings_ActivationInsert) then 
									config.Settings.ActivationInsert = settings_ActivationInsert.v
									inicfg.save(config)
								end
								
							imgui.SetCursorPosX(25)	
								if imgui.Checkbox(u8'Авто Y', settings_AutoY) then 
									config.Settings.AutoY = settings_AutoY.v
									inicfg.save(config)
								end
							
							imgui.EndChild()
						end

					imgui.EndChild()
				imgui.EndChild()
			imgui.EndChild()
		imgui.EndChild()
        imgui.End()
    end
	-- Окно для гм
	if fun_gm_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(350, 250), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - GM', fun_gm_window_state, imgui.WindowFlags.NoResize)
		if imgui.Checkbox(u8'Включить ГМ', fun_gm) then
			if fun_gm.v then
				function sampev.onSendSpawn()
					return false
				end
				function sampev.onSendDeathNotification(reason, killerId)
					return false
				end
				function sampev.onSetPlayerHealth(health)
					return false
				end
			else
				function sampev.onSendSpawn()
					return true
				end
				function sampev.onSendDeathNotification(reason, killerId)
					return true
				end
				function sampev.onSetPlayerHealth(health)
					return true
				end
			end
        end

		if imgui.Checkbox(u8"Заспавниться в больке", fun_gm1) then
			if fun_gm1.v == true then
				function sampev.onSendSpawn()
					return false
				end
			else
				function sampev.onSendSpawn()
					return true
				end
			end
		end
		if imgui.Button(u8"Умереть", imgui.ImVec2(70, 30)) then
			setCharHealth(PLAYER_PED, 0)
		end
        imgui.End()
	end
	-- Окно для рыбалки
	if fishing_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(500, 350), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - Fishing', fishing_window_state, imgui.WindowFlags.NoResize)

		--Помощник для рыбалки
		imgui.SetCursorPosX(155)
		imgui.PushFont(menu_HeadFuncText_size)
		imgui.Text(u8'Помощник для рыбалки')
		imgui.PopFont()
		imgui.SetCursorPosY(50)
		imgui.Text(u8'Сколько износа?:')
		imgui.SameLine()
		imgui.PushItemWidth(40)
		if imgui.InputText(u8'', fishing_helper_buffer) then end
		imgui.SameLine()
		imgui.PushItemWidth(130)
		imgui.SetCursorPosX(165)
		imgui.Combo(" ", fishing_combo, fishing_array, #fishing_array)
		imgui.SameLine()
		if imgui.Checkbox(u8 'Вкл', fishing_helper) then
			if fishing_helper.v then
				if (tonumber(fishing_helper_buffer.v) == nil) then
					sampAddChatMessage(yellow_color_text .. 'Помощник для рыбалки: {0dffdb}Эээээ, введи норм число! :P', main_color)
				elseif (tonumber(fishing_helper_buffer.v) >= 0) and (tonumber(fishing_helper_buffer.v) <= 100) then
					fish_value = tonumber(fishing_helper_buffer.v)
					sampAddChatMessage(yellow_color_text .. 'Помощник для рыбалки: Запомнил, у вас - {0dffdb}' .. tostring(fish_value) .. yellow_color_text .. ' :P', main_color)
				else
					sampAddChatMessage(yellow_color_text .. 'Помощник для рыбалки: {0dffdb}Эээээ, введи норм число! :P', main_color)
				end
			end
			if not fishing_helper.v then end
		end
		--Бот рыбалка
		if imgui.Checkbox(u8 'Бот рыбалка', fishing_bot) then
			if fishing_bot.v then
				sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Начинаю работать :P', main_color)
				fishing_spamAlt_thread:run()
			end
			if not fishing_bot.v then
				sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', main_color)
			end
		end
		if imgui.Checkbox(u8'Активация Бот рыбалка на B', fishing_bot_key) then end
		if imgui.Checkbox(u8'Выключить Тунца', fishing_bot_tunecOff) then end

		imgui.End()
	end
	-- Окно для охоты
	if ohota_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(500, 350), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - Ohota', ohota_window_state, imgui.WindowFlags.NoResize)
		--Вх на оленей и медведей
		if imgui.Checkbox(u8'Вх на оленей и медведей', legit_whohota) then end
		imgui.Text("")
		if imgui.Checkbox(u8'Вх на уток', legit_whDuck) then end
		imgui.SameLine()
		if imgui.Checkbox(u8'Трейсер на уток', legit_whDuck_traser) then end
		if imgui.Checkbox(u8'Автоподбор уток', legit_AutoTakeDuck) then end
		if imgui.Checkbox(u8'Аим на уток', legit_aimDuck) then end
		imgui.SameLine()
		if imgui.Checkbox(u8'Сайлент аим на уток', legit_aimDuck_silent) then end

		imgui.End()
	end
	--Окно Авто-логин
	if autologin_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(200, 150), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - AutoLogin', autologin_window_state, imgui.WindowFlags.NoResize)
		--Авто-Логин
		if imgui.Checkbox(u8'Авто-Логин', AutoLoginStatus) then 
			config.AutoLogin.AutoLoginStatus = AutoLoginStatus.v
			inicfg.save(config)
		end
		imgui.PushItemWidth(150)
		if imgui.InputText(u8'', autologin_buffer) then
			config.AutoLogin.Password = autologin_buffer.v
			inicfg.save(config)
		end
		imgui.End()
	end
	
	-- Окно для дайвинга
	if diving_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - Diving', diving_window_state, imgui.WindowFlags.NoResize)

		if imgui.Checkbox(u8'Вх на сундуки', legit_whDiving) then end
		if imgui.Checkbox(u8'Трейсер на сундуки', legit_whDiving_traser) then end

		imgui.End()
	end
	
	-- Окно для пилота
	if pilot_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(300, 150), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - Pilot', pilot_window_state, imgui.WindowFlags.NoResize)

		if imgui.Checkbox(u8'Пилот Авто-скип таблички', legit_PilotAutoSkipTable) then end

		imgui.End()
	end
	
	if halloween_window_state.v then
		menus_style()
		-- Настройки окна
		imgui.SetNextWindowSize(imgui.ImVec2(450, 250), imgui.Cond.FirstUseEver)
		imgui.SetNextWindowPos(imgui.ImVec2(sw / 2, sh / 2), imgui.Cond.FirstUseEver, imgui.ImVec2(0.5, 0.5))

		-- Вывод окна
		imgui.Begin('SlivsMenu for RadmirRP - Halloween', halloween_window_state, imgui.WindowFlags.NoResize)

		if imgui.Checkbox(u8'Выдать листовку ПКМ+B (R,J перестанет работать)', legit_halloween_sendListovka) then end

		imgui.End()
	end
	
end
-- Функция для переключения менюшки(вырубаем все менюшки чтобы включить нужную)
function main_menu_exitAll()
	main_menu_legit = false
	main_menu_rage = false
	main_menu_settings = false
end

-- Стиль окна
function apply_custom_style()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4

	--style.WindowPadding = imgui.ImVec2(5.0, 5.0)
    style.WindowRounding = 20.0
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
    colors[clr.TitleBg]                = ImVec4(0.04, 0.04, 0.04, 1.00)
    colors[clr.TitleBgActive]          = ImVec4(0.16, 0.29, 0.48, 1.00)
    colors[clr.TitleBgCollapsed]       = ImVec4(0.00, 0.00, 0.00, 0.51)
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

function RGBA(r, g, b, a)
	r = r / 255
	g = g / 255
	b = b / 255
	return r, g, b, a
end

-- Размер шрифта
function imgui.BeforeDrawFrame()
	if headsize == nil then
		headsize = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 40.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
	if menu_buttonText_size == nil then
		menu_buttonText_size = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 20.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
	if menu_HeadFuncText_size == nil then
		menu_HeadFuncText_size = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 16.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
	if menu_buttonCheatText_size == nil then
		menu_buttonCheatText_size = imgui.GetIO().Fonts:AddFontFromFileTTF(getFolderPath(0x14) .. '\\trebucbd.ttf', 18.0, nil, imgui.GetIO().Fonts:GetGlyphRangesCyrillic())
	end
end

--Менюшка
function createChild(windowName, x, y, posX, posY, color)
	local style = imgui.GetStyle()
	local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
	imgui.SetCursorPosX(posX)
	imgui.SetCursorPosY(posY)
	style.ChildWindowRounding = 20.0
	--colors[clr.ChildWindowBg] = ImVec4(RGBA(255, 143, 0, 0.8))
	colors[clr.ChildWindowBg] = color
	imgui.BeginChild(windowName, imgui.ImVec2(x, y), true)
end

--Авто сбор утки
function legit_autoTakeDuck_thread_function()
	sampSendChat("/take_duck")
	wait(1000)
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
			print('Packet: '.._style..'/'.._type..'/'..l..'/'..style3..'/'..length..'/'..bitstreamtext)
			if fishing_bot.v then
				--print('bot: '.._style..'/'.._type..'/'..l..'/'..style3..'/'..length..'/'..bitstreamtext)
				if (_style == 727) and (_type == 512) and (l == 0) and (style3 == 1) and (length == 64) then
					local fish_percent = tonumber(string.sub(bitstreamtext, #bitstreamtext-5, #bitstreamtext-3))
					if fish_percent >= 60 then
						lua_thread.create( -- создаем поток нажатия клавиши
							function()
								setVirtualKeyDown(VK_SPACE, true)
								wait(100)
								setVirtualKeyDown(VK_SPACE, false)
							end)
					end
				end
				if string.find(bitstreamtext, 'Вы хотите забрать или отпустить рыбу?', 1, true) then
					--727/512/0/1/195/window.addDialogInQueue('[0,6,"Улов","","Забрать","Отпустить",0,0]', ["Вы поймали Красноперка весом 0.2 кг.<n><n>Вы хотите забрать или отпустить рыбу?", "fishing/fish/-1.png"], 0)
					if fishing_bot_tunecOff.v and string.find(bitstreamtext, 'Тунец', 1, true) then
						lua_thread.create(
							function()
								wait(500)
								setVirtualKeyDown(VK_ESCAPE, true)
								wait(100)
								setVirtualKeyDown(VK_ESCAPE, false)
								wait(3500)
								fishing_spamAlt_thread:run()
						end)
					else
						lua_thread.create(
							function()
								wait(500)
								setVirtualKeyDown(VK_RETURN, true)
								wait(100)
								setVirtualKeyDown(VK_RETURN, false)
								wait(100)
								setVirtualKeyDown(VK_RETURN, true)
								wait(100)
								setVirtualKeyDown(VK_RETURN, false)
								wait(3500)
								fishing_spamAlt_thread:run()
						end)
					end
				end
				if string.find(bitstreamtext, 'fishing/sfx_fishing_swish.ogg', 1, true) and (not fishing_spamAlt_thread.dead) then
					fishing_spamAlt_thread_stop = true
				end
			end
			
			-- 727/1024/0/2/13/Authorization
			if (length == 13) and (bitstreamtext == "Authorization") and AutoLoginStatus.v then
				local Password = tostring(config.AutoLogin.Password)
				local bs = raknetNewBitStream()
				raknetBitStreamWriteInt8(bs, 215) --215
				raknetBitStreamWriteInt8(bs, 2) --2
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
			end
			
			if legit_halloween_sendListovka.v then
				if (bitstreamtext == "PlayerInteraction") or (string.find(bitstreamtext, "interface('PlayerInteraction').onServerResponse", 1, true)) then
					return false
				end
			end
			
			-- 727/512/0/1/120/window.addDialogInQueue('[0,0,"Auaa?eoa aaenoaea","","Aa","Iao",0,0]', "Au oioeoa caeii?eou ?aaioo?", 0)
			if legit_PilotAutoSkipTable.v then
				if string.find(bitstreamtext, "window.addDialogInQueue('[0,0,", 1, true) then
					local bs = raknetNewBitStream()
					local MyPacket = {215, 2, 0, 0, 0, 0, 0, 16, 0, 0, 0, 79, 110, 68, 105, 97, 108, 111, 103, 82, 101, 115, 112, 111, 110, 115, 101, 8, 0, 0, 0, 100, 0, 0, 0, 0, 100, 0, 0, 0, 0, 100, 255, 255, 255, 255, 115, 0, 0, 0, 0}
					for i=1, #MyPacket do
						raknetBitStreamWriteInt8(bs, MyPacket[i])
					end
					raknetSendBitStream(bs) -- отправляем пакет
					raknetDeleteBitStream(bs) -- удаляем пакет
					return false
				end
			end
			-- interface('ProgressBar').getBarInfo("[["Нажимайте Y <br>с небольшим интервалом",0,1000]]")
			if settings_AutoY.v then
				if string.find(bitstreamtext, "interface('ProgressBar').getBarInfo(\"[[\"Нажимайте Y <br>с небольшим интервалом\",0,1000]]\")", 1, true) or ((bitstreamtext == "ProgressBar") and (getCharModel(PLAYER_PED) == 15576)) then
					settings_AutoY_clicker = true
					
					lua_thread.create(function()
						setVirtualKeyDown(VK_Y, true)
						wait(50)
						setVirtualKeyDown(VK_Y, false)
					end)
				end
				
				if string.find(bitstreamtext, "interface('ProgressBar').setFill(0, ", 1, true) and settings_AutoY_clicker then
					local setFill = tonumber(string.sub(bitstreamtext, 37, -2))
					if (setFill == 100) then
						settings_AutoY_clicker = false
					else
						lua_thread.create(function()
							wait(600)
							setVirtualKeyDown(VK_Y, true)
							wait(50)
							setVirtualKeyDown(VK_Y, false)
						end)
					end
				end
				
			end
		end
	end
end
--function onSendPacket(id, bitStream, priority, reliability, orderingChannel)
--    if fun_TpOnCoord_TPshim and not isCharInAnyCar(PLAYER_PED) then id = 159 return false end
--end

function sampev.onSendPlayerSync(data)
	if fun_TpOnCoord_TPshim and not isCharInAnyCar(PLAYER_PED) then
		return false
	end
end

-- Получение сообщений от сервера
function sampev.onServerMessage(color, text)
	-- Помощник для рыбалки
	if fishing_helper.v then
		if (fishing_combo.v == 0) then
			if string.find(text, 'Вы словили рыбу', 1, true) then
				fish_value = fish_value + 0.5
			end
			if string.find(text, 'Рыба сорвалась с крючка.', 1, true) then
				fish_value = fish_value + 1
			end
			if string.find(text, 'Угорь ударил вас током и уплыл.', 1, true) then
				fish_value = fish_value + 0.5
			end
		elseif (fishing_combo.v == 1) then
			if string.find(text, 'Вы словили рыбу', 1, true) then
				fish_value = fish_value + 2
			end
			if string.find(text, 'Рыба сорвалась с крючка.', 1, true) then
				fish_value = fish_value + 3
			end
		elseif (fishing_combo.v == 2) then
			if string.find(text, 'Вы словили рыбу', 1, true) then
				fish_value = fish_value + 1
			end
			if string.find(text, 'Рыба сорвалась с крючка.', 1, true) then
				fish_value = fish_value + 2
			end
		end
	end

	-- Бот для рыбалки
	if fishing_bot.v then
		if string.find(text, 'Подсечка не удалась, рыба съела наживку и уплыла.', 1, true) then
			lua_thread.create(
				function()
						wait(4000)
						fishing_spamAlt_thread:run()
				end)
		end
		if string.find(text, 'У вас недостаточно свободного веса в инвентаре чтобы забрать рыбу.', 1, true) or string.find(text, 'У вас недостаточно места в инвентаре чтобы забрать рыбу.', 1, true) then
			fishing_bot.v = false
			sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', main_color)
			if not fishing_spamAlt_thread.dead then
				fishing_spamAlt_thread_stop = true
			end
		end
		if string.find(text, 'У вас закончилась наживка', 1, true) then
			fishing_bot.v = false
			sampAddChatMessage(yellow_color_text .. 'Бот рыбалка: {0dffdb}Хватит на сегодня рыбы', main_color)
			if not fishing_spamAlt_thread.dead then
				fishing_spamAlt_thread_stop = true
			end
		end
	end

end

--Спам ALT для рыбалки
function fishing_spamAlt_thread_function()
	--sampAddChatMessage("Ну я тут", -1)
	while (not fishing_spamAlt_thread_stop) do
		if not fishing_bot.v then break end
		setVirtualKeyDown(VK_MENU, true)
		wait(100)
		setVirtualKeyDown(VK_MENU, false)
		wait(500)
	end
	--sampAddChatMessage("Проспамили", -1)
	fishing_spamAlt_thread_stop = false
end

--Отправка пули на сервер
function sampev.onSendBulletSync(data)
	if legit_aimDuck_silent.v then
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
					if legit_aimDuck.v then
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

--Эвенты
function sampev.onRemovePlayerFromVehicle()
	if rage_ygonAvto.v then
		return false
	end
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
	if legit_aimDuck.v then
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

function ferma1TpPerenos_thread_function()
	while ferma1TpPerenos do
		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		moveTudaObratno(-1074.3, -1026.2, 47) -- тп на мельницу
		while fun_TpOnCoord_TPshim do
			wait(100)
		end
		
		wait(math.random(5000, 7500))
		
		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		moveTudaObratno(-1121.1, -828, 51) -- тп на сдачу
		while fun_TpOnCoord_TPshim do
			wait(100)
		end
		
		wait(math.random(4000, 5000))
	end
	sampAddChatMessage("Доделали", -1)
end

function ferma2TpPerenos_thread_function()
	while ferma2TpPerenos do
		
		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		moveTudaObratno(1556.2, 651.4, 15) -- тп на мельницу
		while fun_TpOnCoord_TPshim do
			wait(100)
		end
		
		wait(math.random(3600, 5000))
		
		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		moveTudaObratno(1657.7, 692.3, 15.5) -- тп на сдачу
		while fun_TpOnCoord_TPshim do
			wait(100)
		end
		
		wait(math.random(3600, 5000))
	end
	sampAddChatMessage("Доделали", -1)
end

function fermaTpVspah_thread_function()
	while fermaTpVspah do
	
		fun_TpOnCoord_syncPacketCount=0
		fun_TpOnCoord_TPshim = true
		moveTudaObratno(fermaCheckpointPosX, fermaCheckpointPosY, fermaCheckpointPosZ) -- тп на метку
		while fun_TpOnCoord_TPshim do
			wait(100)
		end
		
		wait(5000)
	end
	sampAddChatMessage("Доделали", -1)
end

function sampev.onSetCheckpoint(position, radius)
	if (radius == 1) or (radius == 2.5) then
		fermaCheckpointPosX = position.x
		fermaCheckpointPosY = position.y
		fermaCheckpointPosZ = position.z
		--sampAddChatMessage(string.format("X:%0.3f |Y:%0.3f |Z:%0.3f", fermaCheckpointPosX, fermaCheckpointPosY, fermaCheckpointPosZ), -1)
	end
end

--Телепорт атп/мтп
function moveToBlip(blipX, blipY, blipZ)
	local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
	local isCar = isCharInAnyCar(PLAYER_PED)
	local PosDelay
	if isCar then
		PosDelay = 5 --делей если в машине
	else
		PosDelay = 1.45 --делей если пешком
	end
	lua_thread.create(function()
		while fun_TpOnCoord_TPshim do
			local success, err = pcall(function()
				local moveX, moveY, moveZ = calculateNextStep(playerX, playerY, playerZ, blipX, blipY, blipZ, PosDelay)
				playerX, playerY, playerZ = playerX + moveX, playerY + moveY, playerZ + moveZ
				
				syncMovement(playerX, playerY, playerZ, isCar)
				fun_TpOnCoord_syncPacketCount=fun_TpOnCoord_syncPacketCount + 1
				
				if calculateDistance(playerX, playerY, blipX, blipY) < PosDelay then
					local whatTime=os.clock()-fun_TpOnCoord_tpTime
					setCharCoordinates(PLAYER_PED, blipX, blipY, blipZ)
					wait(100)
					fun_TpOnCoord_TPshim=false
					sampAddChatMessage("{c300ff}ATP/MTP by L.team: {ffffff}Тепнули вас сер за " .. string.format("%0.2f", whatTime) .. " секунд", -1);
					
				end

				if fun_TpOnCoord_syncPacketCount >= 450 then --OnPacket = 480
					fun_TpOnCoord_syncPacketCount=0
					--sampAddChatMessage("Ждём " .. fun_TpOnCoord_tpWait .. "мс", -1)
					if isCar then
						wait(fun_TpOnCoord_tpWait)
					else
						wait(1600)
					end
				end
			end)

			if not success then
				fun_TpOnCoord_TPshim=false
			end
		end
	end)
end
function moveTudaObratno(blipX, blipY, blipZ)
	local playerX, playerY, playerZ = getCharCoordinates(PLAYER_PED)
	local myPosX, myPosY, myPosZ = getCharCoordinates(PLAYER_PED)
	local isCar = isCharInAnyCar(PLAYER_PED)
	local tuda = true
	local PosDelay
	if isCar then
		PosDelay = 5 --делей если в машине
	else
		PosDelay = 1 --делей если пешком
	end
	lua_thread.create(function()
		while fun_TpOnCoord_TPshim do
			local success, err = pcall(function()
				if tuda then
					local moveX, moveY, moveZ = calculateNextStep(playerX, playerY, playerZ, blipX, blipY, blipZ, PosDelay)
					playerX, playerY, playerZ = playerX + moveX, playerY + moveY, playerZ + moveZ
					syncMovement(playerX, playerY, playerZ, isCar)
					fun_TpOnCoord_syncPacketCount=fun_TpOnCoord_syncPacketCount + 1
				else
					local moveX, moveY, moveZ = calculateNextStep(playerX, playerY, playerZ, myPosX, myPosY, myPosZ, PosDelay)
					playerX, playerY, playerZ = playerX + moveX, playerY + moveY, playerZ + moveZ
					syncMovement(playerX, playerY, playerZ, isCar)
					fun_TpOnCoord_syncPacketCount=fun_TpOnCoord_syncPacketCount + 1
				end
				
				if calculateDistance(playerX, playerY, blipX, blipY) < PosDelay and tuda then
					syncMovement(blipX, blipY, blipZ, isCar)
					fun_TpOnCoord_syncPacketCount=fun_TpOnCoord_syncPacketCount + 1
					tuda = false
				end
				
				if calculateDistance(playerX, playerY, myPosX, myPosY) < PosDelay and not tuda then
					--sampAddChatMessage(myPosX .. "|" .. myPosY .. "|" .. myPosZ, -1)
					if isCar then
						setCarCoordinates(getCarModel(storeCarCharIsInNoSave(PLAYER_PED)), myPosX, myPosY, myPosZ)
					else
						local data = samp_create_sync_data("player")
						data.health = getCharHealth(PLAYER_PED)
						data.specialAction = 0
						data.animationId = 1189 -- просто стоим на месте
						data.send()
						setCharCoordinates(PLAYER_PED, myPosX, myPosY, myPosZ-1)
					end
					wait(100)
					fun_TpOnCoord_TPshim=false
				end
				
				if fun_TpOnCoord_syncPacketCount >= 450 then --OnPacket = 480
					fun_TpOnCoord_syncPacketCount=0
					--sampAddChatMessage("Ждём " .. fun_TpOnCoord_tpWait .. "мс", -1)
					if isCar then
						wait(fun_TpOnCoord_tpWait)
					else
						wait(1000)
					end
				end
				
			end)

			if not success then
				fun_TpOnCoord_TPshim=false
			end
		end
	end)
end
function calculateNextStep(x, y, z, targetX, targetY, targetZ, speed)
    local deltaX, deltaY, deltaZ = targetX - x, targetY - y, targetZ - z
    local dist = math.sqrt(deltaX^2 + deltaY^2 + deltaZ^2)
    if dist == 0 then return 0, 0, 0 end
    local scale = speed / dist
    return deltaX * scale, deltaY * scale, deltaZ * scale
end
function syncMovement(x, y, z, isCar)
	local randomizes = tonumber("0.0000" .. math.random(9))
	--setCharCoordinates(PLAYER_PED, x+randomizes, y+randomizes,z+randomizes)
	if isCar then
		local data = samp_create_sync_data("vehicle")
		data.position={x+randomizes, y+randomizes,z+randomizes}
		--data.playerHealth = getCharHealth(PLAYER_PED)
		data.send()
	else
		local data = samp_create_sync_data("player")
		data.position={x+randomizes, y+randomizes,z+randomizes}
		data.health = 1/0
		data.keysData = 0
		data.specialAction = 4
		data.animationId = 1018
		data.animationFlags = 12211
		data.send()
	end
end
function calculateDistance(x,y,tpX,tpY)
	return math.sqrt(((tpX-x)^2) + ((tpY-y)^2))
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