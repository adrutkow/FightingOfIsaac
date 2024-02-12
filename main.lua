FighterMod = RegisterMod("Fighter", 1)
require("healthbar")
local Hitbox = require("hitbox")
local Fighter = require("fighter")
local Data = require("data")
local Utils = require("utils")
local game = Game()
Fighters = {}
UIElements = {}
SHOW_HITBOXES = false
SLOWDOWN = false
BG_SPRITE = nil
BG_SPRITE2 = nil
BLACKBAR1 = nil
BLACKBAR2 = nil
STAGEY = 275

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

    Isaac.GetPlayer(0).Position = Vector(480, 650)
    if Isaac.GetPlayer(1) ~= nil then
        Isaac.GetPlayer(1).Position = Vector(680, 650)
    end

    BG_SPRITE = Sprite()
    BG_SPRITE:Load("images/background.anm2", true)
    BG_SPRITE:Play("Idle")

    BG_SPRITE2 = Sprite()
    BG_SPRITE2:Load("images/background2.anm2", true)
    BG_SPRITE2:Play("Idle")

    BLACKBAR1 = Sprite()
    BLACKBAR1:Load("images/blackbar.anm2", true)
    BLACKBAR1:Play("Idle")

    BLACKBAR2 = Sprite()
    BLACKBAR2:Load("images/blackbar.anm2", true)
    BLACKBAR2:Play("Idle")
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

local function initUI()
    Game():GetHUD():SetVisible(false)
    UIElements = {}
    for i = 1, 2 do
        local newHealthBar = HealthBar:new(i)
        table.insert(UIElements, newHealthBar)
    end
end

local function startGame()
    for i in pairs(Fighters) do
        Fighters[i] = nil
    end
    Isaac.ExecuteCommand("goto d.900")

    if Isaac.CountEntities(nil, EntityType.ENTITY_PLAYER) == 1 then
        Isaac.ExecuteCommand("addplayer 1 0")
    end

    for i = 1, Isaac.CountEntities(nil, EntityType.ENTITY_PLAYER) do
        addFighterToGame(Isaac.GetPlayer(i - 1))
    end

    if #Fighters > 1 then
        if Fighters[2].player.ControllerIndex == 0 then
            Fighters[2].isDummy = true
        end
    end


    initUI()
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

    local room = Game():GetRoom()
    local offset = room:GetRenderScrollOffset()




    BG_SPRITE2:Render(Vector(0, 225) + offset / 8)
    BG_SPRITE2:Update()

    BG_SPRITE:Render(Vector(0, 425) + offset)
    BG_SPRITE:Update()

    BLACKBAR1:Render(Vector(0, 275))
    BLACKBAR1:Update()

    BLACKBAR2:Render(Vector(0, 0))
    BLACKBAR2:Update()

    Isaac.RenderText("IsaacFighter", 200, 250, 1, 1, 1, 255)



    for i = 1, #Fighters do
        local skipFrame = false
        if SLOWDOWN then
            if Isaac.GetFrameCount() % 2 == 0 then
                skipFrame = true
            end
        end

        if not skipFrame then 
            Fighters[i]:nextFrame()
        end
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

    for i = 1, #UIElements do
        UIElements[i]:draw()
    end

    if Fighters[1] ~= nil then
        Isaac.RenderText("Combo: " .. Fighters[1].comboCount, 370, 30, 1, 1, 1, 255)
    end

    if Fighters[2] ~= nil then
        Isaac.RenderText("Combo: " .. Fighters[2].comboCount, 60, 30, 1, 1, 1, 255)
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
        



    end

    if SLOWDOWN then
        for i = 1, #Fighters do
            Fighters[i].player.Velocity = Vector( Fighters[i].player.Velocity.X / 2,  Fighters[i].player.Velocity.Y / 2)
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
    local newHealthBar = HealthBar:new()
    table.insert(UIElements, newHealthBar)
end





FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit)
FighterMod:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onNewRoom)
FighterMod:AddCallback(ModCallbacks.MC_POST_RENDER, onPostRender)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockMovement, InputHook.GET_ACTION_VALUE)
FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, Fighter.blockShot, InputHook.IS_ACTION_PRESSED)
FighterMod:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, FighterMod.testfunc)
FighterMod:AddCallback(ModCallbacks.MC_POST_GAME_STARTED, onGameStart)


