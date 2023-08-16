Fighter = {}
PlayerID = 0

function Fighter:new(player)
    local sprite = Sprite()
    sprite:Load("kfm/kfm.anm2", true)
    local newObj = {
        index = #Fighters + 1,
        player = player,
        sprite = sprite,
        isActionable = true,
        state = 1,
        playerID = PlayerID
    }

    local function blockMovementCallback(entity, hook, but)
        return self:blockMovement(entity, hook, but)
    end

    self.__index = self
    PlayerID = PlayerID + 1
    --FighterMod:AddCallback(ModCallbacks.MC_INPUT_ACTION, blockMovementCallback, InputHook.GET_ACTION_VALUE)
    print(PlayerID)
    return setmetatable(newObj, self)
end

function Fighter:inputManager()

    local controllerID = self.playerID

    if Input.IsActionTriggered(ButtonAction.ACTION_UP, controllerID) then
        --print("JUMP")
        self:TryChangeState(STATE.JUMP)
        return
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, controllerID) then
        if self:isOnGround() then
            self:TryChangeState(STATE.PUNCH)
        else
            self:TryChangeState(STATE.JUMPKICK)
        end
        return
    end

    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, controllerID) then
        if self:isOnGround() then
            self:TryChangeState(STATE.WALKING)
        end
        return
    end

    if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, controllerID) then
        if self:isOnGround() then
            self:TryChangeState(STATE.WALKING)
        end
        return
    end
end

function Fighter:draw()
    self.sprite:Render(Vector(self.x, self.y))
    self.sprite:Update()
end

function Fighter:jump()
    if not self:isPlayerActionable() then
        self.player.Velocity.Y = 0
        return
    end

    if not self:isOnGround() then
        return
    end 

    self.player:AddVelocity(Vector(0, -5))
end

function Fighter:isPlayerActionable()
    return self.isActionable
end

function Fighter:isOnGround()
    return Utils:numberIsBasicallyX(self.player.Position.Y, 370)
end

function CanStateTransitionInto(state0, state1)

    --print(GetAnimationByState(state0) .. "into " .. GetAnimationByState(state1))

    if ANIMATION_TRANSITIONS[state0][1] == -1 then
        return true
    end
    if Utils:arrayHas(ANIMATION_TRANSITIONS[state0], state1) then
        return true
    end
    return false
end

function Fighter:changeState(newState)
    self.state = newState
    if not self:isAnimationActionable(self.state) then
        self:makePlayerNotActionable()
    else
        self:makePlayerActionable()
    end
    self:onStateChange()
end

function Fighter:onStateChange()
    if self.state == STATE.JUMP then
        self:jump()
    end

    if self.state == STATE.PUNCH then
        
        local pos = Isaac.WorldToScreen(self.player.Position)
        local t = Isaac.Spawn(EntityType.ENTITY_TEAR, ProjectileVariant.PROJECTILE_COIN, 0, pos, Vector.Zero, nil)
        t:GetData()
    end
end

function Fighter:makePlayerActionable()
    self.isActionable = true
end

function Fighter:makePlayerNotActionable()
    self.isActionable = false
end

function Fighter:TryChangeState(newState)
    if CanStateTransitionInto(self.state, newState) then
        self:changeState(newState)
    end
end

function Fighter:playAnimation(animationName)
    local forceAnimation = animationName ~= self.sprite:GetAnimation()
    self.sprite:Play(animationName, forceAnimation)
end

function Fighter:isAnimationActionable(animationID)
    return ANIMATION_ACTIONABLE[animationID]
end

function Fighter:doesAnimationFreezeVel(animationID)
    return ANIMATION_STOPVEL[animationID]
end

function Fighter:getCurrentAnimation()
    return ANIMATIONS[self.state]
end

function Fighter:getCurrentState()
    return self.state
end

function GetAnimationByState(s)
    return ANIMATIONS[s]
end

function Fighter:stateManager()
    if self.player.Velocity.Y >= 0 then
        if self:isOnGround() and (self:getCurrentState() == STATE.JUMP or self:getCurrentState() == STATE.JUMPKICK or self:getCurrentState() == STATE.FALLING) then
            self:changeState(STATE.IDLE)
        end
    end

    if Utils:numberIsBasicallyX(self.player.Velocity.X, 0) and self:getCurrentState() == STATE.WALKING then
        self:changeState(STATE.IDLE)
    end
end

function Fighter:checkAnimationFinish()

    local currentAnimIsActionable = ANIMATION_ACTIONABLE[self:getCurrentState()]

    if self.sprite:IsFinished(GetAnimationByState(STATE.JUMP)) or self.sprite:IsFinished(GetAnimationByState(STATE.JUMPKICK)) then
        self:changeState(STATE.FALLING)
    end

    if self.sprite:IsFinished(self:getCurrentAnimation()) and not currentAnimIsActionable then
        self:makePlayerActionable()
        self:changeState(STATE.IDLE)
    end
end

function Fighter:animationManager()

    self:checkAnimationFinish()
    self:stateManager()
    self:playAnimation(self:getCurrentAnimation())
    local pos = Isaac.WorldToScreen(self.player.Position)

    if self:isPlayerActionable() then
        if self:getOtherFighter() ~= nil then
            if self:getOtherFighter().player.Position.X < self.player.Position.X then
                self.sprite.FlipX = true
            else
                self.sprite.FlipX = false
            end
        end
    end


    self.sprite:Render(pos)
    self.sprite:Update()

    -- hitboxSprite:Render(pos)
    -- hitboxSprite.Scale = Vector(4, 2)
    -- hitboxSprite:Render(pos + Vector(15, 10))
    -- hitboxSprite:Play("Idle")
    -- hitboxSprite:Update()
end

function Fighter:getOtherFighter()
    for i = 1, #Fighters do
        if i ~= self.index then
            return Fighters[i]
        end
    end
end

---comment
---@param entity Entity
---@param hook InputHook
---@param but ButtonAction
---@return float
function Fighter:blockMovement(entity, hook, but)

    if entity == nil then
        return
    end

    local player = entity:ToPlayer()
    if player == nil then
        return
    end

    local fighter = Fighters[player.ControllerIndex + 1]

    if fighter:isPlayerActionable() then 
        return
    end

    if (but == ButtonAction.ACTION_LEFT or but == ButtonAction.ACTION_RIGHT or but == ButtonAction.ACTION_UP) then
        return 0;
    end
end

function Fighter:blockMovement1(entity, hook, but)
    local index = 2
    local fighter = Fighters[index]
    if fighter == nil then
        return
    end


    if fighter:isPlayerActionable() then 
        return
    end
    if (but == ButtonAction.ACTION_LEFT or but == ButtonAction.ACTION_RIGHT or but == ButtonAction.ACTION_UP) then
        return 0;
    end
end



---comment
---@param entity Entity
---@param hook InputHook
---@param but ButtonAction
---@return boolean
function Fighter:blockShot(entity, hook, but)
    if (true and (but == ButtonAction.ACTION_SHOOTUP or but == ButtonAction.ACTION_SHOOTLEFT or but == ButtonAction.ACTION_SHOOTRIGHT or but == ButtonAction.ACTION_SHOOTDOWN)) then
        return false;
    end
end

return Fighter