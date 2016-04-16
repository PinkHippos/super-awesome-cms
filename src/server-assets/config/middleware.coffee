bodyParser = require 'body-parser'
cookieParser = require 'cookie-parser'
cors  = require 'cors'
express = require 'express'
passport = require 'passport'
session = require 'express-session'
RedisStore = require('connect-redis') session

{googleAuth} = require "#{__dirname}/../controllers/authCtrl"
{r, redisOpts} = require "#{__dirname}/dbConfig"
{crudRead} = require "#{__dirname}/../helpers/crud"
{User} = require "#{__dirname}/../models"

module.exports = (app)->
  ######
  # Parsing packages
  ######
  app.use bodyParser.json()
  app.use cookieParser()
  app.use cors()

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

  ###
    Passport uses serialize and deserialize to manage the logged in User
    Instead of carrying the entire user around we just use the id
    We can then just lookup the user by id if we need req.user
  ###
  passport.serializeUser (user, done)->
    info =
      googleId: user.auth.google.id
      userId: user.id
      db: process.env.DB_NAME
    console.log 'ATTEMPTING TO SERIALIZE -->', info
    done null, info

  passport.deserializeUser (info, done)->
    query = User.filter r.row('auth')('google')('id').eq info.googleId
    crudRead query
      .then (user)->
        done null, user
      .catch (e)->
        done null, {msg: 'User not found', status: 404}

  passport.use 'google', googleAuth
