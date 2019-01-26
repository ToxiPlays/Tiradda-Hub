local discordia = require('discordia')
local client = discordia.Client()
local enums = discordia.enums

local admins = {
	["259935350653321216"] = true,
	["312435711192334336"] = true,
	["368595168523321346"] = true,
	["521025553562730506"] = true
}

local HelpMessage = [[
Tiradda's Hub is a game bot that will instantly set up upon inviting it to a Discord server.

Would you like...
a list of commands? ( <https://github.com/CryfryDoesGaming/Tiradda-Hub/wiki/Commands> )
a list of vaild difficulties? ( <https://github.com/CryfryDoesGaming/Tiradda-Hub/wiki/Difficulties> )
]]
local difficulties = {
	["automatic"] = 0,
	["easy"] = 10,
	["normal"] = 60,
	["hard"] = 20,
	["harder"] = 30,
	["insane"] = 60,
	["impossible"] = 95,
}
local PublicLevels = {}
local CreatorLevels = {}

function fetchUserID(user)
	-- This works by noticing that by mentioning someone, you send "<@USER ID>" into a Discord channel.
	-- This function simply cuts off the <@ and > part of the mention to give you the User ID of the Discord user.
	local mentionString = user.mentionString
	local ID = string.sub(mentionString,3,string.len(mentionString)-1)
	
	if ID then
		return ID
	else
		return nil
	end
end

function CheckForCommands(message, arguments)
	if arguments[1] == 'h>ping' then
		message.channel:send('🏓 Pong!')
	elseif arguments[1] == 'h>search' then
		local index = tonumber(arguments[2])
		local level = PublicLevels[index]
		if level then
			message.channel:send {
									  embed = {
										title = level["Name"],
										description = "**Created by**: "..level["Creator"].."\n**Chance of Beating**: "..level["Difficulty"].."%\nBeating this level will give you **"..level["Stars"].."** stars!",
										color = discordia.Color.fromRGB(255, 255, 0).value,
										footer = "Created on ",
										timestamp = level["Timestamp"]
									  }
									}
		else
			message.channel:send {
									  embed = {
										title = "Error",
										fields = {
										  {name = "What Happened?", value = "Level Not Found", inline = true},
										  {name = "Fix", value = "Make sure that the level is uploaded, and that you typed the right ID (PublicLevelID, not LevelID)", inline = true},
										},
										color = discordia.Color.fromRGB(255, 0, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
		end
	elseif arguments[1] == 'h>say' then
		if message.mentionsEveryone then
			message.channel:send('Sorry, but I am specifically programmed to NOT repeat messages from people that ping everyone, or ping here. Please try another message.')
			return
		end
		local allowedToRun = admins[tostring(fetchUserID(message.author))]
		if allowedToRun then
			if arguments[2] == 'true' then
				message:delete()
			end
			local name = ""
			for i=1,#arguments do
				if i ~= 1 then
					if i ~= 2 then
						name = name..arguments[i].." "
					end
				end
			end
			message.channel:send(name)
		else
			message.channel:send('Only bot developers are allowed to run this command!')
		end
	elseif arguments[1] == 'h>help' then
		message.channel:send('I\'ve been informed you have mail, **'..message.author.username..'**.')
		message.author:send(HelpMessage)
	elseif arguments[1] == 'h>invite' then
		message.channel:send('I\'ve been informed you have mail, **'..message.author.username..'**.')
		message.author:send('Someone on your account has asked for a link to add Tiradda\'s Hub to your server. Here it is.')
		message.author:send('https://discordapp.com/api/oauth2/authorize?client_id=532094093820428298&permissions=0&scope=bot')
	elseif arguments[1] == 'h>support' then
		message.channel:send('I\'ve been informed you have mail, **'..message.author.username..'**.')
		message.author:send('Someone on your account has asked for the support Discord server invite. Here it is.')
		message.author:send('https://discord.gg/jqAC2CE')
	elseif arguments[1] == 'h>verify' then
		local level = CreatorLevels[tonumber(arguments[2])]
		if level ~= nil then
			if level["Status"] == "Verified" then
				message.channel:send {
									  embed = {
										title = "Error",
										fields = {
										  {name = "What Happened?", value = "You've already beat this!", inline = true},
										  {name = "Fix", value = "Nothing you need to do now (except upload this level).", inline = true},
										},
										color = discordia.Color.fromRGB(255, 0, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
			else
				if level["Creator"] == message.author.username then
					local number = math.random(1,100)
					local chance = level["Difficulty"]
					if number > chance then
					level["Status"] = "Verified"
						message.channel:send {
									  embed = {
										title = "You beat this level!",
										description = "Now try uploading it to the public.",
										color = discordia.Color.fromRGB(0, 255, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
				else
						message.channel:send {
									  embed = {
										title = "Failure",
										description = "You failed this level.",
										color = discordia.Color.fromRGB(255, 0, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
				end
			else
				message.channel:send {
								  embed = {
									title = "Error",
									fields = {
									  {name = "What Happened?", value = "The level isn't published.", inline = true},
									  {name = "Fix", value = "Wait until "..level["Creator"].." publishes this level.", inline = true},
									},
									color = discordia.Color.fromRGB(255, 0, 0).value,
									timestamp = discordia.Date():toISO('T', 'Z')
								  }
								}
			end
		end
		else
			message.channel:send {
								  embed = {
									title = "Error",
									fields = {
									  {name = "What Happened?", value = "The level doesn't exist.", inline = true},
									  {name = "Fix", value = "Create a level, or try rewriting the command.", inline = true},
									},
									color = discordia.Color.fromRGB(255, 0, 0).value,
									timestamp = discordia.Date():toISO('T', 'Z')
								  }
								}
		end
		elseif arguments[1] == "h>createlvl" then
			local difficulty = difficulties[string.lower(arguments[2])]
		if difficulty then
			message.channel:send('Level successfully created! Your level ID: `'..tostring(#CreatorLevels+1)..'`')
			CreatorLevels[#CreatorLevels+1] = {
				["Creator"] = message.author.username,
				["Difficulty"] = difficulty,
				["Status"] = "Pending"
			}
		else
			message.channel:send('That\'s not a vaild difficulty! See `h>help` for a list of vaild difficulties.')
		end
	elseif arguments[1] == 'h>upload' then
		level = CreatorLevels[tonumber(arguments[2])]
		if level then
			local name = ""
			for i=1,#arguments do
				if i ~= 1 then
					if i ~= 2 then
						name = name..arguments[i].." "
					end
				end
			end
			message.channel:send {
									  embed = {
										title = "Uploaded!",
										description = "Your level ID is "..tostring(#PublicLevels+1).."\n**Name**: "..name.."\n**Chance of Failure**: "..level["Difficulty"].."%",
										color = discordia.Color.fromRGB(255, 255, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
			PublicLevels[#PublicLevels+1] = {
				["Creator"] = message.author.username,
				["Name"] = name,
				["Difficulty"] = level["Difficulty"],
				["Stars"] = 0,
				["Timestamp"] = discordia.Date():toISO('T', 'Z')
			}
			
			table.remove(CreatorLevels,tonumber(arguments[2]))
		else
			message.channel:send('You gave an invaild ID.')
		end
	end
end

client:on('messageCreate', function(message)
	local arguments = {}
	for i in string.gmatch(message.content, "%S+") do
	   arguments[#arguments+1] = i
	end
	
	-- argument 1 = "h>"command-name
	-- argument 2 and beyond - actual arguments
	
	
	if message.author.bot == false then
		CheckForCommands(message, arguments)
	end
end)

client:on('ready', function()
	-- client.user is the path for your bot
	print('Logged in as '.. client.user.username)
	client:setGame{
		["name"] = tostring(#client.guilds..' servers | h>help'),
		["type"] = 2
	}
end)


client:run('Bot TOKEN')
