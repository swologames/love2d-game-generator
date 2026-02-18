-- Animation State Machine
-- Manages animation states and transitions

local AnimationStateMachine = {}
AnimationStateMachine.__index = AnimationStateMachine

function AnimationStateMachine:new(animationSystem)
  local instance = setmetatable({}, self)
  
  instance.animationSystem = animationSystem
  instance.states = {}
  instance.currentState = nil
  instance.transitions = {}
  instance.conditions = {}
  
  return instance
end

-- Add a state that maps to an animation
-- @param name: State name
-- @param animationName: Animation to play in this state
-- @param onEnter: Optional callback when entering state
-- @param onExit: Optional callback when exiting state
function AnimationStateMachine:addState(name, animationName, onEnter, onExit)
  self.states[name] = {
    name = name,
    animation = animationName,
    onEnter = onEnter,
    onExit = onExit
  }
  
  print("[AnimStateMachine] Added state:", name, "->", animationName)
  return true
end

-- Add a transition between states
-- @param fromState: State to transition from
-- @param toState: State to transition to
-- @param condition: Function that returns true when transition should occur
function AnimationStateMachine:addTransition(fromState, toState, condition)
  if not self.transitions[fromState] then
    self.transitions[fromState] = {}
  end
  
  table.insert(self.transitions[fromState], {
    to = toState,
    condition = condition
  })
  
  return true
end

-- Set the current state (force transition)
-- @param name: State name
-- @param force: Force transition even if already in this state
function AnimationStateMachine:setState(name, force)
  if not self.states[name] then
    print("[AnimStateMachine] Warning: State not found:", name)
    return false
  end
  
  -- Don't change if already in this state (unless forced)
  if self.currentState == name and not force then
    return true
  end
  
  -- Exit current state
  if self.currentState then
    local state = self.states[self.currentState]
    if state.onExit then
      state.onExit()
    end
  end
  
  -- Enter new state
  self.currentState = name
  local state = self.states[name]
  
  if state.animation then
    self.animationSystem:play(state.animation, true)
  end
  
  if state.onEnter then
    state.onEnter()
  end
  
  print("[AnimStateMachine] Entered state:", name)
  return true
end

-- Update state machine and check transitions
-- @param dt: Delta time
-- @param context: Context object passed to transition conditions (typically the entity)
function AnimationStateMachine:update(dt, context)
  if not self.currentState then return end
  
  -- Check transitions from current state
  local transitions = self.transitions[self.currentState]
  if transitions then
    for _, transition in ipairs(transitions) do
      if transition.condition(context) then
        self:setState(transition.to)
        break -- Only process one transition per frame
      end
    end
  end
  
  -- Update animation system
  self.animationSystem:update(dt)
end

-- Draw current animation
function AnimationStateMachine:draw(...)
  self.animationSystem:draw(...)
end

-- Get current state name
function AnimationStateMachine:getCurrentState()
  return self.currentState
end

-- Get current animation name
function AnimationStateMachine:getCurrentAnimation()
  return self.animationSystem:getCurrentAnimation()
end

-- Check if animation is playing
function AnimationStateMachine:isPlaying()
  return self.animationSystem:isPlaying()
end

return AnimationStateMachine
