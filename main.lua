
FighterMod = RegisterMod("Fighter", 1)
local Hitbox = require("hitbox")
local Fighter = require("fighter")
local Data = require("data")
local Utils = require("utils")
local game = Game()
local sprite = Sprite()
local state = 1
local isActionable = true
Fighters = {}
SHOW_HITBOXES = true

local function onGameStart()
end

local function onNewRoom()
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

local function startGame()
    Isaac.ExecuteCommand("goto d.900")
end

local function addFighterToGame(entityPlayer)
    table.insert(Fighters, Fighter:new(entityPlayer))
    if entityPlayer ~= nil then
        entityPlayer:GetSprite().Color = Color(255, 255, 255, 0)
    end
end

---comment
---@param entityPlayer EntityPlayer
local function onPlayerInit(entityPlayer)
    if entityPlayer == nil then
        addFighterToGame()
    else
        addFighterToGame(Isaac.GetPlayer(Game():GetNumPlayers() - 1))
    end

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
        Fighters[i]:inputManager()
        Fighters[i]:animationTriggers()
        Fighters[i]:animationManager()
        Fighters[i]:CheckIfHitEnemy()
    end
    
    for i = 1, #Fighters do
        if Fighters[i].gotHitThisFrame == true then
            if Fighters[i]:isBlocking() then
                Fighters[i]:block()
            else
                Fighters[i]:getHit()
            end
            Fighters[i].gotHitThisFrame = false
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

FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)
FighterMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)
FighterMod:AddCallback(ModCallbacks.MC_POST_RENDER, onPostRender)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockMovement, InputHook.GET_ACTION_VALUE)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockShot, InputHook.IS_ACTION_PRESSED)
FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FighterMod.testfunc)
FighterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStart)


