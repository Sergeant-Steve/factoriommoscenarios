-- Permissions Module
-- Made by: Mylon for FactorioMMO
-- This module sets the permissions in the way we want them to be.

function permissions_init()
	local default = game.permissions.groups[1]
	default.set_allows_action(defines.input_action.deconstruct, false)
	default.set_allows_action(defines.input_action.change_programmable_speaker_parameters, false)
	default.set_allows_action(defines.input_action.edit_custom_tag, false)
	default.set_allows_action(defines.input_action.delete_custom_tag, false)
	--No changing train stations
	--This one ought to cover most of the bases...
	default.set_allows_action(defines.input_action.open_train_gui, false)
	default.set_allows_action(defines.input_action.set_train_stopped, false)
	default.set_allows_action(defines.input_action.change_train_stop_station, false)
	game.permissions.create_group("trusted") --For level 5+ players.
	
	global.patreon.patreons = {}
	global.trusted.list = {}
end

function permissions_upgrade(event)
	if event.tick % (5 * 60 * 60) == 500 then --Check once every 5 minutes
		for n, p in pairs(game.connected_players) do
			if p.permissions_group.name == "default" then
				if p.online_time / 60 / 60 > 30 then --30 minutes
					p.permission_group = game.permissions.get_group("trusted")
				end
			end
		end
	end	
end

function permissions_precheck(event)
	local player = game.players[player_index]
	if patreon_check(player) or player.admin then
		p.permission_group = game.permissions.get_group("trusted")
	end
end

Event.register()
Event.register(defines.events.on_player_created, permissions_precheck)
Event.register(-1, permissions_init)
