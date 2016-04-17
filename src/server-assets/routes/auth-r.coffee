q        = require 'q'
_        = require 'lodash'
passport = require 'passport'

{r}                   = require "#{__dirname}/../config/dbConfig"
{User}                = require "#{__dirname}/../models"
{crudRead}            = require "#{__dirname}/../helpers/crudHelper"
{handleErr, sendErr}  = require "#{__dirname}/../helpers/util"
{getUser, createUser} = require "#{__dirname}/userCtrl"


module.exports =
  ##### auth #####
  # Ensures the requester is authenticated
  # Redirects if not logged in.
  auth: (req, res, next)->
    if req.isAuthenticated()
      next()
    else
      res
        .status 401
        .send 'Please login.'

  ##### login #####
  # Checks for a session in redis and logs in the user if found
  # Redirects if the user is not logged in.
  login: (req, res, next)->
    session = _.has req, 'session.passport.user'
    if session and req.session.passport.user.db is process.env.DB_NAME
      getUser req.session.passport.user.userId
        .then (user)->
          req.logout()
          req.login user, (err)->
            if err
              res
                .status 500
                .send err
            else
              res
                .status 200
                .end()
        .catch (err)->
          sendErr err, res
    else
      res.redirect '/api/auth/google'

  ##### logout #####
  # Logs out the user
  logout: (req, res, next)->
    console.log 'Logging out this user -->', req.user
    req.logout()
    req.session.destroy()
    res
      .status 204
      .redirect '/'

  ##### googleLogin #####
  # Authenticates using google oAuth
  # This uses a custom callback so we can handle for errs after done is called
  googleLogin: (req, res, next)->
    passport.authenticate('google', (err, user, info)->
      if err
        sendErr err, res
      if user
        req.logout()
        req.login user, (err)->
          if err
            sendErr err, res
          else
            status = 200
            if info.new
              status = 201
            res
              .status status
              .redirect '/'
    )(req,res,next)

  ##### googleAuth #####
  # Sets up the auth strategy with google.
  googleAuth: new GoogleStrategy
    clientID: process.env.G_CLIENT_ID
    clientSecret: process.env.G_CLIENT_SECRET
    callbackURL: "#{process.env.G_CALLBACK}/api/auth/google/callback"
  ,(token, refreshToken, profile, done)->
    ###
      Finds the matching user in the DB using the google info returned
      and logs in that user.
    ###
    query = User.filter r.row('auth')('google')('id').eq profile.id
    crudRead query
      .then (user)->
        done null, user, new: false
      .catch (err)->
        if err.status is 404
          ###
            If no user is found then we can create a new one and log them in.
          ###
          newUser =
            auth:
              google:
                id: profile.id
                token: token
                name: profile.displayName
                email: profile.emails[0].value
          createUser newUser
            .then (createdUser)->
              done null, createdUser, new: true
            .catch (err)->
              done err, false
        else
          done err, false

  ##### roleCheck #####
  # Ensures the user has proper permissions.
  # @params: allowedRoles -> array
  # @returns: function (Express Middleware)
  roleCheck: (allowedRoles)->
    (req, res, next)->
      roles = req.user.roles
      pass = false
      if !allowedRoles or allowedRoles.length is 0 then allowedRoles = ['admin']
      for role in allowedRoles
        if roles.indexOf(role) != -1
          pass = true
          break
      if pass
        next()
      else
        res
          .status 403
          .send "You don't need one of these roles: #{allowedRoles}"
