---@class ServerConfig
---@field Debug boolean
---@field InventorySystem 'ox_inventory' | 'qb-inventory'
---@field Backpacks table<string, {label: string, stash: {slots: number, maxWeight: number}}>
---@field StashPrefix string

---@type ServerConfig
local Config<const> = lib.load('config')

local SCRIPT_VERSION<const> = '1.0.0'
local INVENTORY<const> = Config.InventorySystem

---@param ... any
local function debugPrint(...)
    if not Config.Debug then return end
    print('[Sync-backpacks]', ...)
end

---@param src number
---@return string
local function getIdentifier(src)
    ---@type table
    local identifiers<const> = GetPlayerIdentifiers(src)

    for i = 1, #identifiers do
        ---@type string
        local id<const> = identifiers[i]
        if id:find('license:') == 1 then return id end
    end

    return identifiers[1] or 'unknown'
end

---@param itemName string
---@return {label: string, stash: {slots: number, maxWeight: number}} | nil
local function getBackpackConfig(itemName)
    return Config.Backpacks[itemName]
end

---@param src number
---@param itemName string
---@return string
local function getStashId(src, itemName)
    ---@type string
    local identifier<const> = getIdentifier(src)
    return ('%s:%s:%s'):format(Config.StashPrefix, identifier, itemName)
end

---@param resource string
---@param exportName string
---@param ... any
---@return boolean, any
local function safeExportCall(resource, exportName, ...)
    ---@type boolean, any
    local ok, res = pcall(function(...)
        return exports[resource][exportName](...)
    end, ...)

    if not ok then return false, res end
    return true, res
end


---@param src number
---@param itemName string
---@return boolean
local function hasItem(src, itemName)
    if INVENTORY == 'ox_inventory' then
        ---@type boolean, number
        local ok, count = pcall(function()
            return exports.ox_inventory:GetItemCount(src, itemName)
        end)
        return ok and count and count > 0
    elseif INVENTORY == 'qb-inventory' then
        ---@type boolean, table
        local ok, item = pcall(function()
            return exports['qb-inventory']:GetItemByName(src, itemName)
        end)
        return ok and item and item.amount > 0
    end
    return false
end

---@param src number
---@param itemName string
---@return boolean, string
local function registerStashIfNeeded(src, itemName)
    ---@type {label: string, stash: {slots: number?, maxWeight: number?}} | nil
    local bp = getBackpackConfig(itemName)
    if not bp then return false, 'invalid_backpack' end

    ---@type string
    local stashId<const> = getStashId(src, itemName)

    ---@type number | nil
    local slots = bp.stash and tonumber(bp.stash.slots)
    ---@type number | nil
    local maxWeight = bp.stash and tonumber(bp.stash.maxWeight)
    if not slots or not maxWeight then
        ---@type {slots: number, maxWeight: number} | nil
        local fallback<const> = Config.Backpacks[itemName] and Config.Backpacks[itemName].stash
        slots = slots or tonumber(fallback and fallback.slots)
        maxWeight = maxWeight or tonumber(fallback and fallback.maxWeight)
    end
    if not slots or not maxWeight then
        if itemName == 'largebackpack' then
            slots = slots or 40
            maxWeight = maxWeight or 30000
        else
            slots = slots or 20
            maxWeight = maxWeight or 15000
        end
    end

    slots = tonumber(slots) or 20
    maxWeight = tonumber(maxWeight) or 15000

    debugPrint(('Registering stash %s slots=%s maxWeight=%s'):format(stashId, tostring(slots), tostring(maxWeight)))

    if INVENTORY == 'ox_inventory' then
        ---@type boolean, string?
        local ok, err = pcall(function()
            exports.ox_inventory:RegisterStash(stashId, bp.label or itemName, slots, maxWeight)
        end)
        if not ok then
            debugPrint('RegisterStash failed:', err)
            return false, 'register_failed'
        end
    end

    return true, stashId
end

---@param src number
---@param stashId string
---@return boolean
local function openInventory(src, stashId)
    if INVENTORY == 'ox_inventory' then
        ---@type boolean, string?
        local ok, err = pcall(function()
            exports.ox_inventory:forceOpenInventory(src, 'stash', stashId)
        end)
        if not ok then
            debugPrint('forceOpenInventory failed:', err)
            return false
        end
        return true
    elseif INVENTORY == 'qb-inventory' then
        ---@type boolean, string?
        local ok, err = pcall(function()
            exports['qb-inventory']:OpenInventory(src, 'stash', stashId)
        end)
        if not ok then
            debugPrint('OpenInventory failed:', err)
            return false
        end
        return true
    end
    return false
end

---@param src number
---@param itemName string
---@return boolean, string?
local function openBackpack(src, itemName)
    ---@type boolean, string
    local ok, stashIdOrErr = registerStashIfNeeded(src, itemName)
    if not ok then return false, stashIdOrErr end

    ---@type string
    local stashId<const> = stashIdOrErr

    if not openInventory(src, stashId) then
        return false, 'open_failed'
    end

    TriggerClientEvent('sync_backpacks:setEquipped', src, itemName)
    return true
end

---@param itemName string
RegisterNetEvent('sync_backpacks:open', function(itemName)
    ---@type number
    local src<const> = source
    if type(itemName) ~= 'string' then return end
    if not getBackpackConfig(itemName) then return end

    if not hasItem(src, itemName) then return end

    openBackpack(src, itemName)
end)

---@param source number
---@param itemName string
AddEventHandler('ox_inventory:usedItem', function(source, itemName)
    if INVENTORY ~= 'ox_inventory' then return end
    if type(itemName) ~= 'string' then return end
    if not getBackpackConfig(itemName) then return end

    openBackpack(source, itemName)
end)

---@param source number
---@param item table
AddEventHandler('qb-inventory:server:UseItem', function(source, item)
    if INVENTORY ~= 'qb-inventory' then return end
    if not item or not item.name then return end
    if not getBackpackConfig(item.name) then return end

    openBackpack(source, item.name)
end)

---@param data table | nil
---@param slot table | nil
exports('openBackpack', function(data, slot)
    ---@type number
    local src<const> = source
    ---@type string | nil
    local itemName = type(data) == 'table' and data.name or slot and slot.name

    if not itemName or not getBackpackConfig(itemName) then return end

    openBackpack(src, itemName)
end)

AddEventHandler('onResourceStart', function(res)
    if res ~= GetCurrentResourceName() then return end
    if not GetResourceState('ox_lib'):find('start') then
        print('^1[Sync-backpacks] ERROR: ox_lib is not started! Please ensure ox_lib is started before this resource.^0')
        return
    end
    if INVENTORY == 'ox_inventory' then
        if not GetResourceState('ox_inventory'):find('start') then
            print('^1[Sync-backpacks] ERROR: ox_inventory is not started! Set InventorySystem to qb-inventory if using qb-inventory.^0')
            return
        end
    elseif INVENTORY == 'qb-inventory' then
        if not GetResourceState('qb-inventory'):find('start') then
            print('^1[Sync-backpacks] ERROR: qb-inventory is not started! Set InventorySystem to ox_inventory if using ox_inventory.^0')
            return
        end
    end
    print('^2[Sync-backpacks] Version ' .. SCRIPT_VERSION .. ' started successfully^0')
    print('^2[Sync-backpacks] Inventory System: ' .. INVENTORY .. '^0')
    print('^2[Sync-backpacks] Backpacks configured: ' .. table.concat(GetTableKeys(Config.Backpacks), ', ') .. '^0')
end)

---@param t table
---@return table
function GetTableKeys(t)
    local keys = {}
    for k in pairs(t) do
        keys[#keys + 1] = k
    end
    return keys
end
