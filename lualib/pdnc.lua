--global.pdnc = global.programmable_daynight_cycle or {}
--global.pdnc.enabled = global.programmable_daynight_cycle.enabled or true
global.pdnc_scenario_selection = 0
global.pdnc_global_darkness = 0
global.pdnc_global_lightness = 0
global.pdnc_daylength_ticks = 36000
global.pdnc_stepsize_ticks = 31 
global.pdnc_doomsday = false
global.pdnc_doomsday_timer = 648000 -- 1h27.5m in ticks
global.current_time = 0
global.pdnc_disable_warning = true

function pdnc_tick(event)
	local stepsize_ticks = global.pdnc_stepsize_ticks -- stepsize_ticks < 25000!!!
	if not ((game.tick % stepsize_ticks == 0) and (global.pdnc.enabled)) then -- Replace with 'on_nth_tick' once I figure out how to do that
		return
	end
	if(global.pdnc_doomsday_timer < game.tick) then
		local pollution = (global.pdnc_doomsday_timer / game.tick) * global.pdnc_stepsize_ticks
		local position = {0.0,0.0} -- replace with bilinear aproximation of player position at doomsday
		game.surfaces[1].pollute(position, (10000 * pollution)) -- arbitrary value
	end
	if(game.surfaces[1].freeze_daytime)then
		game.surfaces[1].freeze_daytime = false
		game.print("Can't use freeze_daytime while programmable day-night cycle is active; time has been unfrozen")
	end
	local daylength_ticks = global.pdnc_daylength_ticks
	local current_time = (game.tick / daylength_ticks)
	global.current_time = (game.tick / daylength_ticks)
	local next_time = current_time + (stepsize_ticks/daylength_ticks)
	local curve_start = {x = current_time, y = pdnc_alt_dnc(current_time)}
	local curve_end = {x = next_time, y = pdnc_alt_dnc(next_time)}
    local top_point = pdnc_intersection_top(curve_start, curve_end)
	local bot_point = pdnc_intersection_bot(curve_start, curve_end)
	-- clean-up and avoiding daytime loop-back
	game.surfaces[1].daytime = 0
	game.surfaces[1].dusk = -999999999
	game.surfaces[1].dawn = 999999999
	game.surfaces[1].evening = -999999998
	game.surfaces[1].morning = 999999998
	-- TODO: add manual logic to check dusk, evening, morning and dawn to avoid errors in the log
	if(top_point == bot_point)
		game.print("PDNC top and bot point returned the same value! Ignoring, using last curve")
	elseif(top_point < bot_point) then -- dusk -> evening
		game.surfaces[1].evening = bot_point - current_time
		game.surfaces[1].dusk = top_point - current_time
	else -- morning -> dawn
		game.surfaces[1].morning = bot_point - current_time
		game.surfaces[1].dawn = top_point - current_time
	end
end

function pdnc_alt_dnc(x) -- now more fancy and with 179.9 days 'orbit'
	if(global.pdnc_scenario_selection = 0)
		return pdnc_doomsday_scenario(x)
	elseif(global.pdnc_scenario_selection = 1)
		return pdnc_unused_scenario(x)
	else
		return pdnc_default_scenario(x)
	end
end

function pdnc_doomsday_scenario(x)	
	local current_day = global.current_time * math.pi * 2 --read only!!!
	local returnvalue = 0
	local days = x * math.pi * 2
	local doomsday_start = (global.pdnc_doomsday_timer / global.pdnc_daylength_ticks)
	if (current_day < doomsday_start) then
		returnvalue = (1+((math.sin(x) + (0.111 * math.sin(3 * x))) * 1.1225)) * 0.5 -- simpler formula, no 'orbit'
		return pdnc_range_limiter(returnvalue*0.35 + 0.15)
	elseif (current_day < doomsday_start + 0.5) then
		if (global.pdnc_doomsday == false) then
			game.print("Nuclear winter is here. May god have mercy on your souls...")
			global.pdnc_doomsday = true
		end
		return pdnc_range_limiter((doomsday_start + 1) - current_day)^12)
	
	else
		returnvalue = ((1+(math.sin(x) + (0.111 * math.sin(3 * x)))) * 1.1225) * 0.5 -- simpler formula, no 'orbit'
		return pdnc_range_limiter((returnvalue * 0.2) - 0.01246)
	end
end

function pdnc_unused_scenario(x)
	return(pdnc_range_limiter((math.sin(x * math.pi * 2) + 1) * 0.5))
end

function pdnc_default_scenario(x)	
	local current_day = global.current_time * math.pi * 2 --read only!!!
	local returnvalue = 0
	local days = x
	x = x * math.pi * 2
    returnvalue = ((1+(math.sin(x) + (0.111 * math.sin(3 * x)))) * 1.1225) * 0.5 -- simpler formula, no 'orbit'
	return pdnc_range_limiter((returnvalue * 0.2) - 0.01246)
end

function pdnc_doomsday_time_left()
	if(global.pdnc_scenario_selection = 0)
		local ticks = (global.pdnc_doomsday_timer - game.tick)
		if (ticks >= 0) then 
			local seconds = math.floor(ticks/ 60)
			local minutes = math.floor(seconds / 60)
			local hours = math.floor(minutes / 60)
			local days = math.floor(hours / 24)
			game.print("time until doomsday: " .. string.format("%d:%02d:%02d", hours, minutes % 60, seconds % 60))
		else
			ticks = math.abs(ticks) 
			local seconds = math.floor(ticks / 60)
			local minutes = math.floor(seconds / 60)
			local hours = math.floor(minutes / 60)
			local days = math.floor(hours / 24)
			game.print("Doomsday was: " .. string.format("%d:%02d:%02d", hours, minutes % 60, seconds % 60) .. " ago...")
		end
	else
		game.print("Error: Doomsday scenraio not currently selected")
end

function pdnc_scenario_selection(n)
	global.pdnc_scenario_selection = n
end

function pdnc_set_doomsday_time_left_ticks(t)
	global.pdnc_doomsday_time_left = t + game.ticks()
end

function pdnc_set_doomsday_time_left_minutes(m)
	global.pdnc_doomsday_time_left = m*60*60 + game.ticks()
end

function pdnc_set_doomsday_time_left_hours(h)
	global.pdnc_doomsday_time_left = h*60*60*60 + game.ticks()
end
function pdnc_force_doomsday_now()
	global.pdnc_doomsday_time_left = game.ticks() + global.pdnc_stepsize_ticks  -- makes sure any transitional code runs
end
	
function pdnc_range_limiter(n)
	if (n < 0) then
		n = 0
	end
	if (n > 1.0) then
		n = 1
	end
	return 0.15 + global.pdnc_global_lightness + (n * 0.85 * (1 - global.pdnc_global_darkness))
end

-- take all this and put it into a seperate module once everything else works
-- code stolen from https://rosettacode.org/wiki/Find_the_intersection_of_two_lines#Lua
function pdnc_intersection (s1, e1, s2, e2)
  local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
  local a = s1.x * e1.y - s1.y * e1.x
  local b = s2.x * e2.y - s2.y * e2.x
  local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
  --local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
  return x--, y
end

function pdnc_intersection_top (s2, e2)
	local s1, e1 = {x = -999999999, y = 1}, {x = 999999999, y = 1}
	return pdnc_intersection (s1, e1, s2, e2)
end

function pdnc_intersection_bot (s2, e2)
	local s1, e1 = {x = -999999999, y = 0.15}, {x = 999999999, y = 0.15}
	return pdnc_intersection (s1, e1, s2, e2)
end


function pdnc_global_darkness(n)
  if((n>=0)and(n=<1.0))
	global.pdnc_global_darkness = n
  else
    game.print("global darkness needs to be [0.0 - 1.0], was: " .. n)
  end
end

function pdnc_disable()
	if(pdnc_disable_warning)
		game.print("Repeat the command to disable Programmable Day-Night Cycle. This cannot be undone.")
		pdnc_disable_warning = false
	else
		pdnc_force_disable()
	end
end

function pdnc_force_disable()
	global.pdnc.enabled = false
	Event.remove(defines.events.on_tick, pdnc_tick)
	game.surfaces[1].daytime = 0
	game.surfaces[1].dusk = -999999999
	game.surfaces[1].dawn = 999999999
	game.surfaces[1].evening = -999999998
	game.surfaces[1].morning = 999999998
	-- first setting to safe values before setting them back to defaults. 
	game.surfaces[1].evening = 0.45
	game.surfaces[1].morning = 0.55
	game.surfaces[1].dusk = 0.25
	game.surfaces[1].dawn = 0.75
	game.print("Resetting day-night cycle to default values")
end

function pdnc_stepsize_ticks(n)
	if ((n < 24998) and (n >= 1)) then -- 2 tick margin 
		global.pdnc_stepsize_ticks = n
	else 
		game.print("pdnc_stepsize_ticks was set to " .. n .. " but needs to be [1, 24998)")
		n = 59 -- reasonably good value for most uses. 
	end
end

function pdnc_daylength_ticks(n)
	if ((n < 1) or (n < global.pdnc_stepsize_ticks)) then
		game.print("tried to set global.pdnc_daylength_ticks to an unreasonable value: " .. n)
		global.pdnc_daylength_ticks = 36000 -- 10min default
	else 
		global.pdnc_daylength_ticks = n
	end
end

function pdnc_init()
    commands.add_command("timeleft", "Gives you the time till doomsday!", pdnc_doomsday_time_left)
end

-- seems the error with the command not working on reload is related to this part. 
Event.register(defines.events.on_tick,pdnc_tick)
Event.register(-1, pdnc_init)