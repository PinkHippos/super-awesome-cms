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
      res.redirect '/api/auth/login'

  ##### logout #####
  # Logs out the user
  logout: (req, res, next)->
    console.log 'Logging out this user -->', req.user
    req.logout()
    req.session.destroy()
    res
      .status 204
      .redirect '/'

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
