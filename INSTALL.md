# Sync-Backpacks Installation Guide

Works with **ESX + ox_inventory**, **QBCore + ox_inventory**, and **Qbox + ox_inventory**.

---

## 1) Dependencies

Ensure these resources are installed and started **before** this script:

```
ensure ox_lib
ensure ox_inventory
ensure Sync-backpacks
```

## 2) Configuration

Edit `config.lua` to customize:
- Backpack slots/weight limits
- Prop display settings
- Debug mode

---

## 3) INSTALL

When setting up the script, you will need to install the images in the INSTALL folder to your inventory resource. The images are named 'smallbackpack.png' and 'largebackpack.png'. Depending on the inventory resource you are using, you will need to add the items to your inventory resource's items.lua file using the provided code snippets from the INSTALL folder.

---