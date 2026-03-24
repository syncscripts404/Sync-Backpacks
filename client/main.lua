---@class ClientConfig
---@field Debug boolean
---@field InventorySystem 'ox_inventory' | 'qb-inventory'
---@field PropShowMode 'always' | 'equipped'
---@field PropWhenInInventory boolean
---@field RefreshIntervalMs number
---@field Attach {bone: integer, pos: vector3, rot: vector3}
---@field Backpacks table<string, {label: string, stash: {slots: number, maxWeight: number}, prop: {model: string|integer}}>
---@field StashPrefix string

---@type ClientConfig
local Config<const> = lib.load('config')
local INVENTORY<const> = Config.InventorySystem

---@type string | nil
local equipped = nil

---@type number | nil
local currentProp = nil

---@param ... any
local function debugPrint(...)
    if not Config.Debug then return end
    print('[Sync-backpacks]', ...)
end

---@param itemName string
---@return boolean
local function hasItem(itemName)
    if INVENTORY == 'ox_inventory' then
        ---@type boolean, number
        local ok, count = pcall(function()
            return exports.ox_inventory:GetItemCount(itemName)
        end)
        if not ok then return false end
        return (count or 0) > 0
    elseif INVENTORY == 'qb-inventory' then
        ---@type boolean, table
        local ok, PlayerData = pcall(function()
            return exports['qb-inventory']:GetPlayerData()
        end)
        if not ok or not PlayerData or not PlayerData.items then return false end
        for _, item in pairs(PlayerData.items) do
            if item and item.name == itemName and item.amount > 0 then
                return true
            end
        end
        return false
    end
    return false
end

---@return nil
local function deleteProp()
    if currentProp and DoesEntityExist(currentProp) then
        DeleteEntity(currentProp)
    end
    currentProp = nil
end

---@param model string | integer
---@return boolean
local function ensureModel(model)
    if not IsModelInCdimage(model) then return false end

    RequestModel(model)
    while not HasModelLoaded(model) do
        Wait(0)
    end
    return true
end

---@param model string | integer
---@return nil
local function attachBackpack(model)
    deleteProp()

    if not ensureModel(model) then return end

    ---@type number
    local ped<const> = PlayerPedId()
    ---@type number
    local obj<const> = CreateObject(model, 0.0, 0.0, 0.0, false, true, false)
    ---@type number
    local bone<const> = GetPedBoneIndex(ped, Config.Attach.bone)

    AttachEntityToEntity(
        obj,
        ped,
        bone,
        Config.Attach.pos.x, Config.Attach.pos.y, Config.Attach.pos.z,
        Config.Attach.rot.x, Config.Attach.rot.y, Config.Attach.rot.z,
        true, true, false, true, 2, true
    )

    SetModelAsNoLongerNeeded(model)
    currentProp = obj
end

---@return string | nil
local function getDesiredBackpack()
    ---@type boolean
    local showAlways<const> = Config.PropShowMode == 'always' or Config.PropWhenInInventory

    if showAlways then
        if hasItem('largebackpack') then return 'largebackpack' end
        if hasItem('smallbackpack') then return 'smallbackpack' end
        return nil
    end

    return equipped
end

---@return nil
local function refreshProp()
    ---@type string | nil
    local desired = getDesiredBackpack()

    if not desired then
        deleteProp()
        return
    end

    ---@type {prop: {model: string|integer}} | nil
    local bp = Config.Backpacks[desired]
    if not bp then
        deleteProp()
        return
    end

    if currentProp and DoesEntityExist(currentProp) then return end

    attachBackpack(bp.prop.model)
end

---@param itemName string | nil
RegisterNetEvent('sync_backpacks:setEquipped', function(itemName)
    equipped = itemName
    refreshProp()
end)

---@param item string | table
local function onUse(item)
    ---@type string | nil
    local itemName = type(item) == 'string' and item or type(item) == 'table' and item.name or nil

    if not itemName or not Config.Backpacks[itemName] then
        itemName = getDesiredBackpack()
    end

    if not itemName then return end

    TriggerServerEvent('sync_backpacks:open', itemName)
end

AddEventHandler('sync_backpacks:use', onUse)
RegisterNetEvent('sync_backpacks:use', onUse)

---@param _ any
---@param args table
RegisterCommand('backpack', function(_, args)
    ---@type string | nil
    local itemName = args[1]

    if not itemName or not Config.Backpacks[itemName] then
        itemName = getDesiredBackpack()
    end

    if not itemName then return end

    TriggerServerEvent('sync_backpacks:open', itemName)
end, false)

CreateThread(function()
    while true do
        Wait(Config.RefreshIntervalMs)

        ---@type number
        local ped<const> = PlayerPedId()

        if not DoesEntityExist(ped) then
            deleteProp()
        else
            refreshProp()
        end
    end
end)

AddEventHandler('onResourceStop', function(res)
    if res ~= GetCurrentResourceName() then return end
    deleteProp()
end)
