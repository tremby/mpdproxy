require('start-stop-daemon')
	outFile: 'daemon.out.log'
	errFile: 'daemon.err.log'
, ->
	require('./mpdproxy').start()
