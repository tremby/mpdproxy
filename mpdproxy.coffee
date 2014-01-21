net = require 'net'
netmask = require 'netmask'

try
	config = require './config'
catch e
	console.log "Configuration required. Copy config.coffee.example to config.coffee and edit it."
	process.exit 1

start = ->
	server = net.createServer (socket) ->
		address = socket.remoteAddress
		console.log "connection from #{address}"
		passwordless = false
		for range in config.passwordlessRanges
			if new netmask.Netmask(range).contains address
				console.log "in a passwordless range -- provide password on client's behalf"
				passwordless = true
				break
		if not passwordless
			console.log "not in a passwordless range"

		noMpd = (error) ->
			console.log 'error:', error
			mpd.destroy()
			if socket.writable
				socket.write String(error) + '\n'
			socket.destroy()

		gotVersion = false
		data = ''
		versionstring = null
		passwordacknowledged = false

		parseData = (newdata) ->
			data += newdata

			# split data by newline
			lines = data.split '\n'

			# read each line but the last as a command
			while lines.length > 1
				parseLine lines.shift()

			# whatever is left (there was no newline character after it) is partial 
			# data, save for next time
			data = lines[0]

		parseLine = (line) ->
			if gotVersion
				if passwordless and not passwordacknowledged
					if line == 'OK'
						passwordacknowledged = true
						socket.write versionstring + '\n'
						socket.pipe mpd
					else
						console.log 'password not accepted, response was ', line
						noMpd new Error "mpdproxy: password not accepted"
				else
					socket.write line + '\n'
			else
				if /^OK MPD .+/.test line
					gotVersion = true
					versionstring = line
					if passwordless
						mpd.write "password #{config.password}\n"
					else
						socket.write versionstring + '\n'
						socket.pipe mpd
				else
					console.log "unexpected opening data from MPD: #{line}"
					noMpd new Error "mpdproxy: unexpected opening data from MPD: #{line}"

		mpd = net.createConnection config.port, config.host
		mpd.setEncoding 'utf-8'

		mpd.on 'error', noMpd
		mpd.on 'timeout', -> noMpd new Error "mpdproxy: connection to MPD timed out"
		mpd.on 'end', -> noMpd new Error "mpdproxy: lost connection to MPD"
		mpd.on 'data', (newdata) ->
			if not gotVersion or passwordless and not passwordacknowledged
				# we need the data line by line
				parseData newdata
			else
				# output any unfinished data from previous iterations
				if data.length
					socket.write data
					data = ''

				# pass all new stuff through
				socket.write newdata

		socketError = (error) ->
			console.log "remote #{address}: #{error}"
		socket.on 'end', -> socketError "disconnected"
		socket.on 'error', socketError

	server.on 'error', (error) ->
		console.log 'server error: ', error

	server.listen config.proxyPort

# Start or expose application
# ---------------------------

if require.main is module
	start()
else
	module.exports.start = start
