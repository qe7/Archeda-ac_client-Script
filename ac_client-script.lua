-- Define color constants
local color = {
    white = color.new(255, 255, 255, 255),
    black = color.new(0, 0, 0, 255),
    red = color.new(255, 0, 0, 255),
    green = color.new(0, 255, 0, 255),
}

-- Define memory addresses
local addresses = {
    game = { module = 0 },
    structures = {
        localPlayer = 0x10F4F4,
        entityList = 0x10F4F8,
    },
    localPlayer = {
        m_iHealth = 0xF8,
        m_iArmor = 0xFC,
        m_iReservePrimaryAmmo = 0x118,
        m_iReserveSecondaryAmmo = 0x114,
        m_iTMPAmmo = 0x140,
        m_iV19Ammo = 0x144,
        m_iAARDAmmo = 0x148,
        m_iAD81Ammo = 0x14C,
        m_iMTP57Ammo = 0x150,
        m_iSecondaryAmmo = 0x13C,
        m_iGrenades = 0x158,
        m_vecOriginX = 0x34,
        m_vecOriginY = 0x38,
        m_vecOriginZ = 0x3C,
        m_vecViewOffsetX = 0x04,
        m_vecViewOffsetY = 0x08,
        m_vecViewOffsetZ = 0x0C,
    },
    entityList = {},
}

-- Flag to track initialization status
local hasInitialized = false

-- Initialize memory addresses
local function initialize()
    if hasInitialized then return end

    addresses.game.module = memory.get_process_module("ac_client.exe")
    if addresses.game.module == 0 then
        print("Failed to find game module.")
    end

    local localPlayer = memory.read_int(addresses.game.module + addresses.structures.localPlayer)
    if localPlayer == 0 then
        print("Failed to find local player.")
    end

    local entityList = memory.read_int(addresses.game.module + addresses.structures.entityList)
    if entityList == 0 then
        print("Failed to find entity list.")
    end

    print("Initialized")
    hasInitialized = true
end

-- Get local player address
local function get_local_player()
    local localPlayer = memory.read_int(addresses.game.module + addresses.structures.localPlayer)
    if localPlayer == 0 then
        print("Failed to find local player.")
    end
    return localPlayer
end

-- Set value if less than the given value
local function set_value_if_less(address, value)
    local currentValue = memory.read_int(address)
    if currentValue < value then
        memory.write_int(address, value)
        return true
    end
    return false
end

-- Enable god mode
local function godmode()
    local localPlayer = get_local_player()
    local playerHealthAddress = localPlayer + addresses.localPlayer.m_iHealth
    if set_value_if_less(playerHealthAddress, 1337) then
        print("Godmode: Health set to 1337")
    end
end

-- Provide unlimited armor
local function unlimited_armor()
    local localPlayer = get_local_player()
    local playerArmorAddress = localPlayer + addresses.localPlayer.m_iArmor
    if set_value_if_less(playerArmorAddress, 1337) then
        print("Unlimited Armor: Set to 1337")
    end
end

-- Provide unlimited grenades
local function unlimited_grenades()
    local localPlayer = get_local_player()
    local playerGrenadesAddress = localPlayer + addresses.localPlayer.m_iGrenades
    if set_value_if_less(playerGrenadesAddress, 1337) then
        print("Unlimited Grenades: Set to 1337")
    end
end

-- Provide unlimited ammo for weapons
local function unlimited_ammo()
    local localPlayer = get_local_player()
    local ammoAddresses = {
        addresses.localPlayer.m_iTMPAmmo,
        addresses.localPlayer.m_iV19Ammo,
        addresses.localPlayer.m_iAARDAmmo,
        addresses.localPlayer.m_iAD81Ammo,
        addresses.localPlayer.m_iMTP57Ammo,
        addresses.localPlayer.m_iSecondaryAmmo
    }

    for _, address in ipairs(ammoAddresses) do
        if set_value_if_less(localPlayer + address, 1337) then
            print(("Unlimited Ammo: Set to 1337 at address 0x%X"):format(address))
        end
    end
end

local function draw_gui()
    local x = 2
    local y = 200

    render.text("Game module: " .. string.format("0x%X", addresses.game.module), vec2.new(x, y), color.white, text_pos.LEFT)
    y = y + 17
    local localPlayer = memory.read_int(addresses.game.module + addresses.structures.localPlayer)
    render.text("Local player: " .. string.format("0x%X", localPlayer), vec2.new(x, y), color.white, text_pos.LEFT)
end

-- Main loop
func.add(function()
    initialize()

    if not hasInitialized then return end
    draw_gui()

    if key.is_held(0x70) then
        print("God mode activated")
        godmode()
    elseif key.is_held(0x71) then
        print("Unlimited Armor activated")
        unlimited_armor()
    elseif key.is_held(0x72) then
        print("Unlimited Ammo activated")
        unlimited_ammo()
    elseif key.is_held(0x73) then
        print("Unlimited Grenades activated")
        unlimited_grenades()
    end
end)
