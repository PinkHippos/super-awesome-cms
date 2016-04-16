app = require "#{__dirname}/app"

{port} = require "#{__dirname}/config/serverConfig"

server = app.listen port, (e)->
  if e then console.log 'SERVER START ERROR ====>', e
  else
    console.log "SERVER SPUN UP ON PORT #{port}"

module.exports = server
