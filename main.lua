FighterMod = RegisterMod("Fighter", 1)
local Hitbox = require("hitbox")
local Fighter = require("fighter")
local Data = require("data")
local Utils = require("utils")
local game = Game()
Fighters = {}
SHOW_HITBOXES = true

local function onGameStart()
end
-- test
local function onNewRoom()

    print("NEW ROOM")

    local level = game:GetLevel()
    level:SetStage(LevelStage.STAGE1_2, StageType.STAGETYPE_ORIGINAL)
    Game():Spawn(EntityType.ENTITY_PLAYER, 2, Vector(100,100), Vector(0,0), nil, 0, 0)
    if level:GetCurrentRoomDesc().Data.Variant ~= 900 and level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() then
        Isaac.ExecuteCommand("goto d.900")
    end

    Isaac.GetPlayer(0).Position = Vector(200, 350)
    if Isaac.GetPlayer(1) ~= nil then
        Isaac.GetPlayer(1).Position = Vector(400, 350)
    end

end


local function addFighterToGame(entityPlayer)
    local newFighter = Fighter:new(entityPlayer)
    table.insert(Fighters, newFighter)
    if entityPlayer ~= nil then
        entityPlayer:GetSprite().Color = Color(255, 255, 255, 0)
    end
    newFighter.sprite:Play("Idle")
    return newFighter
end

local function startGame()
    for i in pairs(Fighters) do
        Fighters[i] = nil
    end
    Isaac.ExecuteCommand("goto d.900")


    for i = 1, Isaac.CountEntities(nil, EntityType.ENTITY_PLAYER) do
        addFighterToGame(Isaac.GetPlayer(i - 1))
    end

    local mainPlayerIndex = Isaac.GetPlayer(0).Index


    -- if #Fighters > 1 then
    --     for i = 2, #Fighters do
    --         Fighters[i].isDummy = true
    --     end
    -- end

end

---comment
---@param entityPlayer EntityPlayer
local function onPlayerInit(entityPlayer)
    -- if entityPlayer == nil then
    --     addFighterToGame()
    -- else
    --     addFighterToGame(Isaac.GetPlayer(Game():GetNumPlayers() - 1))
    -- end

end

local function debugText()
    local fighter0 = Fighters[1]
    local str = ""
    -- str = str .. "isGround" .. tostring(fighter0:isOnGround()) .. "\n"
    -- str = str .. "isActionable" .. tostring(fighter0:isPlayerActionable()) .. "\n"
    -- str = str .. "currentState" .. GetAnimationByState(fighter0:getCurrentState()) .. "\n"
    Isaac.RenderText(str, 50, 50, 255, 255, 255, 255)
end

local function onTick()
    for i = 1, #Fighters do
        Fighters[i]:nextFrame()
        Fighters[i]:inputManager()
        Fighters[i]:stateManager()
        Fighters[i]:animationTriggers()
        Fighters[i]:countCombo()
        Fighters[i]:render()

        Fighters[i].sprite.Color = Color.Default
    end

    for i = 1, #Fighters do
        Fighters[i]:CheckIfHitEnemy()
    end

    for i = 1, #Fighters do
        -- if Fighters[i].gotHitThisFrame == true then
        if Fighters[i].hitboxHitByThisFrame then
            if Fighters[i]:isBlocking() then
                Fighters[i]:block()
            else
                Fighters[i]:getHit()
                Fighters[i]:animationTriggers()
            end
            -- Fighters[i].gotHitThisFrame = false
            Fighters[i].hitboxHitByThisFrame = nil
        end

        -- if Fighters[i].isDummy then
        --     Fighters[i].player.Velocity = Vector(0, 10)
        -- end
        
        if Fighters[1] ~= nil then
            Isaac.RenderText("Combo: " .. Fighters[1].comboCount, 350, 30, 1, 1, 1, 255)
        end

        if Fighters[2] ~= nil then
            Isaac.RenderText("Combo: " .. Fighters[2].comboCount, 50, 30, 1, 1, 1, 255)
        end


    end

    --debugText()
    if Input.IsActionTriggered(ButtonAction.ACTION_BOMB, 0) then
        startGame()
    end
end

local function onPostRender()
    onTick()
end

function FighterMod:debug()
    print("TEST")
end

FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)
FighterMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)
FighterMod:AddCallback(ModCallbacks.MC_POST_RENDER, onPostRender)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockMovement, InputHook.GET_ACTION_VALUE)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockShot, InputHook.IS_ACTION_PRESSED)
FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FighterMod.testfunc)
FighterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStart)

