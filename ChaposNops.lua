---------------------------------------------------------------
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
--| donate 100 RUB to get source code: https://qiwi.com/n/AMID24 |--
---------------------------------------------------------------


local imgui = require('imgui')
local encoding = require 'encoding'
encoding.default = 'CP1251'
u8 = encoding.UTF8

local inicfg = require 'inicfg'
local directIni = 'ChaposNOPS.ini'
local ini = inicfg.load(inicfg.load({
    main = {
        fanat_chapo = false,
    },
}, directIni))
inicfg.save(ini, directIni)

local fanat_chapo = ini.main.fanat_chapo

local window = imgui.ImBool(false)
local search = imgui.ImBuffer(256)
local navigation = {
    current = 1,
    list = {'RPC IN', 'RPC OUT', 'Packet IN', 'Packet OUT'}
}

local enabled = imgui.ImBool(false)

local list_file = getWorkingDirectory()..'\\config\\ChapoNOPS_ARBEB.json'
local list = {}
local rpcs = {}

function jsonSave(t)
    local jsonFilePath = list_file
    file = io.open(jsonFilePath, "w")
    file:write(encodeJson(t))
    file:flush()
    file:close()
end

function jsonRead()
    local jsonFilePath = list_file
    local file = io.open(jsonFilePath, "r+")
    local jsonInString = file:read("*a")
    file:close()
    local jsonTable = decodeJson(jsonInString)
    return jsonTable
end

function main()
    while not isSampAvailable() do wait(200) end
    if not doesDirectoryExist(getWorkingDirectory()..'\\config') then createDirectory(getWorkingDirectory()..'\\config') end
    if not doesFileExist(list_file) then
        local t = {
            --[[rpc in]]        {['113'] = false,['59'] = false,['37'] = false,['38'] = false,['39'] = false,['107'] = false,['61'] = false,['108'] = false,['120'] = false,['121'] = false,['85'] = false,['73'] = false,['56'] = false,['144'] = false,['26'] = false,['154'] = false,['57'] = false,['65'] = false,['70'] = false,['71'] = false,['106'] = false,['123'] = false,['147'] = false,['159'] = false,['160'] = false,['161'] = false,['164'] = false,['165'] = false,['58'] = false,['94'] = false,['170'] = false,['134'] = false,['83'] = false,['105'] = false,['104'] = false,['126'] = false,['127'] = false,['68'] = false,['128'] = false,['19'] = false,['137'] = false,['138'] = false,['155'] = false,['86'] = false,['87'] = false,['166'] = false,['11'] = false,['12'] = false,['13'] = false,['34'] = false,['153'] = false,['29'] = false,['88'] = false,['152'] = false,['17'] = false,['90'] = false,['15'] = false,['124'] = false,['30'] = false,['69'] = false,['16'] = false,['18'] = false,['20'] = false,['21'] = false,['22'] = false,['41'] = false,['42'] = false,['43'] = false,['14'] = false,['66'] = false,['145'] = false,['162'] = false,['67'] = false,['32'] = false,['163'] = false,['79'] = false,['55'] = false,['93'] = false,['35'] = false,['89'] = false,['156'] = false,['72'] = false,['74'] = false,['111'] = false,['133'] = false,['157'] = false,['158'] = false},
            --[[rpc out]]       {['106'] = false,['26'] = false,['154'] = false,['52'] = false,['101'] = false,['118'] = false,['53'] = false,['50'] = false,['62'] = false,['103'] = false,['115'] = false,['119'] = false,['128'] = false,['129'] = false,['132'] = false,['140'] = false,['131'] = false,['116'] = false,['117'] = false,['155'] = false,['25'] = false,['54'] = false,['168'] = false},
            --[[packet in]]     {['31'] = false,['32'] = false,['33'] = false,['34'] = false,['35'] = false,['36'] = false,['37'] = false},
            --[[packet out]]    {['11'] = false,['12'] = false,['38'] = false,['200'] = false,['201'] = false,['203'] = false,['204'] = false,['205'] = false,['206'] = false,['207'] = false,['209'] = false,['210'] = false,['211'] = false,['212'] = false},
        }
        jsonSave(t)
    end
    list = jsonRead()
    load()
    window.v = false
    imgui.Process = window.v
    sampRegisterChatCommand('nop', function()
        window.v = not window.v
    end)
    while true do
        wait(0)
        imgui.Process = window.v
        if testCheat('chapoyafan') then
            fanat_chapo = not fanat_chapo
            local fancol = fanat_chapo and '{ff004d}' or '{698cc7}' 
            sampAddChatMessage(fancol..'[Chapo\'s NOPS]:{ffffff} theme switched to '..fancol..(fanat_chapo and 'SECRET' or 'default'), -1)
            ini.main.fanat_chapo = fanat_chapo
            inicfg.save(ini, directIni)
            BH_theme()
        end
    end
end

function imgui.OnDrawFrame()
    if window.v then
        local resX, resY = getScreenResolution()
        local sizeX, sizeY = 400, 400
        imgui.SetNextWindowPos(imgui.ImVec2(resX / 2 - sizeX / 2, resY / 2 - sizeY / 2), imgui.Cond.FirstUseEver)
        imgui.SetNextWindowSize(imgui.ImVec2(sizeX, sizeY), imgui.Cond.FirstUseEver)
        imgui.Begin('Chapo\'s NOPS'..(fanat_chapo and ' (FAN MODE)' or ''), window, imgui.WindowFlags.NoCollapse)
        imgui.SetWindowFontScale(1)
        local s = imgui.GetWindowSize()
        sizeX, sizeY = s.x, s.y
        for i, title in ipairs(navigation.list) do
            if HeaderButton(navigation.current == i, title) then
                navigation.current = i
            end
            if i ~= #navigation.list then
                imgui.SameLine(nil, 30)
            end
        end
        page = navigation.current
        imgui.SameLine(sizeX - 75)
        if imgui.Button('OFF ALL', imgui.ImVec2(70, 20)) then 
            for i = 1, 4 do
                for k, v in pairs(rpcs[i]) do
                    v.nop.v = false
                end
            end
        end
        --if imgui.IsItemHovered() then
        --    imgui.BeginTooltip()
        --        imgui.Text(u8'Restore Restore previous settings\n-------------------------------------\nВосстановить нопы, выбранные в прошлый раз')
        --    imgui.EndTooltip()
        --end

        imgui.SetCursorPos(imgui.ImVec2(5, 45))
        imgui.BeginChild('sear', imgui.ImVec2(sizeX - 10, 25), true)
            imgui.Checkbox('Enabled', enabled)
            local searchSize = sizeX - 200
            imgui.SameLine(sizeX - searchSize - 5 - 5 - 50)
            imgui.Text('Search:')
            imgui.SameLine(sizeX - searchSize - 5)
            imgui.PushItemWidth(searchSize)
            imgui.InputText('##srch', search)
            imgui.PopItemWidth()
            imgui.SameLine()
            
        imgui.EndChild()

        imgui.SetCursorPos(imgui.ImVec2(5, 75))
        imgui.BeginChild('list', imgui.ImVec2(sizeX - 10, sizeY - 80), true)
        imgui.SetWindowFontScale(1.1)
        for i = 1, #rpcs[page] do
            if page == 1 or page == 2 then
                rpcname = raknetGetRpcName(rpcs[page][i].id)
            else
                rpcname = raknetGetPacketName(rpcs[page][i].id)
            end
            if rpcname == nil then rpcname = 'UNKNOWN' end
            local text = ' ['..rpcs[page][i].id..'] '..rpcname

            if #search.v > 0 then 
                if text:lower():find(search.v:lower(), nil, true) then
                    if imgui.Checkbox(text, rpcs[page][i].nop) then save() end
                end
            else
                if imgui.Checkbox(text, rpcs[page][i].nop) then save() end
            end
        end
        imgui.EndChild()

        imgui.End()
    end
end

function check(index, id)
    if enabled.v then
        if #rpcs > 0 then
            local t = rpcs[index]
            for i = 1, #t do
                if t[i].id == id then
                    return not t[i].nop.v
                end
            end
        end
    end
end

function onReceiveRpc(id, bs)
    return check(1, id)
end

function onSendRpc(id, bs)
    return check(2, id)
end

function onReceivePacket(id, bs)
    return check(3, id)
end

function onSendPacket(id, bs)
    return check(4, id)
end

function save()
    local page = navigation.current
    for page = 1, #list do
        for k, v in pairs(list[page]) do
            for i = 1, table.getn(rpcs[page]) do
                if k == tostring(rpcs[page][i].id) then
                    --print('list = ', v, 'rpcs = ', rpcs[page][i].nop.v)
                    list[page][k] = rpcs[page][i].nop.v
                end
            end
        end
    end
    jsonSave(list)
end

function load()
    rpcs = {
        -- rpc in
        {{id = 113, nop = imgui.ImBool(list[1]['113'])},{id = 59, nop = imgui.ImBool(list[1]['59'])},{id = 37, nop = imgui.ImBool(list[1]['37'])},{id = 38, nop = imgui.ImBool(list[1]['38'])},{id = 39, nop = imgui.ImBool(list[1]['39'])},{id = 107, nop = imgui.ImBool(list[1]['107'])},{id = 61, nop = imgui.ImBool(list[1]['61'])},{id = 108, nop = imgui.ImBool(list[1]['108'])},{id = 120, nop = imgui.ImBool(list[1]['120'])},{id = 121, nop = imgui.ImBool(list[1]['121'])},{id = 85, nop = imgui.ImBool(list[1]['85'])},{id = 73, nop = imgui.ImBool(list[1]['73'])},{id = 56, nop = imgui.ImBool(list[1]['56'])},{id = 144, nop = imgui.ImBool(list[1]['144'])},{id = 26, nop = imgui.ImBool(list[1]['26'])},{id = 154, nop = imgui.ImBool(list[1]['154'])},{id = 57, nop = imgui.ImBool(list[1]['57'])},{id = 65, nop = imgui.ImBool(list[1]['65'])},{id = 70, nop = imgui.ImBool(list[1]['70'])},{id = 71, nop = imgui.ImBool(list[1]['71'])},{id = 106, nop = imgui.ImBool(list[1]['106'])},{id = 123, nop = imgui.ImBool(list[1]['123'])},{id = 147, nop = imgui.ImBool(list[1]['147'])},{id = 159, nop = imgui.ImBool(list[1]['159'])},{id = 160, nop = imgui.ImBool(list[1]['160'])},{id = 161, nop = imgui.ImBool(list[1]['161'])},{id = 164, nop = imgui.ImBool(list[1]['164'])},{id = 165, nop = imgui.ImBool(list[1]['165'])},{id = 58, nop = imgui.ImBool(list[1]['58'])},{id = 94, nop = imgui.ImBool(list[1]['94'])},{id = 170, nop = imgui.ImBool(list[1]['170'])},{id = 134, nop = imgui.ImBool(list[1]['134'])},{id = 83, nop = imgui.ImBool(list[1]['83'])},{id = 105, nop = imgui.ImBool(list[1]['105'])},{id = 104, nop = imgui.ImBool(list[1]['104'])},{id = 126, nop = imgui.ImBool(list[1]['126'])},{id = 127, nop = imgui.ImBool(list[1]['127'])},{id = 68, nop = imgui.ImBool(list[1]['68'])},{id = 128, nop = imgui.ImBool(list[1]['128'])},{id = 19, nop = imgui.ImBool(list[1]['19'])},{id = 137, nop = imgui.ImBool(list[1]['137'])},{id = 138, nop = imgui.ImBool(list[1]['138'])},{id = 155, nop = imgui.ImBool(list[1]['155'])},{id = 86, nop = imgui.ImBool(list[1]['86'])},{id = 87, nop = imgui.ImBool(list[1]['87'])},{id = 166, nop = imgui.ImBool(list[1]['166'])},{id = 11, nop = imgui.ImBool(list[1]['11'])},{id = 12, nop = imgui.ImBool(list[1]['12'])},{id = 13, nop = imgui.ImBool(list[1]['13'])},{id = 34, nop = imgui.ImBool(list[1]['34'])},{id = 153, nop = imgui.ImBool(list[1]['153'])},{id = 29, nop = imgui.ImBool(list[1]['29'])},{id = 88, nop = imgui.ImBool(list[1]['88'])},{id = 152, nop = imgui.ImBool(list[1]['152'])},{id = 17, nop = imgui.ImBool(list[1]['17'])},{id = 90, nop = imgui.ImBool(list[1]['90'])},{id = 15, nop = imgui.ImBool(list[1]['15'])},{id = 124, nop = imgui.ImBool(list[1]['124'])},{id = 30, nop = imgui.ImBool(list[1]['30'])},{id = 69, nop = imgui.ImBool(list[1]['69'])},{id = 16, nop = imgui.ImBool(list[1]['16'])},{id = 18, nop = imgui.ImBool(list[1]['18'])},{id = 20, nop = imgui.ImBool(list[1]['20'])},{id = 21, nop = imgui.ImBool(list[1]['21'])},{id = 22, nop = imgui.ImBool(list[1]['22'])},{id = 41, nop = imgui.ImBool(list[1]['41'])},{id = 42, nop = imgui.ImBool(list[1]['42'])},{id = 43, nop = imgui.ImBool(list[1]['43'])},{id = 14, nop = imgui.ImBool(list[1]['14'])},{id = 66, nop = imgui.ImBool(list[1]['66'])},{id = 145, nop = imgui.ImBool(list[1]['145'])},{id = 162, nop = imgui.ImBool(list[1]['162'])},{id = 67, nop = imgui.ImBool(list[1]['67'])},{id = 32, nop = imgui.ImBool(list[1]['32'])},{id = 163, nop = imgui.ImBool(list[1]['163'])},{id = 79, nop = imgui.ImBool(list[1]['79'])},{id = 55, nop = imgui.ImBool(list[1]['55'])},{id = 93, nop = imgui.ImBool(list[1]['93'])},{id = 35, nop = imgui.ImBool(list[1]['35'])},{id = 89, nop = imgui.ImBool(list[1]['89'])},{id = 156, nop = imgui.ImBool(list[1]['156'])},{id = 72, nop = imgui.ImBool(list[1]['72'])},{id = 74, nop = imgui.ImBool(list[1]['74'])},{id = 111, nop = imgui.ImBool(list[1]['111'])},{id = 133, nop = imgui.ImBool(list[1]['133'])},{id = 157, nop = imgui.ImBool(list[1]['157'])},{id = 158, nop = imgui.ImBool(list[1]['158'])},},
        -- rpc out
        {{id = 106, nop = imgui.ImBool(list[2]['106'])},{id = 26, nop = imgui.ImBool(list[2]['26'])},{id = 154, nop = imgui.ImBool(list[2]['154'])},{id = 52, nop = imgui.ImBool(list[2]['52'])},{id = 101, nop = imgui.ImBool(list[2]['101'])},{id = 118, nop = imgui.ImBool(list[2]['118'])},{id = 53, nop = imgui.ImBool(list[2]['53'])},{id = 50, nop = imgui.ImBool(list[2]['50'])},{id = 62, nop = imgui.ImBool(list[2]['62'])},{id = 103, nop = imgui.ImBool(list[2]['103'])},{id = 115, nop = imgui.ImBool(list[2]['115'])},{id = 119, nop = imgui.ImBool(list[2]['119'])},{id = 128, nop = imgui.ImBool(list[2]['128'])},{id = 129, nop = imgui.ImBool(list[2]['129'])},{id = 132, nop = imgui.ImBool(list[2]['132'])},{id = 140, nop = imgui.ImBool(list[2]['140'])},{id = 131, nop = imgui.ImBool(list[2]['131'])},{id = 116, nop = imgui.ImBool(list[2]['116'])},{id = 117, nop = imgui.ImBool(list[2]['117'])},{id = 155, nop = imgui.ImBool(list[2]['155'])},{id = 25, nop = imgui.ImBool(list[2]['25'])},{id = 54, nop = imgui.ImBool(list[2]['54'])},{id = 168, nop = imgui.ImBool(list[2]['168'])},},
        -- packet in
        {{id = 31, nop = imgui.ImBool(list[3]['31'])},{id = 32, nop = imgui.ImBool(list[3]['32'])},{id = 33, nop = imgui.ImBool(list[3]['33'])},{id = 34, nop = imgui.ImBool(list[3]['34'])},{id = 35, nop = imgui.ImBool(list[3]['35'])},{id = 36, nop = imgui.ImBool(list[3]['36'])},{id = 37, nop = imgui.ImBool(list[3]['37'])},},
        -- packet out
        {{id = 11, nop = imgui.ImBool(list[4]['11'])},{id = 12, nop = imgui.ImBool(list[4]['12'])},{id = 38, nop = imgui.ImBool(list[4]['38'])},{id = 200, nop = imgui.ImBool(list[4]['200'])},{id = 201, nop = imgui.ImBool(list[4]['201'])},{id = 203, nop = imgui.ImBool(list[4]['203'])},{id = 204, nop = imgui.ImBool(list[4]['204'])},{id = 205, nop = imgui.ImBool(list[4]['205'])},{id = 206, nop = imgui.ImBool(list[4]['206'])},{id = 207, nop = imgui.ImBool(list[4]['207'])},{id = 209, nop = imgui.ImBool(list[4]['209'])},{id = 210, nop = imgui.ImBool(list[4]['210'])},{id = 211, nop = imgui.ImBool(list[4]['211'])},{id = 212, nop = imgui.ImBool(list[4]['212'])},}
    }
end

HeaderButton = function(bool, str_id)
    local DL = imgui.GetWindowDrawList()
    local ToU32 = imgui.ColorConvertFloat4ToU32
    local result = false
    local label = string.gsub(str_id, "##.*$", "")
    local duration = { 0.5, 0.3 }
    local cols = {
        idle = imgui.GetStyle().Colors[imgui.Col.TextDisabled],
        hovr = imgui.GetStyle().Colors[imgui.Col.Text],
        slct = imgui.GetStyle().Colors[imgui.Col.ButtonActive]
    }

    if not AI_HEADERBUT then AI_HEADERBUT = {} end
     if not AI_HEADERBUT[str_id] then
        AI_HEADERBUT[str_id] = {
            color = bool and cols.slct or cols.idle,
            clock = os.clock() + duration[1],
            h = {
                state = bool,
                alpha = bool and 1.00 or 0.00,
                clock = os.clock() + duration[2],
            }
        }
    end
    local pool = AI_HEADERBUT[str_id]

    local degrade = function(before, after, start_time, duration)
        local result = before
        local timer = os.clock() - start_time
        if timer >= 0.00 then
            local offs = {
                x = after.x - before.x,
                y = after.y - before.y,
                z = after.z - before.z,
                w = after.w - before.w
            }

            result.x = result.x + ( (offs.x / duration) * timer )
            result.y = result.y + ( (offs.y / duration) * timer )
            result.z = result.z + ( (offs.z / duration) * timer )
            result.w = result.w + ( (offs.w / duration) * timer )
        end
        return result
    end

    local pushFloatTo = function(p1, p2, clock, duration)
        local result = p1
        local timer = os.clock() - clock
        if timer >= 0.00 then
            local offs = p2 - p1
            result = result + ((offs / duration) * timer)
        end
        return result
    end

    local set_alpha = function(color, alpha)
        return imgui.ImVec4(color.x, color.y, color.z, alpha or 1.00)
    end

    imgui.BeginGroup()
        local pos = imgui.GetCursorPos()
        local p = imgui.GetCursorScreenPos()
      
        imgui.TextColored(pool.color, label)
        local s = imgui.GetItemRectSize()
        local hovered = imgui.IsItemHovered()
        local clicked = imgui.IsItemClicked()
      
        if pool.h.state ~= hovered and not bool then
            pool.h.state = hovered
            pool.h.clock = os.clock()
        end
      
        if clicked then
            pool.clock = os.clock()
            result = true
        end

        if os.clock() - pool.clock <= duration[1] then
            pool.color = degrade(
                imgui.ImVec4(pool.color),
                bool and cols.slct or (hovered and cols.hovr or cols.idle),
                pool.clock,
                duration[1]
            )
        else
            pool.color = bool and cols.slct or (hovered and cols.hovr or cols.idle)
        end

        if pool.h.clock ~= nil then
            if os.clock() - pool.h.clock <= duration[2] then
                pool.h.alpha = pushFloatTo(
                    pool.h.alpha,
                    pool.h.state and 1.00 or 0.00,
                    pool.h.clock,
                    duration[2]
                )
            else
                pool.h.alpha = pool.h.state and 1.00 or 0.00
                if not pool.h.state then
                    pool.h.clock = nil
                end
            end

            local max = s.x / 2
            local Y = p.y + s.y + 3
            local mid = p.x + max

            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid + (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
            DL:AddLine(imgui.ImVec2(mid, Y), imgui.ImVec2(mid - (max * pool.h.alpha), Y), ToU32(set_alpha(pool.color, pool.h.alpha)), 3)
        end

    imgui.EndGroup()
    return result
end

function BH_theme()
    imgui.SwitchContext()
    local style = imgui.GetStyle()
    local colors = style.Colors
    local clr = imgui.Col
    local ImVec4 = imgui.ImVec4
    local ImVec2 = imgui.ImVec2
    style.WindowPadding = ImVec2(6, 4)
    style.WindowRounding = 5.0
    style.ChildWindowRounding = 5.0
    style.FramePadding = ImVec2(5, 2)
    style.FrameRounding = 5.0
    style.ItemSpacing = ImVec2(7, 5)
    style.ItemInnerSpacing = ImVec2(1, 1)
    style.TouchExtraPadding = ImVec2(0, 0)
    style.IndentSpacing = 6.0
    style.ScrollbarSize = 12.0
    style.ScrollbarRounding = 5.0
    style.GrabMinSize = 20.0
    style.GrabRounding = 2.0
    style.WindowTitleAlign = ImVec2(0.5, 0.5)
    if fanat_chapo == false then
        colors[clr.Text]                   = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.TextDisabled]           = ImVec4(0.28, 0.30, 0.35, 1.00)
        colors[clr.WindowBg]               = ImVec4(0.16, 0.18, 0.22, 1.00)
        colors[clr.ChildWindowBg]          = ImVec4(0.19, 0.22, 0.26, 1)
        colors[clr.PopupBg]                = ImVec4(0.05, 0.05, 0.10, 0.90)
        colors[clr.Border]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
        colors[clr.BorderShadow]           = ImVec4(0.00, 0.00, 0.00, 0.00)
        colors[clr.FrameBg]                = ImVec4(0.16, 0.18, 0.22, 1.00)
        colors[clr.FrameBgHovered]         = ImVec4(0.22, 0.25, 0.30, 1.00)
        colors[clr.FrameBgActive]          = ImVec4(0.22, 0.25, 0.29, 1.00)
        colors[clr.TitleBg]                = ImVec4(0.19, 0.22, 0.26, 1.00)
        colors[clr.TitleBgActive]          = ImVec4(0.19, 0.22, 0.26, 1.00)
        colors[clr.TitleBgCollapsed]       = ImVec4(0.19, 0.22, 0.26, 0.59)
        colors[clr.MenuBarBg]              = ImVec4(0.19, 0.22, 0.26, 1.00)
        colors[clr.ScrollbarBg]            = ImVec4(0.20, 0.25, 0.30, 0.60)
        colors[clr.ScrollbarGrab]          = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.ScrollbarGrabHovered]   = ImVec4(0.49, 0.63, 0.86, 1.00)
        colors[clr.ScrollbarGrabActive]    = ImVec4(0.49, 0.63, 0.86, 1.00)
        colors[clr.ComboBg]                = ImVec4(0.20, 0.20, 0.20, 0.99)
        colors[clr.CheckMark]              = ImVec4(0.90, 0.90, 0.90, 0.50)
        colors[clr.SliderGrab]             = ImVec4(1.00, 1.00, 1.00, 0.30)
        colors[clr.SliderGrabActive]       = ImVec4(0.80, 0.50, 0.50, 1.00)
        colors[clr.Button]                 = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.ButtonHovered]          = ImVec4(0.49, 0.62, 0.85, 1.00)
        colors[clr.ButtonActive]           = ImVec4(0.49, 0.62, 0.85, 1.00)
        colors[clr.Header]                 = ImVec4(0.19, 0.22, 0.26, 1.00)
        colors[clr.HeaderHovered]          = ImVec4(0.22, 0.24, 0.28, 1.00)
        colors[clr.HeaderActive]           = ImVec4(0.22, 0.24, 0.28, 1.00)
        colors[clr.Separator]              = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.SeparatorHovered]       = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.SeparatorActive]        = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.ResizeGrip]             = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(0.49, 0.61, 0.83, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(0.49, 0.62, 0.83, 1.00)
        colors[clr.CloseButton]            = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.CloseButtonHovered]     = ImVec4(0.50, 0.63, 0.84, 1.00)
        colors[clr.CloseButtonActive]      = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.PlotLines]              = ImVec4(1.00, 1.00, 1.00, 1.00)
        colors[clr.PlotLinesHovered]       = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogram]          = ImVec4(0.90, 0.70, 0.00, 1.00)
        colors[clr.PlotHistogramHovered]   = ImVec4(1.00, 0.60, 0.00, 1.00)
        colors[clr.TextSelectedBg]         = ImVec4(0.41, 0.55, 0.78, 1.00)
        colors[clr.ModalWindowDarkening]   = ImVec4(0.16, 0.18, 0.22, 0.76)
    else
        colors[clr.ChildWindowBg]          = ImVec4(0.19, 0.22, 0.26, 0)
        colors[clr.Border] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.WindowBg] = ImVec4(0.13, 0.14, 0.17, 1.00)
        colors[clr.FrameBg] = ImVec4(0.200, 0.220, 0.270, 0.85)
        colors[clr.TitleBg] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.TitleBgActive] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.Button] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.ButtonHovered] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.Separator] = ImVec4(1, 0, 0.3, 1.00)

        colors[clr.ResizeGrip]             = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.ResizeGripHovered]      = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.ResizeGripActive]       = ImVec4(1, 0, 0.3, 1.00)
        --CollapsingHeader
        colors[clr.Header] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.HeaderHovered] = ImVec4(0.68, 0, 0.2, 0.86)
        colors[clr.HeaderActive] = ImVec4(1, 0.24, 0.47, 1.00)
        colors[clr.CheckMark] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.ModalWindowDarkening] = ImVec4(0.200, 0.220, 0.270, 0.73)

        colors[clr.ScrollbarBg] = ImVec4(0.200, 0.220, 0.270, 0.85)
        colors[clr.ScrollbarGrab] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.ScrollbarGrabHovered] = ImVec4(1, 0, 0.3, 1.00)
        colors[clr.ScrollbarGrabActive] = ImVec4(1, 0, 0.3, 1.00)

        colors[clr.ButtonActive] = ImVec4(1, 0, 0.3, 1.00)
    end
end
BH_theme()

