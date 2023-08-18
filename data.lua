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
}

ANIMATIONS = {
    "Idle",
    "WalkFwd",
    "Punch",
    "Jump",
    "JumpKick",
    "Falling",
    "GetHit",
    "Block"
}

ANIMATION_ACTIONABLE = {
    true,
    true,
    false,
    true,
    false,
    false,
    false,
    false,
}

ANIMATION_STOPVEL = {
    false,
    false,
    true,
    false,
    false,
    false,
    false,
    false,
}

ANIMATION_TRANSITIONS = {
    {-1},
    {-1},
    {},
    {5, 6},
    {1, 6},
    {1},
    {},
    {}
}

HITBOXES_DATA_RECT = {
    {-12, 0, 25, 100},
    {0, -60, 64, 28},
    {-12, -30, 25, 60},
    {-12, -30, 70, 50},
    {0, -40, 60, 30}
}

HITBOXES_DATA_ATTACHED = {
    true,
    true,
    true,
    true,
    true,

}

HITBOXES_DATA_ISHURTBOX = {
    false,
    true,
    false,
    false,
    true
}

HITBOXES = {
    Hitbox_Idle = 1,
    Hurtbox_Punch = 2,
    Hitbox_JumpKick_0 = 3,
    Hitbox_JumpKick_1 = 4,
    Hurtbox_JumpKick = 5,
}



return Data