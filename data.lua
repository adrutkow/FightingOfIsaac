Data = {}

STATE = {
    IDLE = 1,
    WALKING = 2,
    PUNCH = 3,
    JUMP = 4,
    JUMPKICK = 5,
    FALLING = 6,
}

ANIMATIONS = {
    "Idle",
    "WalkFwd",
    "Punch",
    "Jump",
    "JumpKick",
    "Falling",
}

ANIMATION_ACTIONABLE = {
    true,
    true,
    false,
    true,
    false,
    false,
}

ANIMATION_STOPVEL = {
    false,
    false,
    true,
    false,
    false,
    false
}

ANIMATION_TRANSITIONS = {
    {-1},
    {-1},
    {},
    {5, 6},
    {1, 6},
    {1}
}



return Data