TAU = 6.28318530718 -- this is not the correct form to declare a global variable

function programmable_daynight_cycle(event)
	local stepsize = 600 --10 sec in ticks. Assuming 10min day-cycle, that's 60 points resolution
	if not (game.tick % (stepsize) == 0) then -- Replace with 'on_nth_tick' once I figure out how to do that
		return
	end
	local current_time = game.player.surface.daytime -- according to the day-night cycle, not in ticks. [0.0 - 1.0)
	local next_time = 2 * current_time
	local current_darkness = game.player.surface.darkness -- from [0.0 to 0.85]. 0.85 represents full dark
	-- calculate the next set of xy coords. 
	-- local x1 = current_time
	-- local x2 = 2 * current_time -- not needed as x2 - x1 will always be equal x1 here, meaning that both assignments are unessesary
	-- y1 and y2 does not need to be assigned as they're made form a single call and not used again. 
	
	local slope = ((math.cos(next_time*TAU)-math.cos(current_time*TAU))/current_time)
	
	-- convert xy coords to dusk/evening (down) or morning/dawn (up) as needed
	-- find the x coord where the slope intersects y=1.0 and y=0.0.
	-- if the slope is positive, you're setting dusk and evening. If not, you're setting morning and dawn.
	-- the order is dusk - evening - morning - dawn. each one's x-coord needs to be in that order. the x coord can be outside 0.0 -> 0.999
	
	local line1start, line1end = {x = current_time, y = 0}, {x = 2*current_time, y = 10}
	local line2start, line2end = {x = -10000000, y = 1}, {x = 10000000, y = 1}
    local X = intersection(line1start, line1end, line2start, line2end))
	
	if(slope == 0.0)
		slope = slope + 0.0001
	end -- avoiding n/0
	
	if(slope < 0.0) -- dusk -> evening
	-- do something
	end
	else -- morning -> dawn
	-- do something else
	end
end

-- take all this and put it into a seperate module
-- code stolen from https://rosettacode.org/wiki/Find_the_intersection_of_two_lines#Lua
function intersection (s1, e1, s2, e2)
  local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
  local a = s1.x * e1.y - s1.y * e1.x
  local b = s2.x * e2.y - s2.y * e2.x
  local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
  local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
  return x, y
end

function slope (x1, y1, x2, y2)
return ((x2-x1)/(y2-y1))

local line1start, line1end = {x = 4, y = 0}, {x = 6, y = 10}
local line2start, line2end = {x = 0, y = 3}, {x = 10, y = 7}
print(intersection(line1start, line1end, line2start, line2end))



Event.register(defines.events.on_tick, programmable_daynight_cycle)
