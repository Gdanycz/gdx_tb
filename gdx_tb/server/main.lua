ESX = nil

TriggerEvent(Config.GetSharedObject, function(obj) ESX = obj end)

RegisterCommand("tb", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "admin" then
        if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
            TriggerEvent("gdx_tb:sendTB", source, tonumber(args[1]), tonumber(args[2]), args[3])
        else
            TriggerClientEvent("chat:addMessage", source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
        end
    else
        TriggerClientEvent("chat:addMessage", source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
    end
end)

TriggerEvent('chat:addSuggestion', '/tb', 'Send to TB island', {
    { name = "id", help = _U('target_id') },
    { name = "actions", help = _U('action_count_suggested') }
    { name = "reason", help = _U('reason') }
}))

RegisterCommand("tbcheck", function(source, args, rawCommand)
    TriggerEvent('gdx_tb:checkIfSentenced', source)
end, true)

RegisterCommand("endtb", function(source, args, rawCommand)
    local xPlayer = ESX.GetPlayerFromId(source)
    if xPlayer.getGroup() == "admin" then
        if args[1] then
            if GetPlayerName(args[1]) ~= nil then
                TriggerEvent("gdx_tb:endTB", tonumber(args[1]))
            else
                TriggerClientEvent("chat:addMessage", source, { args = { _U('system_msn'), _U('invalid_player_id')  } } )
            end
        else
            TriggerEvent("gdx_tb:endTB", source)
        end
    else
        TriggerClientEvent("chat:addMessage", source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
    end
end)

TriggerEvent('chat:addSuggestion', '/tb', 'End TB island', {
    { name = "id", help = _U('target_id') },
}))

RegisterServerEvent('gdx_tb:endTB')
AddEventHandler('gdx_tb:endTB', function(source)
	if source ~= nil then
		releaseFromCommunityService(source)
	end
end)

RegisterServerEvent('gdx_tb:finishTB')
AddEventHandler('gdx_tb:finishTB', function()
	releaseFromTB(source)
end)

RegisterServerEvent('gdx_tb:completeTB')
AddEventHandler('gdx_tb:completeTB', function()

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier

	MySQL.Async.fetchAll('SELECT * FROM penalty_points WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE penalty_points SET actions_remaining = actions_remaining - 1 WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})
		else
			writeConsole("Problem matching player identifier in database to reduce actions.")
		end
	end)
end)

RegisterServerEvent('gdx_tb:extendTB')
AddEventHandler('gdx_tb:extendTB', function()

	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier

	MySQL.Async.fetchAll('SELECT * FROM penalty_points WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE penalty_points SET actions_remaining = actions_remaining + @extension_value WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@extension_value'] = Config.ServiceExtensionOnEscape
			})
		else
			writeConsole("Problem matching player identifier in database to reduce actions.")
		end
	end)
end)

RegisterServerEvent('gdx_tb:sendTB')
AddEventHandler('gdx_tb:sendTB', function(source, target, actions_count, reason)

    local _source = source
    local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier


	MySQL.Async.fetchAll('SELECT * FROM penalty_points WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE penalty_points SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		else
			MySQL.Async.execute('INSERT INTO penalty_points (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		end
	end)
	local connect = {
					{
						["color"] = "16718105",
						["title"] = GetPlayerName(source).." (".. identifier ..")",
						["description"] = "🔨 **"..GetPlayerName(target).."** ".._U('discord_log', actions_count, reason),
						["footer"] = {
						["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
						["icon_url"] = "https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/apple/271/honeybee_1f41d.png",
						},
					}
    }
	
	PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = _U('discord_log_name'), embeds = connect}), { ['Content-Type'] = 'application/json' })
				

	TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_msg', GetPlayerName(target), actions_count, reason) }, color = { 147, 196, 109 } })
	TriggerClientEvent('esx_policejob:unrestrain', target)
	TriggerClientEvent('gdx_tb:inTB', target, actions_count, reason)
end)

RegisterServerEvent('gdx_tb:checkIfSentenced')
AddEventHandler('gdx_tb:checkIfSentenced', function(source)
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(_source)
	local identifier = xPlayer.identifier

	MySQL.Async.fetchAll('SELECT * FROM penalty_points WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil and result[1].actions_remaining > 0 then
		    TriggerClientEvent('gdx_tb:inTB', _source, tonumber(result[1].actions_remaining))
		end
	end)
end)

function releaseFromTB(target)

    local xPlayer = ESX.GetPlayerFromId(target)
	local identifier = xPlayer.identifier
	MySQL.Async.fetchAll('SELECT * FROM penalty_points WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('DELETE from penalty_points WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_finished', GetPlayerName(target)) }, color = { 147, 196, 109 } })
		end
	end)

	TriggerClientEvent('gdx_tb:finishTB', target)
end

function writeConsole(text)
    print("^2["..Config.Resource.."] ^0"..text)
end