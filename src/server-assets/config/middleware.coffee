cors         = require 'cors'
express      = require 'express'
passport     = require 'passport'
bodyParser   = require 'body-parser'
cookieParser = require 'cookie-parser'
session      = require 'express-session'
RedisStore   = require('connect-redis') session


{googleAuth}   = require "#{__dirname}/../controllers/authCtrl"
{r, redisOpts} = require "#{__dirname}/dbConfig"

module.exports = (app)->
  ######
  # Parsing packages
  ######
  app.use bodyParser.json()
  app.use cookieParser()
  app.use cors()

  require("#{__dirname}/passport") passport
  ######
  # Static file serving
  ######
  app.use '/', express.static "#{__dirname}/../../client"


  ######
  # Auth specific middleware
  ######
  app.use session
    store: new RedisStore redisOpts
    secret: process.env.SESSION_SECRET
    resave: false
    saveUninitialized: false
  app.use passport.initialize()
  app.use passport.session()
