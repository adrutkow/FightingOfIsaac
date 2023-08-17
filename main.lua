
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

local function onGameStart()
    PlayerID = 0

end

local function onNewRoom()
    local level = game:GetLevel()
    level:SetStage(LevelStage.STAGE1_2, StageType.STAGETYPE_ORIGINAL)
    Game():Spawn(EntityType.ENTITY_PLAYER, 2, Vector(100,100), Vector(0,0), nil, 0, 0)
    if level:GetCurrentRoomDesc().Data.Variant ~= 900 and level:GetCurrentRoomIndex() ~= level:GetStartingRoomIndex() then
        Isaac.ExecuteCommand("goto d.900")
    end
end


local function onPlayerInit()
    local p = Isaac.GetPlayer(PlayerID)
    p:GetSprite().Color = Color(255, 255, 255, 0)
    local f = Fighter:new(p)
    table.insert(Fighters, f)
end


local function debugText()
    -- local fighter0 = Fighters[1]
    -- local str = ""
    -- str = str .. "isGround" .. tostring(fighter0:isOnGround()) .. "\n"
    -- str = str .. "isActionable" .. tostring(fighter0:isPlayerActionable()) .. "\n"
    -- str = str .. "currentState" .. GetAnimationByState(fighter0:getCurrentState()) .. "\n"
    -- Isaac.RenderText(str, 50, 50, 255, 255, 255, 255)
end

local function onTick()
    for i = 1, #Fighters do
        Fighters[i]:inputManager()
        Fighters[i]:animationManager()
    end
    debugText()
end

local function onPostRender()
    onTick()
end




---comment
---@param entity Entity
---@param hook InputHook
---@param but ButtonAction
function BlockMovementTest(entity, hook, but)

    if entity ~= nil then
        print("WOW!!")
        print(entity["Name"])
        print(entity.Type)
        getTableKeys(entity)
    end
    if entity.Type == EntityType.ENTITY_PLAYER then
        print("VALID")
        local id = Utils.getPlayerID(entity:ToPlayer())
        return Fighters[id + 1]:blockMovement(entity, hook, but)
    end
    
end







FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)
FighterMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)
FighterMod:AddCallback(ModCallbacks.MC_POST_RENDER, onPostRender)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockMovement, InputHook.GET_ACTION_VALUE)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockShot, InputHook.IS_ACTION_PRESSED)
FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FighterMod.testfunc)
FighterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStart)


