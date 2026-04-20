math.randomseed(os.time())
local randomInt = math.random(11111, 99999)

local VEND_IDS    = { [2978] = true, [9268] = true }
local vendData    = {}
local scanRunning = false
local autoRunning  = false
local fpDelay      = 200
local vendPathMode = "Step"
local pendingVend    = nil
local VEND_UPLOAD_URL = "https://www.grandfuscator.my.id/api/grandfuscator-locator"
local VEND_RAW_URL    = "https://secretapp-wkwk-apaajadah-test.vercel.app/apo/secret/key/nothing/heeh/nonono/panjangkan/vend_data.lua"
local lastWorld      = ""
local locatorCache   = nil

local function log(msg)
    LogToConsole("`w[`cGrandfuscator`w] " .. msg)
end

function inv(item)
    for _, object in pairs(GetInventory()) do
        if object.id == item then return object.amount end
    end
    return 0
end

local function getItemName(id)
    if id == 0 then return "None" end
    local info = getItemInfoByID(id)
    return (info and info.name) or ("ID:" .. id)
end

local function goToVend(tx, ty)
    if vendPathMode == "Direct" then
        goDirect(tx, ty)
    else
        goToStep(tx, ty)
    end
end

local function goToStep(tx, ty)
    local localPlayer = GetLocal()
    if not localPlayer then return end

    local px = math.floor(localPlayer.posX / 32)
    local py = math.floor(localPlayer.posY / 32)

    if math.abs(px - tx) <= 2 and math.abs(py - ty) <= 2 then return end

    local jarax = tx - px
    local jaray = ty - py
    

    if jaray > 6 then
        local steps = math.min(math.floor(jaray / 6))
        for i = 1, steps do
            py = py + 1
            FindPath(px, py)
            Sleep(fpDelay)
        end
    elseif jaray < -6 then
        local steps = math.min(math.floor(-jaray / 6))
        for i = 1, steps do
            py = py - 1
            FindPath(px, py)
            Sleep(fpDelay)
        end
    end

    if jarax > 8 then
        local steps = math.min(math.floor(jarax / 6))
        for i = 1, steps do
            px = px + 1
            FindPath(px, py)
            Sleep(fpDelay)
        end
    elseif jarax < -6 then
        local steps = math.min(math.floor(-jarax / 6))
        for i = 1, steps do
            px = px - 1
            FindPath(px, py)
            Sleep(fpDelay)
        end
    end

    FindPath(tx, ty)
    Sleep(fpDelay)
end

local function goDirect(tx, ty)
    FindPath(tx, ty)
    Sleep(fpDelay)
end

local function wrenchTile(x, y)
    local p = GetLocal()
    if not p then return end
    SendPacketRaw(false, {
        type  = 3,
        value = 32,
        x     = x * 32,
        y     = y * 32,
        px    = x,
        py    = y,
        state = 32,
        netid = p.netID,
    })
end

local function urlEncode(s)
    s = tostring(s or "")
    s = s:gsub("\n", "\r\n")
    s = s:gsub("([^%%w %-%_%.])", function(c)
        return string.format("%%%02X", string.byte(c))
    end)
    return s:gsub(" ", "%%20")
end

local function formatAge(ts)
    local diff = os.time() - ts
    if diff < 0 then diff = 0 end
    local d = math.floor(diff / 86400)
    local h = math.floor((diff % 86400) / 3600)
    local m = math.floor((diff % 3600)  / 60)
    local s = diff % 60
    local parts = {}
    if d > 0 then table.insert(parts, d .. "d") end
    if h > 0 then table.insert(parts, h .. "h") end
    if m > 0 then table.insert(parts, m .. "m") end
    table.insert(parts, s .. "s")
    return table.concat(parts, " ")
end

local MAX_URL_LEN = 3000

local function buildVendParams(worldName, vends, chunkIdx, totalChunks)
    local parts = {
        "?action=upload",
        "&world="  .. urlEncode(worldName),
        "&count="  .. tostring(#vends),
        "&chunk="  .. tostring(chunkIdx),
        "&chunks=" .. tostring(totalChunks),
    }
    for i, v in ipairs(vends) do
        local n = tostring(i)
        table.insert(parts, "&v" .. n .. "_id="    .. tostring(v.vend_item))
        table.insert(parts, "&v" .. n .. "_item="  .. urlEncode(getItemName(v.vend_item)))
        table.insert(parts, "&v" .. n .. "_vend="  .. urlEncode(getItemName(v.fg)))
        table.insert(parts, "&v" .. n .. "_price=" .. tostring(v.price))
        table.insert(parts, "&v" .. n .. "_x="     .. tostring(v.x))
        table.insert(parts, "&v" .. n .. "_y="     .. tostring(v.y))
    end
    return table.concat(parts)
end

local function uploadVends(worldName, vList)
    if #vList == 0 then return end

    local testQuery = buildVendParams(worldName, vList, 1, 1)
    if #VEND_UPLOAD_URL + #testQuery <= MAX_URL_LEN then
        fetch(VEND_UPLOAD_URL .. testQuery)
        
        return
    end

    
    local chunks = {}
    local cur = {}
    for _, v in ipairs(vList) do
        table.insert(cur, v)
        local q = buildVendParams(worldName, cur, 1, 1)
        if #VEND_UPLOAD_URL + #q > MAX_URL_LEN then
            
            table.remove(cur)
            if #cur > 0 then
                table.insert(chunks, cur)
            end
            cur = { v }
        end
    end
    if #cur > 0 then table.insert(chunks, cur) end

    local totalChunks = #chunks
    
    for i, chunkVends in ipairs(chunks) do
        local q = buildVendParams(worldName, chunkVends, i, totalChunks)
        fetch(VEND_UPLOAD_URL .. q)
        Sleep(300)
    end
    log("Upload done: " .. totalChunks .. " chunks sent")
end

local function fetchLocatorData(callback)
    local raw, err = fetch(VEND_RAW_URL)
    if not raw then
        
        if callback then callback(nil) end
        return
    end
    local fn, lerr = load(raw)
    if not fn then
        
        if callback then callback(nil) end
        return
    end
    fn()
    local raw_list = datavending or {}
    local data = { vends = {}, total_worlds = 0, total_vends = 0 }
    local worldSet = {}
    for _, v in ipairs(raw_list) do
        table.insert(data.vends, v)
        if not worldSet[v.world] then
            worldSet[v.world] = true
            data.total_worlds = data.total_worlds + 1
        end
        data.total_vends = data.total_vends + 1
    end
    locatorCache = data
    if callback then callback(data) end
end

local locatorQuery     = ""
local locatorSortMode  = "newest"
local locatorPage      = 1
local ITEMS_PER_PAGE   = 20
local locatorFiltered  = {}

local function showSearchDialog()
    local sn = locatorSortMode == "newest" and "staticBlueFrame" or "frame"
    local sl = locatorSortMode == "low"    and "staticBlueFrame" or "frame"
    local sh = locatorSortMode == "high"   and "staticBlueFrame" or "frame"
    local dia = [[
add_label_with_icon|big|`wSearch Items|left|6016|
add_smalltext|`9Find the items you need here.|left|
add_spacer|small|
add_textbox|`8Item name (partial match):|left|
add_text_input|vl_query|||999|left|
add_spacer|small|
add_label_with_icon|small|`wFilters|left|9268|
add_button_with_icon|vl_sort_newest|`wNewest First|]]..sn..[[|242||
add_button_with_icon|vl_sort_low|`wLowest Price|]]..sl..[[|242||
add_button_with_icon|vl_sort_high|`wHighest Price|]]..sh..[[|242||
add_button_with_icon||END_LIST||||
add_spacer|small|
end_dialog|VendSearchDia|Cancel|Search|
]]
    SendVariant({ v1 = "OnDialogRequest", v2 = dia })
end

local function showLocatorResults(query, data, page)
    if not data or not data.vends then return end
    page = page or locatorPage

    local q = query:lower()
    locatorFiltered = {}
    local worldSeen = {}
    for _, v in ipairs(data.vends) do
        local name = (v.item_name or ""):lower()
        if q == "" or name:find(q, 1, true) then
            
            table.insert(locatorFiltered, v)
            worldSeen[v.world] = true
        end
    end
    if locatorSortMode == "newest" then
        table.sort(locatorFiltered, function(a, b) return (a.timestamp or 0) > (b.timestamp or 0) end)
    elseif locatorSortMode == "low" then
        table.sort(locatorFiltered, function(a, b) return (a.price or 0) < (b.price or 0) end)
    elseif locatorSortMode == "high" then
        table.sort(locatorFiltered, function(a, b) return (a.price or 0) > (b.price or 0) end)
    end

    local totalFound = #locatorFiltered
    local totalPages = math.max(1, math.ceil(totalFound / ITEMS_PER_PAGE))
    page = math.max(1, math.min(page, totalPages))
    locatorPage = page

    local minP, maxP = math.huge, 0
    for _, v in ipairs(locatorFiltered) do
        if v.price < minP then minP = v.price end
        if v.price > maxP then maxP = v.price end
    end
    if totalFound == 0 then minP = 0 end
    local avgStr = totalFound > 0 and (minP .. "-" .. maxP .. " ") or "N/A"

    
    local uniqueWorlds = 0
    for _ in pairs(worldSeen) do uniqueWorlds = uniqueWorlds + 1 end

    local startIdx = (page - 1) * ITEMS_PER_PAGE + 1
    local endIdx   = math.min(page * ITEMS_PER_PAGE, totalFound)

    local lb = {}
    table.insert(lb, "add_label_with_icon|big|`2Vend Locator|left|242|")
    table.insert(lb, "add_smalltext|`9Search `7" .. data.total_worlds ..
        " `9Worlds. Found `5" .. data.total_vends .. " `9Vends.|left|")
    table.insert(lb, "add_spacer|small|")
    table.insert(lb, "add_textbox|`2Successfully `wFound Vending machine|left|")
    table.insert(lb, "add_textbox|`w Average price : `5" .. avgStr .. " `w(wl).|left|")
    table.insert(lb, "add_textbox|`w Total Vending : `5" .. totalFound ..
        "`w  |  Page `9" .. page .. "`w/`9" .. totalPages .. "`w.|left|")
    table.insert(lb, "add_spacer|small|")

    if totalFound == 0 then
        table.insert(lb, "add_textbox|`4No results found for: `w" .. query .. "|left|")
    else
        for i = startIdx, endIdx do
            local v = locatorFiltered[i]
            if v then
                local age   = formatAge(v.timestamp or 0)
                local label = string.format(
                    "`w%s `7%d`w(wl) (`8%s`w) In `9%s`w.",
                    v.item_name, v.price, age, v.world)
                table.insert(lb,
                    "add_label_with_icon|small|" .. label .. "|left|" .. v.item_id .. "|")
            end
        end
    end

    local rows = table.concat(lb, "\n")
    local navRows = ""
    if totalPages > 1 then
        local pv = page > 1          and "`w< Prev" or "`8< Prev"
        local nx = page < totalPages and "`wNext >" or "`8Next >"
        navRows = "add_button_with_icon|vl_prev|"..pv.."|frame|5672||\nadd_button_with_icon||END_LIST||||\nadd_button_with_icon|vl_next|"..nx.."|frame|5674||\nadd_button_with_icon||END_LIST||||\nadd_spacer|small|\n"
    end
    local dia = [[
add_label_with_icon|big|`2Vend Locator|left|242|
add_smalltext|`9Search `7]]..data.total_worlds..[[  `9Worlds. Found `5]]..data.total_vends..[[ `9Vends.|left|
add_spacer|small|
add_textbox|`2Successfully `wFound Vending machine|left|
add_textbox|`w Average price : `5]]..avgStr..[[ `w(wl).|left|
add_textbox|`w Total Vending : `5]]..totalFound..[[`w  |  Page `9]]..page..[[`w/`9]]..totalPages..[[`w.|left|
add_spacer|small|
]]..rows..[[
add_button_with_icon||END_LIST||||
]]..navRows..[[
end_dialog|VendLocatorDia| Back | Close |
]]
    SendVariant({ v1 = "OnDialogRequest", v2 = dia })
end

function openVendLocator()
    editValue("vh_status!" .. randomInt, "Status: Loading...")
    runThread(function()
        fetchLocatorData(function(data)
            editValue("vh_status!" .. randomInt, "Status: Idle")
            if not data then
                growtopia.notify("`4Failed to load vend data")
                return
            end
            showSearchDialog()
        end)
    end)
end

function scanVends()
    if scanRunning then log("Already scanning!") return end
    scanRunning = true
    vendData = {}
    log("Scanning vends...")
    runThread(function()
        local wm = getWorldTileMap()
        if not wm then log("Cannot get world!") scanRunning = false return end
        local maxX = wm.size.x - 1
        local maxY = wm.size.y - 1
        local found = 0
        for y = 0, maxY do
            if y % 10 == 0 then Sleep(5) end
            for x = 0, maxX do
                local t = getTile(x, y)
                if t and VEND_IDS[t.fg] and t.extra then
                    local ex = t.extra
                    table.insert(vendData, {
                        x          = x,
                        y          = y,
                        fg         = t.fg,
                        price      = ex.vend_price or 0,
                        vend_item  = ex.vend_item  or 0,
                        owner      = ex.owner      or 0,
                        label      = ex.label      or "",
                    })
                    found = found + 1
                end
            end
        end
        log("Found " .. found .. " vends")
        editValue("vh_status!" .. randomInt, "Status: Found " .. found .. " vends")
        scanRunning = false
        
        local wn = GetWorldName and GetWorldName() or "UNKNOWN"
        uploadVends(wn, vendData)
    end)
end

function showVendList()
    if #vendData == 0 then log("No vend data! Scan first.") return end
    local rows = {}
    for i, v in ipairs(vendData) do
        table.insert(rows, "add_button_with_icon|vend_"..i.."|`$"..getItemName(v.vend_item).." `0- `9"..v.price.."`0|frame|"..v.vend_item.."||")
    end
    local dia = [[
add_label_with_icon|big|`wVend Helper - Vend List|left|2978|
add_spacer|small|
add_textbox|`wFound `9]]..#vendData..[[ `wvending machines|left|
add_spacer|small|
]]..table.concat(rows, "\n")..[[

add_button_with_icon||END_LIST||||
add_spacer|small|
end_dialog|VendListDia| Close ||
]]
    SendVariant({ v1 = "OnDialogRequest", v2 = dia })
end

function showVendDetail(idx)
    local v = vendData[idx]
    if not v then log("Vend #"..idx.." not found") return end
    local iName = getItemName(v.vend_item)
    local vName = getItemName(v.fg)
    local labelRow = v.label ~= "" and ("add_textbox|`wLabel  `e"..v.label.."`0|left|\nadd_spacer|small|\n") or ""
    local stockRow = v.vend_item == 0 and ("add_textbox|`8Stock Item ID:|left|\nadd_text_input|stock_item_"..idx.."|||6|left|\nadd_button_with_icon|do_stock_item_"..idx.."|`2Set Stock Item|frame|6||\n") or ""
    local dia = [[
add_label_with_icon|big|`w]]..vName..[[ Info|left|]]..v.fg..'|'..[[
add_spacer|small|
add_textbox|`wVend Name  `2]]..vName..[[`0|left|
add_spacer|small|
add_textbox|`wPosition  `9X: ]]..v.x..'   Y: '..v.y..[[`0|left|
add_spacer|small|
add_textbox|`wItem  `$]]..iName..[[ `8(ID: ]]..v.vend_item..[[)`0|left|
add_spacer|small|
add_textbox|`wPrice  `9]]..v.price..[[ WL`0|left|
add_spacer|small|
]]..labelRow..[[add_label_with_icon|small|`wGo To Vend|left|482|
add_button_with_icon|go_direct_]]..idx..[[|`$Direct `8(FindPath)`0|frame|482||
add_button_with_icon|go_step_]]..idx..[[|`$Step `8(Step by step)`0|frame|482||
add_button_with_icon||END_LIST||||
add_spacer|small|
add_label_with_icon|small|`2Owner `wControls|left|242|
add_spacer|small|
add_textbox|`8Set Price (World Locks):|left|
add_text_input|vend_price_]]..idx..[[|||6|left|
add_spacer|small|
add_button_with_icon|set_price_]]..idx..[[|`2Set Price|frame|6||
add_button_with_icon|add_stock_]]..idx..[[|`2Add Stock|frame|6||
add_button_with_icon|pull_stock_]]..idx..[[|`4Pull Stock|frame|6||
]]..stockRow..[[add_button_with_icon||END_LIST||||
add_spacer|small|
add_textbox|`8Lock Options:|left|
add_button_with_icon|peritem_]]..idx..[[|`2Set Item Per World Lock|frame|6||
add_button_with_icon|perlock_]]..idx..[[|`2Set World Lock Per Item|frame|6||
add_button_with_icon||END_LIST||||
add_spacer|small|
end_dialog|VendDetailDia| Back | Close |
]]
    SendVariant({ v1 = "OnDialogRequest", v2 = dia })
end

addHook(function(vtype, pkt)
    if not pkt or #pkt < 4 then return false end

    local idx = pkt:match("buttonClicked|vend_(%d+)")
    if idx then showVendDetail(tonumber(idx)) return true end

    if pkt:find("buttonClicked|go_direct_", 1, true) then
        local i = tonumber(pkt:match("go_direct_(%d+)"))
        local v = vendData[i]
        if v then runThread(function() goDirect(v.x, v.y) end) end
        return true
    end

    if pkt:find("buttonClicked|go_step_", 1, true) then
        local i = tonumber(pkt:match("go_step_(%d+)"))
        local v = vendData[i]
        if v then runThread(function() goToVend(v.x, v.y) end) end
        return true
    end

    if pkt:find("buttonClicked|set_price_", 1, true) then
        local i = tonumber(pkt:match("set_price_(%d+)"))
        local v = vendData[i]
        local price = pkt:match("vend_price_" .. i .. "|([^|\n]*)")
        if v and price then
            price = price:match("^%s*(.-)%s*$")
            if price ~= "" then
            goToVend(v.x, v.y)
                    Sleep(500)
                wrenchTile(v.x, v.y)
                Sleep(200)
                SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nsetprice|"..price.."\nchk_peritem|0\nchk_perlock|0\n")
                v.price = tonumber(price) or v.price
                log("Set price vend (" .. v.x .. "," .. v.y .. ") -> " .. price .. " WL")
            end
        end
        return true
    end

    if pkt:find("buttonClicked|add_stock_", 1, true) then
        local i = tonumber(pkt:match("add_stock_(%d+)"))
        local v = vendData[i]
        if v then
        goToVend(v.x, v.y)
                    Sleep(500)
            wrenchTile(v.x, v.y)
            Sleep(200)
            SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nbuttonClicked|addstocks\n\nsetprice|0\nchk_peritem|0\nchk_perlock|0\n")
            log("Add stock vend (" .. v.x .. "," .. v.y .. ")")
        end
        return true
    end

    if pkt:find("buttonClicked|pull_stock_", 1, true) then
        local i = tonumber(pkt:match("pull_stock_(%d+)"))
        local v = vendData[i]
        if v then
        goToVend(v.x, v.y)
                    Sleep(500)
            wrenchTile(v.x, v.y)
            Sleep(200)
            SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nbuttonClicked|pullstocks\n\nsetprice|0\nchk_peritem|0\nchk_perlock|0\n")
            log("Pull stock vend (" .. v.x .. "," .. v.y .. ")")
        end
        return true
    end

    if pkt:find("buttonClicked|do_stock_item_", 1, true) then
        local i = tonumber(pkt:match("do_stock_item_(%d+)"))
        local v = vendData[i]
        local itemID = pkt:match("stock_item_" .. i .. "|([^|\n]*)")
        if v and itemID then
            itemID = itemID:match("^%s*(.-)%s*$")
            if itemID ~= "" then
            goToVend(v.x, v.y)
                    Sleep(500)
                wrenchTile(v.x, v.y)
                Sleep(200)
                SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nstockitem|"..itemID.."\n")
                v.vend_item = tonumber(itemID) or 0
                log("Stock item vend (" .. v.x .. "," .. v.y .. ") -> " .. itemID)
            end
        end
        return true
    end

    if pkt:find("buttonClicked|peritem_", 1, true) then
        local i = tonumber(pkt:match("peritem_(%d+)"))
        local v = vendData[i]
        if v then
        goToVend(v.x, v.y)
                    Sleep(500)
            wrenchTile(v.x, v.y)
            Sleep(200)
            SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nsetprice|"..v.price.."\nchk_peritem|1\nchk_perlock|0\n")
            log("Set per item vend (" .. v.x .. "," .. v.y .. ")")
        end
        return true
    end

    if pkt:find("buttonClicked|perlock_", 1, true) then
        local i = tonumber(pkt:match("perlock_(%d+)"))
        local v = vendData[i]
        if v then
        goToVend(v.x, v.y)
                    Sleep(500)
            wrenchTile(v.x, v.y)
            Sleep(200)
            SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nsetprice|"..v.price.."\nchk_peritem|0\nchk_perlock|1\n")
            log("Set per lock vend (" .. v.x .. "," .. v.y .. ")")
        end
        return true
    end

    if pkt:find("VendDetailDia", 1, true) and pkt:find("Back", 1, true) then
        showVendList()
        return true
    end

    if pkt:find("buttonClicked|vl_sort_newest", 1, true) then
        locatorSortMode = "newest"
        showSearchDialog()
        return true
    end
    if pkt:find("buttonClicked|vl_sort_low", 1, true) then
        locatorSortMode = "low"
        showSearchDialog()
        return true
    end
    if pkt:find("buttonClicked|vl_sort_high", 1, true) then
        locatorSortMode = "high"
        showSearchDialog()
        return true
    end

    if pkt:find("VendSearchDia", 1, true) and not pkt:find("Cancel", 1, true) then
        local q = pkt:match("vl_query|([^|\n]*)") or ""
        q = q:match("^%s*(.-)%s*$")
        locatorQuery = q
        locatorPage  = 1
        if locatorCache then
            showLocatorResults(q, locatorCache, 1)
        else
            editValue("vh_status!" .. randomInt, "Status: Loading...")
            runThread(function()
                fetchLocatorData(function(data)
                    editValue("vh_status!" .. randomInt, "Status: Idle")
                    showLocatorResults(q, data)
                end)
            end)
        end
        return true
    end

    if pkt:find("VendLocatorDia", 1, true) and pkt:find("Back", 1, true) then
        showSearchDialog()
        return true
    end

    if pkt:find("buttonClicked|vl_prev", 1, true) then
        if locatorCache and locatorPage > 1 then
            showLocatorResults(locatorQuery, locatorCache, locatorPage - 1)
        end
        return true
    end

    if pkt:find("buttonClicked|vl_next", 1, true) then
        if locatorCache then
            local totalPages = math.max(1, math.ceil(#locatorFiltered / ITEMS_PER_PAGE))
            if locatorPage < totalPages then
                showLocatorResults(locatorQuery, locatorCache, locatorPage + 1)
            end
        end
        return true
    end

    return false
end, "onSendPacket")



function runAutoRestock()
    if autoRunning then log("Auto already running!") return end
    if #vendData == 0 then log("Scan vends first!") return end
    autoRunning = true
    log("Auto restock started...")
    runThread(function()
        for _, v in ipairs(vendData) do
            if not autoRunning then break end
            while autoRunning do
            if v.vend_item ~= 0 then
                local have = inv(v.vend_item)
                if have > 0 then
                    log(string.format("Restocking (%d,%d): %s x%d", v.x, v.y, getItemName(v.vend_item), have))
                    goToVend(v.x, v.y)
                    Sleep(500)
                    wrenchTile(v.x, v.y)
                    Sleep(200)
                    SendPacket(2, "action|dialog_return\ndialog_name|vending\ntilex|"..v.x.."|\ntiley|"..v.y.."|\nbuttonClicked|addstocks\n\nsetprice|0\nchk_peritem|1\nchk_perlock|0\n")
                    Sleep(800)
                else
                    log(string.format("Skip (%d,%d): no %s in inv", v.x, v.y, getItemName(v.vend_item)))
                    end
                end
            end
        end
        
        editValue("vh_status!" .. randomInt, "Status: Auto restock done")
    end)
end

function stopAuto()
    autoRunning = false
    log("Auto stopped.")
    editValue("vh_status!" .. randomInt, "Status: Idle")
end

local moduleJSON = (function()
    local ri = tostring(randomInt)
    return [[
{
    "sub_name": "Vend Helper [BETA]",
    "icon": "Storefront",
    "menu": [
        {
            "type": "labelapp",
            "icon": "Storefront",
            "text": "Grandfuscator Vend Helper v1 BETA"
        },
        {
            "type": "divider"
        },
        {
            "type": "label",
            "text": "Status: Idle",
            "alias": "vh_status!]] .. ri .. [["
        },
        {
            "type": "divider"
        },
        {
            "type": "button",
            "text": "Scan Vends",
            "alias": "vh_scan!]] .. ri .. [["
        },
        {
            "type": "button",
            "text": "Show Vend List",
            "alias": "vh_show!]] .. ri .. [["
        },
        {
            "type": "button",
            "text": "Vend Locator",
            "alias": "vh_locator!]] .. ri .. [["
        },
        {
            "type": "divider"
        },
        {
            "type": "labelapp",
            "icon": "AutoMode",
            "text": "AUTO RESTOCK"
        },
        {
            "type": "button",
            "text": "Start Auto Restock",
            "alias": "vh_auto!]] .. ri .. [["
        },
        {
            "type": "button",
            "text": "Stop Auto",
            "alias": "vh_stop!]] .. ri .. [["
        },
        {
            "type": "divider"
        },
        {
            "type": "labelapp",
            "icon": "Navigation",
            "text": "OWNER ACTION PATH MODE"
        },
        {
            "type": "toggle",
            "text": "Step (per tile)",
            "alias": "vh_vp_step!]] .. ri .. [[",
            "default": true
        },
        {
            "type": "toggle",
            "text": "Direct (FindPath langsung)",
            "alias": "vh_vp_direct!]] .. ri .. [[",
            "default": false
        },
        {
            "type": "divider"
        },
        {
            "type": "labelapp",
            "icon": "Settings",
            "text": "SETTINGS"
        },
        {
            "type": "slider",
            "text": "FindPath Delay (ms)",
            "alias": "vh_fpdelay!]] .. ri .. [[",
            "min": 50,
            "max": 1000,
            "default": 200,
            "use_dot": false
        },
        {
            "type": "divider"
        },
        {
            "type": "label",
            "text": "Script by Grandfuscator"
        }
    ]
}
]]
end)()

addHook(function(vtype, name, value)
    local alias, id = name:match("(.+)!(%d+)")
    if id ~= tostring(randomInt) then return false end

    if vtype == 0 then
        if alias == "vh_scan" then
            scanVends()
            return true
        elseif alias == "vh_show" then
            showVendList()
            return true
        elseif alias == "vh_auto" then
            runAutoRestock()
            return true
        elseif alias == "vh_stop" then
            stopAuto()
            return true
        elseif alias == "vh_locator" then
            openVendLocator()
            return true
        end
    end

    if vtype == 1 and alias == "vh_fpdelay" then
        fpDelay = tonumber(value) or 200
        return true
    end

    if vtype == 0 and alias == "vh_vp_step" and value == true then
        vendPathMode = "Step"
        editToggle("vh_vp_direct!" .. randomInt, false)
        log("Owner path: Step")
        return true
    end

    if vtype == 0 and alias == "vh_vp_direct" and value == true then
        vendPathMode = "Direct"
        editToggle("vh_vp_step!" .. randomInt, false)
        log("Owner path: Direct")
        return true
    end

    return false
end, "onValue")

AddHook(function(var, pkt)
    if not var or var.v1 ~= "OnCountryState" then return false end
    local wn = GetWorldName and GetWorldName() or ""
    if wn ~= "" and wn ~= lastWorld then
        lastWorld = wn
        scanVends()
    end
    return false
end, "onVariant")

AddHook(function(vtype, name, value)
    if scriptMode ~= "module" then return false end
    local alias, id = name:match("(.+)!(%d+)")
    if id ~= tostring(randomInt) then return false end
    if vtype == 0 then
        if alias == "vh_scan" then scanVends() return true
        elseif alias == "vh_show" then showVendList() return true
        elseif alias == "vh_auto" then runAutoRestock() return true
        elseif alias == "vh_stop" then stopAuto() return true
        elseif alias == "vh_locator" then openVendLocator() return true
        end
    end
    if vtype == 1 and alias == "vh_fpdelay" then fpDelay = tonumber(value) or 200 return true end
    if vtype == 0 and alias == "vh_vp_step" and value == true then
        vendPathMode = "Step"
        editToggle("vh_vp_direct!"..randomInt, false)
        return true
    end
    if vtype == 0 and alias == "vh_vp_direct" and value == true then
        vendPathMode = "Direct"
        editToggle("vh_vp_step!"..randomInt, false)
        return true
    end
    return false
end, "onValue")

AddHook(function(type, gr)
    -- /start: pilih mode (hanya kalau belum pilih)
    if gr:find("text|/start") and scriptMode == nil then
        modeDia = [[
add_label_with_icon|big|`cVend Helper `wMode|left|2978|
add_spacer|small|
add_textbox|`wPilih mode penggunaan Vend Helper.|left|
add_spacer|small|
add_button_with_icon|mode_module|`2Module `8(UI di sidebar)|staticBlueFrame|2978||
add_button_with_icon|mode_command|`2Command `8(/vh ...)|staticBlueFrame|2978||
add_button_with_icon||END_LIST||||
add_spacer|small|
end_dialog|VHModeDia||
]]
        SendVariant({ v1 = "OnDialogRequest", v2 = modeDia })
        return true
    end

    if gr:find("mode_module") and scriptMode == nil then
        scriptMode = "module"
        addIntoModule(moduleJSON)
        editValue("vh_status!"..randomInt, "Status: Idle")
        growtopia.notify("`2Vend Helper: Module mode aktif")
        return true
    end

    if gr:find("mode_command") and scriptMode == nil then
        scriptMode = "command"
        growtopia.notify("`2Vend Helper: Command mode. Ketik /vh help")
        return true
    end

    -- Command mode: /vh ...
    if scriptMode ~= "command" then return false end

    if gr:find("text|/vh scan") then scanVends() return true end
    if gr:find("text|/vh list") then showVendList() return true end
    if gr:find("text|/vh locator") then openVendLocator() return true end
    if gr:find("text|/vh auto") then runAutoRestock() return true end
    if gr:find("text|/vh stop") then stopAuto() return true end
    if gr:find("text|/vh path step") then
        vendPathMode = "Step"
        growtopia.notify("`2Path mode: Step")
        return true
    end
    if gr:find("text|/vh path direct") then
        vendPathMode = "Direct"
        growtopia.notify("`2Path mode: Direct")
        return true
    end
    if gr:find("text|/vh delay (%d+)") then
        local ms = tonumber(gr:match("text|/vh delay (%d+)"))
        if ms then fpDelay = ms growtopia.notify("`2FindPath delay: "..ms.."ms") end
        return true
    end
    if gr:find("text|/vh") then
        helpDia = [[
add_label_with_icon|big|`cVend Helper `wCommands|left|2978|
add_smalltext|`w======================================|left|
add_label_with_icon|small|`2/vh scan `w- Scan vends di world ini|left|2978|
add_label_with_icon|small|`2/vh list `w- Tampilkan daftar vend|left|2978|
add_label_with_icon|small|`2/vh locator `w- Buka Vend Locator|left|4996|
add_label_with_icon|small|`2/vh auto `w- Start auto restock|left|6|
add_label_with_icon|small|`2/vh stop `w- Stop auto restock|left|6|
add_label_with_icon|small|`2/vh path step `w- Set path mode: Step|left|482|
add_label_with_icon|small|`2/vh path direct `w- Set path mode: Direct|left|482|
add_label_with_icon|small|`2/vh delay <ms> `w- Set FindPath delay|left|482|
add_smalltext|`w======================================|left|
add_button|exit|`wClose|
end_dialog|VHHelp||
]]
        SendVariant({ v1 = "OnDialogRequest", v2 = helpDia })
        return true
    end

    return false
end, "OnSendPacket")

log("Vend Helper loaded! Ketik /start untuk memilih mode.")
