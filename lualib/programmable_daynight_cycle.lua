TAU = 6.28318530718
-- Every 15s, check the table of grave markers and remove expired ones.
function custom_daytime_cycle(event)
	local stepsize = 600 --10 sec in ticks. Assuming 10min day-cycle, that's 60 points resolution
	if not (game.tick % (stepsize) == 0) then -- Replace with 'on_nth_tick' once I figure out how to do that
		return
	end
	local current_time = game.player.surface.daytime -- according to the day-night cycle, not in ticks. [0.0 - 1.0)

	-- calculate the next set of xy coords. 
	-- local x1 = current_time
	-- local x2 = 2 * current_time -- not needed as x2 - x1 will always be equal x1 here, meaning that both assignments are unessesary
	-- y1 and y2 does not need to be assigned as they're made form a single call and not used again. 
	
	local slope = ((math.cos(2*current_time*TAU)-math.cos(current_time*TAU))/current_time)
	
	-- convert xy coords to dusk/evening (down) or morning/dawn (up) as needed
	-- find the x coord where the slope intersects y=1.0 and y=0.0.
	-- if the slope is positive, you're setting dusk and evening. If not, you're setting morning and dawn.
	-- the order is dusk - evening - morning - dawn. each one's x-coord needs to be in that order. the x coord can be outside 0.0 -> 0.999
	
	if(slope < 0.0) -- dusk - evening
	-- do something
	end
	else -- morning - dawn
	-- do something else
	end
end

Event.register(defines.events.on_tick, custom_daytime_cycle)
