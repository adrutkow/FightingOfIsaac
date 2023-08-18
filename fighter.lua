Fighter = {}

function Fighter:new(player)
    local sprite = Sprite()
    sprite:Load("kfm/kfm.anm2", true)
    local newObj = {
        index = #Fighters + 1,
        player = player,
        sprite = sprite,
        isActionable = true,
        state = 1,
        hurtboxes = {},
        hitboxes = {},
        gotHitThisFrame = false,
        hitstunFrames = 0,
        blockstunFrames = 0,
    }

    self.__index = self
    return setmetatable(newObj, self)
end

function Fighter:inputManager()
    if self.player == nil then
        return
    end

    local controllerID = self.player.ControllerIndex

    if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, controllerID) then
        SHOW_HITBOXES = not SHOW_HITBOXES
    end

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

function Fighter:isBlocking()
    if self.hitstunFrames > 0 then
        return false
    end
    local controllerID = self.player.ControllerIndex
    print(controllerID)
    if (Input.IsActionPressed(ButtonAction.ACTION_LEFT, controllerID) and self:isFacingRight() or
        Input.IsActionPressed(ButtonAction.ACTION_RIGHT, controllerID) and not self:isFacingRight()) then
            return true
    end
    return false
end

function Fighter:block()
    self:changeState(STATE.BLOCK)
    self.blockstunFrames = 16
end

function Fighter:onStateChange()

    if self.state == STATE.GETHIT then
        self.sprite:Play(GetAnimationByState(STATE.GETHIT), true)
    end

    if self.state == STATE.JUMP then
        self:jump()
    end

    -- TODO: temp fix?
    if self.state == STATE.IDLE then
        self.hitboxes = {}
        self.hurtboxes = {}
        self:addHitbox(HITBOXES.Hitbox_Idle)
    end

    -- TODO: temp fix.
    if self.state == STATE.GETHIT then
        self:addHitbox(HITBOXES.Hitbox_Idle)
    end

    if self.state == STATE.FALLING then
        self.hitboxes = {}
        self.hurtboxes = {}
        self:addHitbox(HITBOXES.Hitbox_Idle)
    end

    if self.state == STATE.BLOCK then
        self.hitboxes = {}
        self.hurtboxes = {}
        self:addHitbox(HITBOXES.Hitbox_Idle)
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

    if self.hitstunFrames > 0 then 
        return
    end

    if self.blockstunFrames > 0 then
        return
    end

    if self.blockstunFrames == 0 then
        if self:getCurrentState() == STATE.BLOCK then
            self:changeState(STATE.IDLE)
        end
    end

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

    if self.sprite:IsFinished(GetAnimationByState(STATE.GETHIT)) then
        if self.hitstunFrames > 0 then
            return
        end
    end

    if self.sprite:IsFinished(GetAnimationByState(STATE.BLOCK)) then
        if self.blockstunFrames > 0 then
            print(self.blockstunFrames)
            return
        end
    end

    if self.sprite:IsFinished(GetAnimationByState(STATE.JUMP)) or self.sprite:IsFinished(GetAnimationByState(STATE.JUMPKICK)) then
        self:changeState(STATE.FALLING)
    end

    if self.sprite:IsFinished(self:getCurrentAnimation()) and not currentAnimIsActionable then
        self:makePlayerActionable()
        self:changeState(STATE.IDLE)
    end

end

function Fighter:isFacingRight()
    if self:getOtherFighter() ~= nil then
        if self:getOtherFighter().player.Position.X < self.player.Position.X then
            return false
        else
            return true
        end
    end
end


function Fighter:animationManager()
    
    if self.hitstunFrames > 0 then
        self.hitstunFrames = self.hitstunFrames - 1
    end

    if self.blockstunFrames > 0 then
        self.blockstunFrames = self.blockstunFrames - 1
    end

    self:checkAnimationFinish()
    self:stateManager()
    self:playAnimation(self:getCurrentAnimation())
    local pos = Isaac.WorldToScreen(self.player.Position)

    if self:isPlayerActionable() then
        self.sprite.FlipX = not self:isFacingRight()
    end

    self.sprite:Render(pos)
    self.sprite:Update()

    for i = 1, #self.hitboxes do
        self.hitboxes[i]:draw()
    end

    for i = 1, #self.hurtboxes do
        self.hurtboxes[i]:draw()
    end


    -- hitboxSprite:Render(pos)
    -- hitboxSprite.Scale = Vector(4, 2)
    -- hitboxSprite:Render(pos + Vector(15, 10))
    -- hitboxSprite:Play("Idle")
    -- hitboxSprite:Update()
end

function Fighter:animationTriggers()
    if self.sprite:IsEventTriggered("Hurtbox_Punch") then
        self:addHitbox(HITBOXES.Hurtbox_Punch)
    end

    if self.sprite:IsEventTriggered("Hurtbox_END") then
        self.hurtboxes = {}
    end

    if self.sprite:IsEventTriggered("Hitbox_Idle") then
        self.hitboxes = {}
        self:addHitbox(HITBOXES.Hitbox_Idle)
    end

    if self.sprite:IsEventTriggered("Hitbox_JumpKick_0") then
        self.hitboxes = {}
        self:addHitbox(HITBOXES.Hitbox_JumpKick_0)
    end

    if self.sprite:IsEventTriggered("Hitbox_JumpKick_1") then
        self.hitboxes = {}
        self.hurtboxes = {}
        self:addHitbox(HITBOXES.Hitbox_JumpKick_1)
        self:addHitbox(HITBOXES.Hurtbox_JumpKick)
    end

    if self.sprite:IsEventTriggered("Hurtbox_JumpKick") then
        self.hurtboxes = {}
        self:addHitbox(HITBOXES.Hurtbox_JumpKick)
    end
end

function Fighter:getOtherFighter()
    for i = 1, #Fighters do
        if Fighters[i].index ~= self.index then
            return Fighters[i]
        end
    end
end


function Fighter:addHitbox(HITBOX)
    local rect = {HITBOXES_DATA_RECT[HITBOX][1], HITBOXES_DATA_RECT[HITBOX][2], HITBOXES_DATA_RECT[HITBOX][3], HITBOXES_DATA_RECT[HITBOX][4]}
    if self.sprite.FlipX == true then
        rect[1] = -rect[1] - rect[3]
    end

    local hitbox = Hitbox:new(rect, self.player, HITBOXES_DATA_ATTACHED[HITBOX], HITBOXES_DATA_ISHURTBOX[HITBOX])

    if HITBOXES_DATA_ISHURTBOX[HITBOX] == true then
        table.insert(self.hurtboxes, hitbox)
    else
        table.insert(self.hitboxes, hitbox)
    end
end

function Fighter:getHit()
    self.hurtboxes = {}
    self.hitboxes = {}
    self:changeState(STATE.GETHIT)
    self.hitstunFrames = 30
end

function Fighter:CheckIfHitEnemy()
    local otherFighter = self:getOtherFighter()
    if otherFighter == nil then
        return
    end
    for i = 1, #self.hurtboxes do
        for j = 1, #otherFighter.hitboxes do
            local rect1 = self.hurtboxes[i]:getWorldRect()
            local rect2 = otherFighter.hitboxes[j]:getWorldRect()

            if RectCollide(rect1, rect2) then
                otherFighter.gotHitThisFrame = true
                self.hurtboxes = {}
                return
            end
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