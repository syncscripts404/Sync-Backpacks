---@class BackpackStashConfig
---@field slots number
---@field maxWeight number

---@class BackpackPropConfig
---@field model string | integer

---@class BackpackItem
---@field label string
---@field stash BackpackStashConfig
---@field prop BackpackPropConfig

---@class AttachConfig
---@field bone integer
---@field pos vector3
---@field rot vector3

---@class Config
---@field Debug boolean
---@field InventorySystem 'ox_inventory' | 'qb-inventory'
---@field PropShowMode 'always' | 'equipped'
---@field PropWhenInInventory boolean 
---@field RefreshIntervalMs number
---@field Attach AttachConfig
---@field Backpacks table<string, BackpackItem>
---@field StashPrefix string

-- DO NOT TOUCH ANYTHING ABOVE THIS LINE
-- DO NOT TOUCH ANYTHING ABOVE THIS LINE

return {
    Debug = false,
    -- 'ox_inventory' = overextended ox_inventory (recommended, works with ESX/Qbox)
    -- 'qb-inventory' = qb-inventory (QBCore only)
    InventorySystem = 'ox_inventory',

    -- 'always' = prop shows when backpack is in inventory (default)
    -- 'equipped' = prop only shows when backpack is used/opened
    PropShowMode = 'always',
    PropWhenInInventory = true,

    RefreshIntervalMs = 1500,

    -- DONT TOUCH UNLESS YOU KNOW WHAT U ARE DOING
    Attach = {
        bone = 24818,
        pos = vec3(0.08, -0.16, -0.05),
        rot = vec3(0.0, -90.0, 180.0),
    },

    Backpacks = {
        smallbackpack = {
            label = 'Small Backpack',
            stash = {
                slots = 40,
                maxWeight = 30000,
            },
            prop = {
                model = joaat('sf_prop_sf_backpack_02a'),
            },
        },
        largebackpack = {
            label = 'Large Backpack',
            stash = {
                slots = 70,
                maxWeight = 80000,
            },
            prop = {
                model = joaat('sf_prop_sf_backpack_02a'),
            },
        },
    },

    -- Stash ID prefix - do not change unless you know what you're doing
    StashPrefix = 'syncbp',
}
