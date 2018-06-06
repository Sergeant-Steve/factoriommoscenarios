global.programmable_daynight_cycle = global.programmable_daynight_cycle or {}
global.programmable_daynight_cycle.enabled = global.programmable_daynight_cycle.enabled or true


function programmable_daynight_cycle_tick(event)
	local daylength_ticks = 15000 --The day-night cycle length in ticks. Can be any value.
	local stepsize_ticks = 59 	 -- stepsize_ticks < 25000!!!
	if not (game.tick % stepsize_ticks == 0) then -- Replace with 'on_nth_tick' once I figure out how to do that
		return
	end
	local time_ratio = (daylength_ticks/25000) -- normal day-night cycle length
	local current_time = (game.tick / daylength_ticks)
	local time_step = (stepsize_ticks/daylength_ticks)
	current_curve_start = {x = current_time, y = programmable_daynight_cycle_alt_dnc(current_time)}
	current_curve_end = {x = current_time + (time_step * time_ratio), y = programmable_daynight_cycle_alt_dnc(current_time + time_step)}
	local y_top_start, y_top_end = {x = -999999999, y = 1}, {x = 999999999, y = 1}
	local y_bot_start, y_bot_end = {x = -999999999, y = 0.15}, {x = 999999999, y = 0.15}
    local top_point = programmable_daynight_cycle_intersection(current_curve_start, current_curve_end, y_top_start, y_top_end)
	local bot_point = programmable_daynight_cycle_intersection(current_curve_start, current_curve_end, y_bot_start, y_bot_end)
	-- clean-up and avoiding daytime loop-back
	game.surfaces[1].daytime = 0
	game.surfaces[1].dusk = -999999999
	game.surfaces[1].dawn = 999999999
	game.surfaces[1].evening = -999999998
	game.surfaces[1].morning = 999999998	
	if(top_point < bot_point) then -- dusk -> evening
		game.surfaces[1].evening = bot_point - current_time
		game.surfaces[1].dusk = top_point - current_time
	else -- morning -> dawn
		game.surfaces[1].morning = bot_point - current_time
		game.surfaces[1].dawn = top_point - current_time
	end
end

function programmable_daynight_cycle_alt_dnc (x) -- now more fancy and with 179.9 days 'orbit'
	local TAU = 6.28318530718 -- this is not the correct form to declare a global variable. Will fix once everything else works
	local PI =  3.14159265359
	x = x * TAU
	-- return (math.sin(x * TAU) + (0.111 * math.sin(3 * x * TAU))) * 1.12 -- simpler formula, no 'orbit'
	-- return math.sin(x)
	return 0.15 + 0.85*(((1+((math.sin(x)+(0.111111111*math.sin(3*x))-(0.02*math.sin(5*x))-(0.01020408*math.sin(7*x)))*1.1365))*0.5)*(1-(1+math.cos(0.0055555*x + PI))*0.48))
end

-- take all this and put it into a seperate module once everything else works
-- code stolen from https://rosettacode.org/wiki/Find_the_intersection_of_two_lines#Lua
function programmable_daynight_cycle_intersection (s1, e1, s2, e2)
  local d = (s1.x - e1.x) * (s2.y - e2.y) - (s1.y - e1.y) * (s2.x - e2.x)
  local a = s1.x * e1.y - s1.y * e1.x
  local b = s2.x * e2.y - s2.y * e2.x
  local x = (a * (s2.x - e2.x) - (s1.x - e1.x) * b) / d
  local y = (a * (s2.y - e2.y) - (s1.y - e1.y) * b) / d
  return x--, y
end

function programmable_daynight_cycle_enable()
	global.programmable_daynight_cycle.enabled = true
	Event.register(defines.events.on_tick, programmable_daynight_cycle_tick)
end

function programmable_daynight_cycle_disable()
	global.programmable_daynight_cycle.enabled = false
	Event.remove(defines.events.on_tick, programmable_daynight_cycle_tick)
	-- Might want to reset these values to their defaults?
	-- game.surfaces[1].daytime = 0
	-- game.surfaces[1].dusk = -999999999
	-- game.surfaces[1].dawn = 999999999
	-- game.surfaces[1].evening = -999999998
	-- game.surfaces[1].morning = 999999998
end

function programmable_daynight_cycle_init()
	if global.programmable_daynight_cycle.enabled then
		programmable_daynight_cycle_enable()
	else
		programmable_daynight_cycle_disable()
	end
end

Event.register(-1, programmable_daynight_cycle_init)

