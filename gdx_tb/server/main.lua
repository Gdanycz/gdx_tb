ESX = nil

TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)


TriggerEvent('es:addGroupCommand', 'tb', 'admin', function(source, args, user)
	if args[1] and GetPlayerName(args[1]) ~= nil and tonumber(args[2]) then
		TriggerEvent('gdx_tb:sendTO', source, tonumber(args[1]), tonumber(args[2]), args[3])
	else
		TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id_or_actions') } } )
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
end, {help = _U('give_player_community'), params = {{name = "id", help = _U('target_id')}, {name = "actions", help = _U('action_count_suggested')}, {name = "duvod", help = _U('duvod')}}})
_U('system_msn')

RegisterCommand("tbcheck", function(source, args, rawCommand)
    TriggerEvent('gdx_tb:checkIfSentenced', source)
end, true)


TriggerEvent('es:addGroupCommand', 'endtb', 'admin', function(source, args, user)
	if args[1] then
		if GetPlayerName(args[1]) ~= nil then
			TriggerEvent('gdx_tb:endTOc', tonumber(args[1]))
		else
			TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('invalid_player_id')  } } )
		end
	else
		TriggerEvent('gdx_tb:endTOc', source)
	end
end, function(source, args, user)
	TriggerClientEvent('chat:addMessage', source, { args = { _U('system_msn'), _U('insufficient_permissions') } })
end, {help = _U('unjail_people'), params = {{name = "id", help = _U('target_id')}}})





RegisterServerEvent('gdx_tb:endTOc')
AddEventHandler('gdx_tb:endTOc', function(source)
	if source ~= nil then
		releaseFromCommunityService(source)
	end
end)

-- unjail after time served
RegisterServerEvent('gdx_tb:finishTO')
AddEventHandler('gdx_tb:finishTO', function()
	releaseFromCommunityService(source)
end)





RegisterServerEvent('gdx_tb:completeTO')
AddEventHandler('gdx_tb:completeTO', function()

	local _source = source
	local identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll('SELECT * FROM trestnebody WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE trestnebody SET actions_remaining = actions_remaining - 1 WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})
		else
			print ("gdx_tb :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)




RegisterServerEvent('gdx_tb:extendTO')
AddEventHandler('gdx_tb:extendTO', function()

	local _source = source
	local identifier = GetPlayerIdentifiers(_source)[1]

	MySQL.Async.fetchAll('SELECT * FROM trestnebody WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)

		if result[1] then
			MySQL.Async.execute('UPDATE trestnebody SET actions_remaining = actions_remaining + @extension_value WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@extension_value'] = Config.ServiceExtensionOnEscape
			})
		else
			print ("gdx_tb :: Problem matching player identifier in database to reduce actions.")
		end
	end)
end)






RegisterServerEvent('gdx_tb:sendTO')
AddEventHandler('gdx_tb:sendTO', function(source, target, actions_count, duvod)

	local identifier = GetPlayerIdentifiers(target)[1]
	local _source = source
	local xPlayer = ESX.GetPlayerFromId(source)

	MySQL.Async.fetchAll('SELECT * FROM trestnebody WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('UPDATE trestnebody SET actions_remaining = @actions_remaining WHERE identifier = @identifier', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		else
			MySQL.Async.execute('INSERT INTO trestnebody (identifier, actions_remaining) VALUES (@identifier, @actions_remaining)', {
				['@identifier'] = identifier,
				['@actions_remaining'] = actions_count
			})
		end
	end)
	local connect = {
					{
						["color"] = "16718105",
						["title"] = GetPlayerName(source).." (".. xPlayer.identifier ..")",
						["description"] = "🔨 **"..GetPlayerName(target).."** obdržel trest ve výši **"..actions_count.."** Trestných bodů z důvodu: **"..duvod.."**",
						["footer"] = {
						["text"] = os.date('%H:%M - %d. %m. %Y', os.time()),
						["icon_url"] = "https://emojipedia-us.s3.dualstack.us-west-1.amazonaws.com/thumbs/120/apple/271/honeybee_1f41d.png",
						},
					}
				}
	
				PerformHttpRequest(Config.DiscordWebhook, function(err, text, headers) end, 'POST', json.encode({username = "Trestné body - Logger", embeds = connect}), { ['Content-Type'] = 'application/json' })
				

	TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_msg', GetPlayerName(target), actions_count, duvod) }, color = { 147, 196, 109 } })
	TriggerClientEvent('esx_policejob:unrestrain', target)
	TriggerClientEvent('gdx_tb:inTO', target, actions_count, duvod)
end)


















RegisterServerEvent('gdx_tb:checkIfSentenced')
AddEventHandler('gdx_tb:checkIfSentenced', function(source)
	local _source = source -- cannot parse source to client trigger for some weird reason
	local identifier = GetPlayerIdentifiers(_source)[1] -- get steam identifier
	print(_source)

	MySQL.Async.fetchAll('SELECT * FROM trestnebody WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] ~= nil and result[1].actions_remaining > 0 then
			--TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('jailed_msg', GetPlayerName(_source), ESX.Math.Round(result[1].jail_time / 60)) }, color = { 147, 196, 109 } })
			TriggerClientEvent('gdx_tb:inTO', _source, tonumber(result[1].actions_remaining))
		end
	end)
end)







function releaseFromCommunityService(target)

	local identifier = GetPlayerIdentifiers(target)[1]
	MySQL.Async.fetchAll('SELECT * FROM trestnebody WHERE identifier = @identifier', {
		['@identifier'] = identifier
	}, function(result)
		if result[1] then
			MySQL.Async.execute('DELETE from trestnebody WHERE identifier = @identifier', {
				['@identifier'] = identifier
			})

			TriggerClientEvent('chat:addMessage', -1, { args = { _U('judge'), _U('comserv_finished', GetPlayerName(target)) }, color = { 147, 196, 109 } })
		end
	end)

	TriggerClientEvent('gdx_tb:finishTO', target)
end
