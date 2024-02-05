require("data")
Fighter = {}


function Fighter:new(player)
    local sprite = Sprite()
    local charId = 0
    if player ~= nil then
        charId = player:GetPlayerType()
    end

    if charId == 0 then
        sprite:Load("kfm/kfm.anm2", true)
    end

    if charId == 1 then
        sprite:Load("sol/sol.anm2", true)
    end

    local newObj = {
        index = #Fighters + 1,
        player = player,
        sprite = sprite,
        isActionable = true,
        state = 1,
        hurtboxes = {},
        hitboxes = {},
        gotHitThisFrame = false,
        hitboxHitByThisFrame = nil,
        hitEnemyThisState = false,
        hitstunFrames = 0,
        blockstunFrames = 0,
        isDummy = false,
        comboCount = 0,
        health = 200,
    }

    self.__index = self
    return setmetatable(newObj, self)
end

function Fighter:nextFrame()
    self.sprite:Update()

    if self.hitstunFrames > 0 then
        self.hitstunFrames = self.hitstunFrames - 1
    end

    if self.blockstunFrames > 0 then
        self.blockstunFrames = self.blockstunFrames - 1
    end

    self:checkAnimationFinish()
end


function Fighter:inputManager()
    if self.player == nil then
        return
    end

    if self.isDummy then
        return
    end

    local controllerID = self.player.ControllerIndex

    if Input.IsActionTriggered(ButtonAction.ACTION_ITEM, controllerID) then
        SHOW_HITBOXES = not SHOW_HITBOXES
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_UP, controllerID) then
        self:tryChangeState(STATE.JUMP)
        return
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTRIGHT, controllerID) then
        if self:isOnGround() then
            self:tryChangeState(STATE.PUNCH)
        else
            self:tryChangeState(STATE.JUMPKICK)
        end
        return
    end

    if Input.IsActionTriggered(ButtonAction.ACTION_SHOOTLEFT, controllerID) then
        if self:isOnGround() then
            self:tryChangeState(STATE.UPPERCUT)
        else
            self:tryChangeState(STATE.JUMPKICK)
        end
        return
    end

    if Input.IsActionPressed(ButtonAction.ACTION_LEFT, controllerID) then
        if self:isOnGround() then
            self:tryChangeState(STATE.WALKING)
        end
        return
    end

    if Input.IsActionPressed(ButtonAction.ACTION_RIGHT, controllerID) then
        if self:isOnGround() then
            self:tryChangeState(STATE.WALKING)
        end
        return
    end
end


function Fighter:animationTriggers()

    if STATE_DATA[self:getCurrentState()].hitboxes == nil then
        return
    end

    for i = 1, #STATE_DATA[self:getCurrentState()].hitboxes do
        local hitboxTable = STATE_DATA[self:getCurrentState()].hitboxes[i]

        if self.sprite:IsEventTriggered("HITBOX1_START") then
            if hitboxTable.eventTrigger == "HITBOX1_START" then
                self:addHitbox(hitboxTable)
            end
        end

        if self.sprite:IsEventTriggered("HITBOX1_END") then
            if hitboxTable.stopTrigger == "HITBOX1_END" then
                print("END HITBOX TRIGGERED")
                self.hitboxes = {}
            end
        end

        if hitboxTable.frameStart ~= -1 then
            if hitboxTable.frameStart == self.sprite:GetFrame() then
                self:addHitbox(hitboxTable)
            end
        end
    end
end

function Fighter:countCombo()
    if self:isPlayerActionable() then
        self.comboCount = 0
    end
end

function Fighter:animationManager()
    --self:playAnimation(self:getCurrentAnimation())
    self:stateManager()

    -- hitboxSprite:Render(pos)
    -- hitboxSprite.Scale = Vector(4, 2)
    -- hitboxSprite:Render(pos + Vector(15, 10))
    -- hitboxSprite:Play("Idle")
    -- hitboxSprite:Update()
end

function Fighter:jump()
    if not self:isPlayerActionable() then
        self.player.Velocity.Y = 0
        return
    end

    if not self:isOnGround() then
        return
    end 

    -- self.player:AddVelocity(Vector(0, -5))
    self:applyVelocity(Vector(0, -5))
end

function Fighter:isPlayerActionable()
    return self.isActionable
end

function Fighter:isOnGround()
    --return Utils:numberIsBasicallyX(self.player.Position.Y, 370)
    return Utils:numberIsBasicallyX(self.player.Position.Y, 650)
end

function Fighter:canStateTransitionInto(state0, state1)

    if STATE_DATA[state0].hitTransitions ~= nil then
        if Utils:arrayHas(STATE_DATA[state0].hitTransitions, state1) and self.hitEnemyThisState then
            return true
        end
    end

    if STATE_DATA[state0].transitions[1] == -1 then
        return true
    end
    
    if Utils:arrayHas(STATE_DATA[state0].transitions, state1) then
        return true
    end

    return false
end

function Fighter:changeState(newState)
    self.state = newState
    if not self:isStateActionable(self.state) then
        self:makePlayerNotActionable()
    else
        self:makePlayerActionable()
    end
    self:onStateChange()
end

function Fighter:isBlocking()

    if self.isDummy then
        return false
    end

    if self.hitstunFrames > 0 then
        return false
    end
    local controllerID = self.player.ControllerIndex
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
    print("STATE CHANGED")
    self.hitboxes = {}
    self.hurtboxes = {}
    self.hitEnemyThisState = false

    if self.state == STATE.JUMP then
        self:jump()
    end

    self.sprite:Play(GetAnimationByState(self.state), true)
end

function Fighter:makePlayerActionable()
    self.isActionable = true
end

function Fighter:makePlayerNotActionable()
    self.isActionable = false
end

function Fighter:tryChangeState(newState)
    if self.state == newState then
        return false
    end
    if self:canStateTransitionInto(self.state, newState) then
        self:changeState(newState)
        return true
    end
end

function Fighter:playAnimation(animationName)
    local forceAnimation = animationName ~= self.sprite:GetAnimation()
    self.sprite:Play(animationName, forceAnimation)
end

function Fighter:isStateActionable(state)
    return STATE_DATA[state].actionable
end

function Fighter:doesAnimationFreezeVel(state)
    return STATE_DATA[state].stopVelocity
end

function Fighter:getCurrentAnimation()
    return STATE_DATA[self.state].animation
end

function Fighter:getCurrentState()
    return self.state
end

function GetAnimationByState(state)
    return STATE_DATA[state].animation
end

function Fighter:stateManager()

    local state = self:getCurrentState()
    
    if state == STATE.FREEFALLUP then
        if self.player.Velocity.Y >= 0 then
            self:changeState(STATE.FREEFALLDOWN)
        end
    end

    if state == STATE.FREEFALLDOWN and self:isOnGround() then
        self:changeState(STATE.GROUND)
    end

    if self.hitstunFrames > 0 then 
        if not self:isOnGround() and (state ~= STATE.FREEFALLUP and state ~= STATE.FREEFALLDOWN) then
            self:changeState(STATE.FREEFALLUP)
        end
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
        if self:isOnGround() and (state == STATE.JUMP or state == STATE.JUMPKICK or state == STATE.FALLING or state == STATE.FREEFALLUP) then
            self:changeState(STATE.IDLE)
        end
    end

    if Utils:numberIsBasicallyX(self.player.Velocity.X, 0) and self:getCurrentState() == STATE.WALKING then
        self:changeState(STATE.IDLE)
    end
end

function Fighter:checkAnimationFinish()

    local currentStateIsActionable = STATE_DATA[self:getCurrentState()].actionable

    if self.sprite:IsFinished(GetAnimationByState(STATE.GROUND)) then
        self:changeState(STATE.RECOVER)
    end

    if self.sprite:IsFinished(GetAnimationByState(STATE.RECOVER)) then
        self:changeState(STATE.IDLE)
    end

    if self.sprite:IsFinished(GetAnimationByState(STATE.GETHIT)) then
        if self.hitstunFrames > 0 then
            return
        end
    end

    if self.sprite:IsFinished(GetAnimationByState(STATE.BLOCK)) then
        if self.blockstunFrames > 0 then
            return
        end
    end

    if self.sprite:IsFinished(GetAnimationByState(STATE.JUMP)) or self.sprite:IsFinished(GetAnimationByState(STATE.JUMPKICK)) then
        self:changeState(STATE.FALLING)
    end

    if self.sprite:IsFinished(self:getCurrentAnimation()) and not currentStateIsActionable then
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
    else
        return true
    end
end


function Fighter:getOtherFighter()
    for i = 1, #Fighters do
        if Fighters[i].index ~= self.index then
            return Fighters[i]
        end
    end
end


function Fighter:addHitbox(hitboxTable)
    local rect = {table.unpack(hitboxTable.rect)}
    if self.sprite.FlipX == true then
        rect[1] = -rect[1] - rect[3]
    end

    local hitbox = Hitbox:new(rect, self.player, hitboxTable.attached, hitboxTable.isHurtbox)

    if hitboxTable.hitVelocity then
        hitbox.hitVelocity = hitboxTable.hitVelocity
    end

    if hitboxTable.recoilVelocity then
        hitbox.recoilVelocity = hitboxTable.recoilVelocity
    end

    if hitboxTable.isHurtbox == true then
        table.insert(self.hurtboxes, hitbox)
    else
        table.insert(self.hitboxes, hitbox)
    end
end

function Fighter:getHit()
    self.hurtboxes = {}
    self.hitboxes = {}
    self:changeState(STATE.GETHIT)
    self.health = self.health - 10

    if self.hitboxHitByThisFrame.hitVelocity then
        --self.player:AddVelocity(self.hitboxHitByThisFrame.hitVelocity)
        self:applyVelocity(self.hitboxHitByThisFrame.hitVelocity)
    else
        if not self:isOnGround() then
            self:setVelocity(0, 0)
            self:applyVelocity(Vector(1, -3))
        end
    end

    self.sprite.Color = Color(255, 0, 0)
    self.comboCount = self.comboCount + 1
    self.hitstunFrames = 30
end

function Fighter:applyVelocity(vector)
    local finalVelX = vector.X
    local finalVelY = vector.Y

    if self:isFacingRight() then
        finalVelX = -vector.X
    end

    self.player:AddVelocity(Vector(finalVelX, finalVelY))
end

function Fighter:setVelocity(x, y)
    self.player.Velocity = Vector(x, y)
end

function Fighter:CheckIfHitEnemy()
    local otherFighter = self:getOtherFighter()
    if otherFighter == nil then
        return
    end
    for i = 1, #self.hitboxes do
        for j = 1, #otherFighter.hurtboxes do
            local rect1 = self.hitboxes[i]:getWorldRect()
            local rect2 = otherFighter.hurtboxes[j]:getWorldRect()

            if RectCollide(rect1, rect2) then
                -- otherFighter.gotHitThisFrame = true
                otherFighter.hitboxHitByThisFrame = self.hitboxes[i]
                self.hitEnemyThisState = true
                self.hitboxes = {}
                return
            end
        end
    end
end

function Fighter:render()
    local pos = Isaac.WorldToScreen(self.player.Position)

    if self:isPlayerActionable() then
        self.sprite.FlipX = not self:isFacingRight()
    end

    self.sprite:Render(pos)

    for i = 1, #self.hurtboxes do
        self.hurtboxes[i]:draw()
    end

    for i = 1, #self.hitboxes do
        self.hitboxes[i]:draw()
    end
end

function GetFighterByEntityIndex(index)
    for i = 1, #Fighters do
        if Fighters[i].player.Index == index then
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
    --local fighter = Fighters[player.ControllerIndex + 1]
    local fighter = GetFighterByEntityIndex(player.Index)

    -- if player then
    --     local playerIndex = player.Index
    -- end

    if fighter.isDummy then
        return 0
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