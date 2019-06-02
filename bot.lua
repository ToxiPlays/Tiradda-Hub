--client.guilds:get(serverID):getChannel(channelID)
pcall(os.remove, 'discordia.log')
pcall(os.remove, 'gateway.json')
local discordia = require('discordia')
local client = discordia.Client()
local enums = discordia.enums
local sandbox = setmetatable({ }, { __index = _G })
function printLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = tostring(select(i, ...))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end
local pp = require('pretty-print')
function prettyLine(...)
    local ret = {}
    for i = 1, select('#', ...) do
        local arg = pp.strip(pp.dump(select(i, ...)))
        table.insert(ret, arg)
    end
    return table.concat(ret, '\t')
end

local admins = {
	["259935350653321216"] = true,
	["312435711192334336"] = true,
	["368595168523321346"] = true,
	["521025553562730506"] = true,
	["482926980564779009"] = true
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
local UserStars = {}

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

function GiveStars(userID, amount, message)
	local checkforEntry = nil
	if amount == 0 then
		message.channel:send("This level is unrated. You have not received any stars for beating it.")
		return
	end
	for i=1, #UserStars do
		local temp = UserStars[i]
		if temp["UserID"] == userID then
			checkforEntry = temp
		end
	end
	if checkforEntry == nil then
		UserStars[#UserStars+1] = {
			["UserID"] = userID,
			["Stars"] = 0
		}
		checkforEntry = UserStars[#UserStars]
	end
	local newStars = checkforEntry["Stars"] + amount
	checkforEntry["Stars"] = newStars
	message.channel:send("Congrats <@"..userID..">! You now have **"..newStars.."⭐** in total!")
end


function exec(arg, msg)
	local function code(str)
		return string.format('```lua\n%s\n```', str)
	end
	
	if not arg then return end
	if msg.author ~= msg.client.owner then return end
	
	arg = arg:gsub('```\n?', '') -- strip markdown codeblocks
	local unnamedTable = {}
	sandbox.message = msg
	sandbox.print = function(...)
		table.insert(unnamedTable, printLine(...))
	end
	sandbox.p = function(...)
		table.insert(unnamedTable, prettyLine(...))
	end
	sandbox.client = client
	sandbox.enums = enums
	sandbox.PublicLevels = PublicLevels
	sandbox.CreatorLevels = CreatorLevels
	sandbox.UserStars = UserStars
	sandbox.restart = function()
		msg.channel:send("```lua\n[string \"DiscordBot\"]:1: Restarting bot...```")
		os.execute("luvit bot.lua")
	end
	local fn, syntaxError = load(arg, 'DiscordBot', 't', sandbox)
	if not fn then return msg:reply(code(syntaxError)) end
	local success, runtimeError = pcall(fn)
	if not success then return msg:reply(code(runtimeError)) end
	unnamedTable = table.concat(unnamedTable, '\n')
	if #unnamedTable > 1990 then -- truncate long messages
		unnamedTable = unnamedTable:sub(1, 1990)
	end
	return msg:reply(code(unnamedTable))
end

function ChangeDescription(ID, desc, message)
	local level = PublicLevels[ID]
	if level then else message.channel:send("Error when looking up ID ".. tostring(ID)..". Canceling description change.") return end
	
	level["Description"] = desc
	message.channel:send("Successfully changed "..level["Name"].."'s description!")
	local channel = client.guilds:get("534252018303369226"):getChannel("561407500939821066")
	channel:send("**<:levelCreated:561742421692776448> "..message.author.username.." added a description to a level!**\n`Description`: ```"..desc.."````Play Now`: h>play "..ID)
end

function CheckForCommands(message, arguments)
	if arguments[1] == 'h>ping' then -- help command buffed by [FuZion] Sexy Cow#0018
		local x = os.clock()
		local s = 0
		for i=1,100000 do
			s = s + i
		end
		local ccolor = discordia.Color(math.random(255), math.random(255), math.random(255)).value
		local embedmessage = message.channel:send{
  			embed = {
    			title = "Ping...",
    			color = discordia.Color.fromRGB(255, 0, 0).value,
				timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
 	 		}
		}
		if not embedmessage then noembedmsg = message.channel:sendMessage(luacode("pong")) end
		if not embedmessage then noembedmsg:setContent(luacode("🏓 Pong!"..string.format(" - time taken: %.2fs", os.clock() - x))) end
		if embedmessage then embedmessage:setEmbed {
				title = "🏓 Pong!",
				description = string.format("time taken: %.2fs", os.clock() - x),
				color = ccolor,
				timestamp = os.date('!%Y-%m-%dT%H:%M:%S'),
				footer = {text = message.author.name..""}
		}
		end
	elseif arguments[1] == 'h>desc' then
		local desc = ""
		for i=1,#arguments do
			if i ~= 1 then
				if i~= 2 then
					desc = desc..arguments[i].." "
				end
			end
		end
		if (desc == " " or desc == "") then
			desc = "This level does not have a description."
		end
		local level = PublicLevels[tonumber(arguments[2])]
		if level then
			local authorized = false
			if level["Creator"] == message.author.username then
				authorized = true
			end
			local allowedToRun = admins[tostring(fetchUserID(message.author))]
			if allowedToRun then
				authorized = true
			end
			if authorized then
				ChangeDescription(tonumber(arguments[2]), desc, message)
			else
				message.channel:send {
									  embed = {
										title = "Error",
										fields = {
										  {name = "What Happened?", value = "You don't own this level, and are not a bot admin.", inline = true},
										  {name = "Fix", value = "Double-check that you typed the correct ID.", inline = true},
										},
										color = discordia.Color.fromRGB(255, 0, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
			end
		else
			message.channel:send("You sent an invalid ID. Try using `h>search` to check if this ID exists.")
		end
	elseif arguments[1] == 'h>eval' then
		local name = ""
		for i=1,#arguments do
			if i ~= 1 then
				name = name..arguments[i].." "
			end
		end
		exec(name, message)
	elseif arguments[1] == 'h>play' then
		local level = PublicLevels[tonumber(arguments[2])]
		if level then
			local number = math.random(1,100)
			local chance = level["Difficulty"]
			if number > chance then
					message.channel:send {
									  embed = {
										title = "BOOOM!!",
										description = "You completed "..level["Creator"].."'s level, "..level["Name"]..". Because of this, you now have earned **"..level["Stars"].."⭐**!",
										color = discordia.Color.fromRGB(0, 255, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
					GiveStars(tostring(fetchUserID(message.author)), level["Stars"], message)
			else
				message.channel:send {
									  embed = {
										title = "Death",
										description = "You attempted to complete "..level["Creator"].."'s level, "..level["Name"]..", but died in the process. Maybe next time!",
										color = discordia.Color.fromRGB(255, 0, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
			end
		else
			message.channel:send("You sent an invalid ID. Try using `h>search` to check if this ID exists.")
		end
	elseif arguments[1] == 'h>setup' then
		message.channel:send(":white_check_mark: This bot is already set up in this Discord server, "..message.author.mentionString.."!")
	elseif arguments[1] == 'h>credit' then
		message.channel:send {
									  embed = {
										title = "Thank you to these many people.",
										description = "Your contributions to the bot have not gone unnoticed.\nToxiPlays#9278 - Bot Owner\nBright Lightning#6416 - Bot Developer\n[FuZion] Sexy Cow#0018 - Buffed h>help",
										color = discordia.Color.fromRGB(0, 255, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
	elseif arguments[1] == 'h>search' then
		local index = tonumber(arguments[2])
		local level = PublicLevels[index]
		if level then
			message.channel:send {
									  embed = {
										title = level["Name"],
										description = "**Created by**: "..level["Creator"].."\n**Chance of Losing**: "..tostring(level["Difficulty"]).."%\n------------\n"..level["Description"].."\n------------\nBeating this level will give you **"..level["Stars"].."** stars!",
										color = discordia.Color.fromRGB(255, 255, 0).value,
										footer = {
											text = "Created on "
										},
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
	elseif arguments[1] == 'h>rate' then
		local allowedToRun = admins[tostring(fetchUserID(message.author))]
		if allowedToRun then
			level = PublicLevels[tonumber(arguments[2])]
			if level then
				local oldStars = level["Stars"]
				level["Stars"] = tonumber(arguments[3])
				
				if oldStars == 0 then
					message.channel:send("Successfully rated "..level["Name"].." as a **"..arguments[3].."⭐**!")
					local channel = client.guilds:get("534252018303369226"):getChannel("561948119831674886")
					channel:send("<:levelCreated:561742421692776448> **"..level["Creator"].."'s level was rated by "..message.author.username.."! **\n`Name`: "..level["Name"].."\n`Chance of Failure`: "..level["Difficulty"].."%\n`Play Now`: h>play "..arguments[2].."\n`Stars`: "..arguments[3])
				else
					message.channel:send("Successfully changed "..level["Name"].."'s rating from a **"..oldStars.."⭐** to a **"..arguments[3].."⭐**!")
					local channel = client.guilds:get("534252018303369226"):getChannel("561948119831674886")
					channel:send("<:levelCreated:561742421692776448> **"..level["Creator"].."'s level's rating was changed by "..message.author.username.."! **\n`Name`: "..string.sub(name,1,string.len(name)-1).."\n`Chance of Failure`: "..level["Difficulty"].."%\n`Play Now`: h>play "..arguments[2].."\n`Stars`: "..arguments[3])
				end
			else
				message.channel:send("You sent an invalid ID. Try using `h>search` to check if this ID exists.")
			end
		else
			message.channel:send('Only bot developers are allowed to run this command!')
		end
	elseif arguments[1] == 'h>stars' then
		status = "<error resolving user>"
		local checkforEntry = nil
		if arguments[2] == nil then
			user = fetchUserID(message.author)
			status = "Your"
		else
			local user = string.sub(arguments[2],3,string.len(arguments[2])-1)
			status = arguments[2].."'s"
		end
		for i=1, #UserStars do
			temp = UserStars[i]
			if temp["UserID"] == fetchUserID(message.author) then
				checkforEntry = temp
			end
		end
		if checkforEntry == nil then
			message.channel:send {
									  embed = {
										title = status.." stars",
										description = "**0⭐**!",
										color = discordia.Color.fromRGB(0, 255, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
		else
			local stars = tostring(temp["Stars"])
			message.channel:send {
									  embed = {
										title = status.." stars",
										description = "**"..stars.."⭐**!",
										color = discordia.Color.fromRGB(0, 255, 0).value,
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
		--message.channel:send('I\'ve been informed you have mail, **'..message.author.username..'**.')
		--message.author:send(HelpMessage)
		message.channel:send('Sorry, '..message.author.username..'. This command is **disabled** because of technical difficulties with the https://toxiplays.github.io website. A bot developer may help you with using this bot. Take care!')
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
			if level["Status"] == "Pending" then
				message.channel:send {
									  embed = {
										title = "Error",
										fields = {
										  {name = "What Happened?", value = "Level is not Verified", inline = true},
										  {name = "Fix", value = "Beat this level (via h>verify) and then try to upload it!", inline = true},
										},
										color = discordia.Color.fromRGB(255, 0, 0).value,
										timestamp = discordia.Date():toISO('T', 'Z')
									  }
									}
				return
			end
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
				["Name"] = string.sub(name,1,string.len(name)-1),
				["Difficulty"] = level["Difficulty"],
				["Stars"] = 0,
				["Description"] = "This level does not have a description.",
				["Timestamp"] = discordia.Date():toISO('T', 'Z')
			}
			table.remove(CreatorLevels,tonumber(arguments[2]))
			client:setGame{
				["name"] = tostring(#PublicLevels..' levels | h>help'),
				["type"] = 2
			}
			local channel = client.guilds:get("534252018303369226"):getChannel("561407500939821066")
			channel:send("<:levelCreated:561742421692776448> **A new level was created by "..message.author.username.."!**\n`Name`: "..string.sub(name,1,string.len(name)-1).."\n`Chance of Failure`: "..level["Difficulty"].."%\n`Play Now`: h>play "..#PublicLevels)
		else
			message.channel:send('You gave an invaild ID.')
		end
		elseif arguments[1] == 'h>export' then
			if #PublicLevels == 0 then
				message.channel:send{file = {"levels.lua", "h>eval PublicLevels = {}"}}
				return
			end
			local un = "{"
			for i=1, #PublicLevels do
				local level = PublicLevels[i]
				un = un.."{[\"Creator\"] = \""..level["Creator"].."\",\n[\"Name\"] = \""..level["Name"].."\",\n[\"Difficulty\"] = "..level["Difficulty"]..", [\"Stars\"] = "..level["Stars"]..",\n[\"Description\"] = \""..level["Description"].."\", \n[\"Timestamp\"] = discordia.Date():toISO('T', 'Z')}, client:setGame{ [\"name\"] = tostring(#PublicLevels..' levels | h>help'), [\"type\"] = 2 }"
			end
			un = string.sub(un,1,string.len(un)-1)
			un = un.."}"
			message.channel:send{file = {"levels.lua", "h>eval PublicLevels = {"..un.."} client:setGame{ [\"name\"] = tostring(#PublicLevels..' levels | h>help'), [\"type\"] = 2 }"}}
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
		["name"] = tostring(#PublicLevels..' levels | h>help'),
		["type"] = 2
	}
end)

client:run('Bot TOKEN')