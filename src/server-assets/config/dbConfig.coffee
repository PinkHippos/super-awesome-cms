thinky = require 'thinky'

redisOpts =
  host: process.env.REDIS_HOST
  port: process.env.REDIS_PORT
  pass: process.env.REDIS_PASS



thinkyOpts =
  authKey: process.env.SSH_TUNNEL_AUTHKEY
  db: process.env.DB_NAME
  host: process.env.DB_HOST
  port: process.env.DB_PORT

db = thinky thinkyOpts

module.exports =
  db: db
  r: db.r
  redisOpts: redisOpts
