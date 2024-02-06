Data = {}

STATE = {
    IDLE = 1,
    WALKING = 2,
    PUNCH = 3,
    JUMP = 4,
    JUMPKICK = 5,
    FALLING = 6,
    GETHIT = 7,
    BLOCK = 8,
    UPPERCUT = 9,
    FREEFALLUP = 10,
    FREEFALLDOWN = 11,
    GROUND = 12,
    RECOVER = 13,
    CROUCH = 14,
    CROUCHKICK = 15,
    CROUCHBLOCK = 16,

}

local stateCount = 0
for _ in pairs(STATE) do
    stateCount = stateCount + 1
end

STATE_DATA = {}

for i = 1, stateCount do
    STATE_DATA[i] = {
        animation = "Idle", -- Animation name in the sprite editor
        actionable = true, -- Can the character move/attack during this state
        stopVelocity = false, -- Does this state stop any velocity the character has
        transitions = {-1}, -- Which states can this state transition into, -1 means all of them
        hitTransitions = {}, -- Which states can this state transition into when the player hits the opponent
        hitboxes = {
            {
                rect = {-12, 0, 25, 100},
                attached = true,
                isHurtbox = true,
                frameStart = -1, -- Which frame the hitbox starts, -1 ignores it
                frameEnd = -1, -- Which frame does the hitbox end, -1 ignores it
                eventTrigger = "", -- Which event in the animation triggers this hitbox, empty string ignores it
                stopTrigger = "", -- Which event kills the hitbox, empty string ignores it
                hitVelocity = Vector(0, 0), -- Velocity to apply to opponent when he gets hit
                recoilVelocity = Vector(0, 0), -- Velocity to apply to attacker on opponent blocking the attack
            }
        }
    }
end

STATE_DATA[STATE.IDLE] = {
    animation = "Idle",
    actionable = true,
    stopVelocity = false,
    transitions = {-1},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.WALKING] = {
    animation = "WalkFwd",
    actionable = true,
    stopVelocity = false,
    transitions = {-1},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.PUNCH] = {
    animation = "Punch",
    actionable = false,
    stopVelocity = true,
    transitions = {},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
        {
            rect = {0, -60, 64, 28},
            attached = true,
            isHurtbox = false,
            eventTrigger = "HITBOX1_START",
            stopTrigger = "HITBOX1_END",
        },
        {
            rect = {0, -60, 48, 32},
            attached = true,
            isHurtbox = true,
            eventTrigger = "HITBOX1_START",
            stopTrigger = "HITBOX1_END",
        }
    }
}

STATE_DATA[STATE.JUMP] = {
    animation = "Jump",
    actionable = true,
    stopVelocity = false,
    transitions = {5, 6},
    hitboxes = {
        {
            rect = {-12, -30, 25, 60},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.JUMPKICK] = {
    animation = "JumpKick",
    actionable = false,
    stopVelocity = false,
    transitions = {1, 6},
    hitboxes = {
        {
            rect = {-12, -30, 25, 60},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
        {
            rect = {-12, -30, 80, 60},
            attached = true,
            isHurtbox = true,
            eventTrigger = "HITBOX1_START",
        },
        {
            rect = {-12, -30, 70, 50},
            attached = true,
            isHurtbox = false,
            eventTrigger = "HITBOX1_START",
            stopTrigger = "HITBOX1_END",
        }

    }
}

STATE_DATA[STATE.FALLING] = {
    animation = "Falling",
    actionable = true,
    stopVelocity = false,
    transitions = {-1},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.GETHIT] = {
    animation = "GetHit",
    actionable = false,
    stopVelocity = false,
    transitions = {},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.BLOCK] = {
    animation = "Block",
    actionable = false,
    stopVelocity = false,
    transitions = {},
    hitboxes = {
        {
            rect = {0, -40, 60, 30},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.UPPERCUT] = {
    animation = "Uppercut",
    actionable = false,
    stopVelocity = true,
    transitions = {},
    hitTransitions = {STATE.JUMP},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
        {
            rect = {0, -60, 32, 60},
            attached = true,
            isHurtbox = false,
            eventTrigger = "HITBOX1_START",
            stopTrigger = "HITBOX1_END",
            hitVelocity = Vector(2, -5),
        }
    }
}

STATE_DATA[STATE.FREEFALLUP] = {
    animation = "FreeFallUp",
    actionable = false,
    stopVelocity = false,
    transitions = {},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.FREEFALLDOWN] = {
    animation = "FreeFallDown",
    actionable = false,
    stopVelocity = false,
    transitions = {},
    hitboxes = {
        {
            rect = {-12, 0, 25, 100},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.GROUND] = {
    animation = "Ground",
    actionable = false,
    stopVelocity = false,
    transitions = {STATE.RECOVER},
}

STATE_DATA[STATE.RECOVER] = {
    animation = "Recover",
    actionable = false,
    stopVelocity = false,
    transitions = {STATE.IDLE},
}

STATE_DATA[STATE.CROUCH] = {
    animation = "Crouch",
    actionable = false,
    stopVelocity = false,
    transitions = {STATE.IDLE, STATE.CROUCHKICK},
    hitboxes = {
        {
            rect = {-12, 0, 25, 72},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

STATE_DATA[STATE.CROUCHKICK] = {
    animation = "CrouchKick",
    actionable = false,
    stopVelocity = true,
    transitions = {},
    hitboxes = {
        {
            rect = {-35, 0, 35, 58},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
        {
            rect = {-35, 0, 90, 20},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
        {
            rect = {8, 0, 45, 15},
            attached = true,
            isHurtbox = false,
            eventTrigger = "HITBOX1_START",
            stopTrigger = "HITBOX1_END",
        },
    }
}

STATE_DATA[STATE.CROUCHBLOCK] = {
    animation = "CrouchBlock",
    actionable = false,
    stopVelocity = false,
    transitions = {},
    hitboxes = {
        {
            rect = {-15, 0, 35, 60},
            attached = true,
            isHurtbox = true,
            frameStart = 0,
        },
    }
}

return Data