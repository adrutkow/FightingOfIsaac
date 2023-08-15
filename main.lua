
local fighter = RegisterMod("Fighter", 1)
local game = Game()
local sprite = Sprite()
local state = 1
local isActionable = true
local player

local STATE = {
    IDLE = 1,
    WALKING = 2,
    PUNCH = 3,
    JUMP = 4,
    JUMPKICK = 5,
    FALLING = 6,
}

local ANIMATIONS = {
    "Idle",
    "WalkFwd",
    "Punch",
    "Jump",
    "JumpKick",
    "Falling",
}

local ANIMATION_ACTIONABLE = {
    true,
    true,
    false,
    true,
    false,
    false,
}

local ANIMATION_STOPVEL = {
    false,
    false,
    true,
    false,
    false,
    false
}

local ANIMATION_TRANSITIONS = {
    {-1},
    {-1},
    {},
    {5, 6},
    {1, 6},
    {1}
}


sprite:Load("kfm/kfm.anm2", true)

local function onGameStart()
    local level = game:GetLevel()
    player = game:GetPlayer(0)
    if level:GetCurrentRoomDesc().Data.Variant ~= 900 then
        Isaac.ExecuteCommand("goto d.900")
    end
end

---comment
---@param tear EntityTear
local function onFireTear(tear)
    

end

local function arrayHas(array, value)
    for i, v in ipairs(array) do
        if v == value then
            return true
        end
    end
    return false
end

local function numberIsBasicallyX(num, X)
    local epsilon = 0.1
    return (X - epsilon) < num and num < (X + epsilon)
end

local function isOnGround()
    return numberIsBasicallyX(player.Position.Y, 370)
end

local function isAnimationActionable(animationID)
    return ANIMATION_ACTIONABLE[animationID]
end

local function doesAnimationFreezeVel(animationID)
    return ANIMATION_STOPVEL[animationID]
end

local function getCurrentAnimation()
    return ANIMATIONS[state]
end

local function getCurrentState()
    return state
end

local function getAnimationByState(s)
    return ANIMATIONS[s]
end

local function makePlayerActionable()
    isActionable = true
end

local function makePlayerNotActionable()
    isActionable = false
end

local function isPlayerActionable()
    return isActionable
end

local function canStateTransitionInto(state0, state1)
    if ANIMATION_TRANSITIONS[state0][1] == -1 then
        return true
    end
    if arrayHas(ANIMATION_TRANSITIONS[state0], state1) then
        return true
    end
    return false
end

local function onStateChange()
    if state == STATE.JUMP then
        fighter:jump()
    end
end

local function changeState(newState)
    state = newState
    if not isAnimationActionable(state) then
        makePlayerNotActionable()
    else
        makePlayerActionable()
    end
    onStateChange()
end

local function TryChangeState(newState)
    local oldState = state
    if canStateTransitionInto(state, newState) then
        changeState(newState)
    end
end

function fighter:jump()
    if not isPlayerActionable() then
        player.Velocity.Y = 0
        return
    end

    if not isOnGround() then
        return
    end 

    player:AddVelocity(Vector(0, -5))
end


local function playAnimation(animationName)
    local forceAnimation = animationName ~= sprite:GetAnimation()
    sprite:Play(animationName, forceAnimation)
end



local function inputManager()

    if Input.IsActionTriggered(ButtonAction.ACTION_UP, 0) then
        TryChangeState(STATE.JUMP)
        return
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, 0) then
        if isOnGround() then
            TryChangeState(STATE.PUNCH)
        else
            TryChangeState(STATE.JUMPKICK)
        end
        return
    end

    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, 0) then
        if isOnGround() then
            TryChangeState(STATE.WALKING)
        end
        return
    end

    if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, 0) then
        if isOnGround() then
            TryChangeState(STATE.WALKING)
        end
        return
    end
end

local function stateManager()
    if player.Velocity.Y >= 0 then
        if isOnGround() and (getCurrentState() == STATE.JUMP or getCurrentState() == STATE.JUMPKICK) then
            changeState(STATE.IDLE)
        end
    end

    if numberIsBasicallyX(player.Velocity.X, 0) and getCurrentState() == STATE.WALKING then
        changeState(STATE.IDLE)
    end
end

local function checkAnimationFinish()

    local currentAnimIsActionable = ANIMATION_ACTIONABLE[getCurrentState()]

    if sprite:IsFinished(getCurrentAnimation()) and not currentAnimIsActionable then
        makePlayerActionable()
        changeState(STATE.IDLE)
    end
end

local function animationManager()

    checkAnimationFinish()
    stateManager()
    playAnimation(getCurrentAnimation())

    local pos = Isaac.WorldToScreen(player.Position)
    sprite:Render(pos)
    sprite:Update()
end


---comment
---@param entity Entity
---@param hook InputHook
---@param but ButtonAction
---@return boolean
function fighter:blockShot(entity, hook, but)
    if (true and (but == ButtonAction.ACTION_SHOOTUP or but == ButtonAction.ACTION_SHOOTLEFT or but == ButtonAction.ACTION_SHOOTRIGHT or but == ButtonAction.ACTION_SHOOTDOWN)) then
        return false;
    end
end

---comment
---@param entity Entity
---@param hook InputHook
---@param but ButtonAction
---@return float
function fighter:blockMovement(entity, hook, but)
    if isPlayerActionable() then 
        return
    end
    if (but == ButtonAction.ACTION_LEFT or but == ButtonAction.ACTION_RIGHT or but == ButtonAction.ACTION_UP) then
        return 0;
    end
end


local function onPlayerInit()
    local p = Isaac.GetPlayer(0)
    p:GetSprite().Color = Color(255, 255, 255, 0)
end


local function debugText()
    local str = ""

    str = str .. "isGround" .. tostring(isOnGround()) .. "\n"
    str = str .. "isActionable" .. tostring(isPlayerActionable()) .. "\n"
    str = str .. "currentState" .. getAnimationByState(getCurrentState()) .. "\n"


    Isaac.RenderText(str, 50, 50, 255, 255, 255, 255)
end

local function onTick()
    inputManager()
    animationManager()
    debugText()
end

local function onPostRender()
    onTick()
end






fighter:AddCallback(ModCallbacks.MC_POST_PLAYER_INIT, onPlayerInit, player)
fighter:AddCallback(ModCallbacks.MC_POST_NEW_ROOM, onGameStart)
fighter:AddCallback(ModCallbacks.MC_POST_FIRE_TEAR, onFireTear)
fighter:AddCallback(ModCallbacks.MC_POST_RENDER, onPostRender)
fighter:AddCallback(ModCallbacks.MC_INPUT_ACTION, fighter.blockMovement, InputHook.GET_ACTION_VALUE)
fighter:AddCallback(ModCallbacks.MC_INPUT_ACTION, fighter.blockShot, InputHook.IS_ACTION_PRESSED)

