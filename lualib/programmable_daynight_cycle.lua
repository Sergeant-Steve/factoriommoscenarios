TAU = 6.28318530718 -- this is not the correct form to declare a global variable

function programmable_daynight_cycle(event)
	local stepsize_ticks = 600 --10 sec in ticks. Assuming 10min day-cycle, that's 60 points resolution
	local daylength_ticks = 36000-- 60ticks * 60 sec * 10min
	if not (game.tick % (stepsize) == 0) then -- Replace with 'on_nth_tick' once I figure out how to do that
		return
	end
	local current_time = game.player.surface.daytime -- according to the day-night cycle, not in ticks. [0.0 - 1.0)
	local next_time = current_time + (1/(daylength/stepsize))
	local current_darkness = 1 - game.player.surface.darkness -- from [1.0 to 0.15]. 0.15 represents full dark
	-- calculate the next set of xy coords. 
	-- y1 and y2 does not need to be assigned as they're made form a single call and not used again. 
	
	local slope = ((math.cos(next_time*TAU)-math.cos(current_time*TAU))/(next_time-current_time))
	-- very unsure if this works as expected. missing limiting the y range of it to 1.0 - 0.15
	
	if(slope == 0.0)
		slope += 0.00001
	end -- avoiding n/0
	
	-- convert xy coords to dusk/evening (down) or morning/dawn (up) as needed
	-- find the x coord where the slope intersects y=1.0 and y=0.0.
	-- if the slope is positive, you're setting dusk and evening. If not, you're setting morning and dawn.
	-- the order is dusk - evening - morning - dawn. each one's x-coord needs to be in that order. the x coord can be outside 0.0 -> 0.999
	
	local current_curve_start, current_curve_end = {x = current_time, y = current_darkness}, {x = next_time, y = (next_time - current_time)*slope}
	local y_top_start, y_top_end = {x = 0, y = 1}, {x = 1, y = 1}
	local y_bot_start, y_bot_end = {x = 0, y = 0.15}, {x = 1, y = 0.15}
    local top_point = intersection(current_curve_start, current_curve_end, y_top_start, y_top_end))
	local bot_point = intersection(current_curve_start, current_curve_end, y_top_start, y_top_end))
	
	if(slope == 0.0)
		slope = slope + 0.0001
	end -- avoiding n/0
	
	if(slope < 0.0) -- dusk -> evening
		game.player.surface.dusk = top_point.x
		game.player.surface.evening = bot_point.x
	end
	else -- morning -> dawn
		game.player.surface.morning = bot_point.x
		game.player.surface.dawn = top_point.x
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


Event.register(defines.events.on_tick, programmable_daynight_cycle)
