# Sync-Backpacks
Backpacks with persistent stash + synced prop - Works with ox_inventory &amp; qb-inventory
# Sync-Backpacks

**A premium backpack system for FiveM with persistent storage and synced props.**

Compatible with **ox_inventory** (ESX/QBCore/Qbox) and **qb-inventory** (QBCore).

---

## Features

- **Persistent Storage** - Items persist between sessions in player-bound stashes
- **Synced Props** - Visual backpack prop attaches to player character
- **Multiple Backpacks** - Small and large backpack variants (easily add more)
- **Inventory Agnostic** - Works with both ox_inventory and qb-inventory
- **Framework Agnostic** - Works with ESX, QBCore, or Qbox
- **Optimized** - Low resource usage with configurable refresh rates
- **Secure** - Stashes are bound to player license identifiers
- **Easy Configuration** - Simple config.lua for all settings

---

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib) (Required)
- [ox_inventory](https://github.com/overextended/ox_inventory) (Recommended) OR [qb-inventory](https://github.com/qbcore-framework/qb-inventory)

---

## Installation

1. Copy `Sync-backpacks` to your `resources` folder
2. Set your inventory system in `config.lua`:
   ```lua
   InventorySystem = 'ox_inventory', -- or 'qb-inventory'
   ```
3. Add the items to your inventory (see `INSTALL/items/`)
4. Copy images from `INSTALL/images/` to your inventory's image folder
5. Configure `config.lua` to your liking
6. Add to `server.cfg`:
```
ensure ox_lib
ensure ox_inventory  -- or ensure qb-inventory
ensure Sync-backpacks
```

---

## Configuration

### Inventory System

Set `InventorySystem` in `config.lua`:
- `'ox_inventory'` - For ox_inventory (works with ESX/QBCore/Qbox)
- `'qb-inventory'` - For qb-inventory (QBCore only)

### Adding More Backpacks

In `config.lua`, add new entries to the `Backpacks` table:

```lua
['yourbackpack'] = {
    label = 'Your Backpack Name',
    stash = {
        slots = 50,
        maxWeight = 50000,
    },
    prop = {
        model = joaat('prop_name_here'),
    },
},
```

### Prop Display Modes

- `PropShowMode = 'always'` - Prop shows when backpack is in inventory
- `PropShowMode = 'equipped'` - Prop only shows when backpack is opened

---

## Commands

| Command | Description |
|---------|-------------|
| `/backpack` | Opens your best available backpack |
| `/backpack smallbackpack` | Opens specific backpack |
| `/backpack largebackpack` | Opens specific backpack |

---

## Inventory Setup

### ox_inventory
Add to `ox_inventory/data/items.lua` (see `INSTALL/items/ox_inventory.txt`)

### qb-inventory
Add to `qb-core/shared/items.lua` (see `INSTALL/items/qb-inventory.txt`)

---

## Support

For support, please provide:
1. Your framework (ESX/QBCore/Qbox)
2. Inventory system (ox_inventory/qb-inventory)
3. Any error messages from F8 console or server console

---

## Version

Current Version: **1.0.0**
