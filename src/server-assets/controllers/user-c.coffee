q = require 'q'

{User}                 = require "#{__dirname}/../models/"
{crudCreate, crudRead} = require "#{__dirname}/../helpers/crudHelper"

module.exports =
    ##### createUser #####
  # Creates new user
  # @params: object
  # @resolves: userObj
  createUser: (newUser) ->
    dfd = q.defer()
    crudCreate User, newUser
    .then dfd.resolve
    .catch (err) ->
      dfd.reject msg: "An insert error occured: #{err.message}", status: 500
    dfd.promise

  ##### getUser #####
  # Gets a user by id or optionally cust query.
  # @params: id -> string
  # @params: query -> Thinky query chain
  # @resolves: userObj
  getUser: (id, query)->
    dfd = q.defer()
    if !query then query = User.get id
    crudRead query
      .then dfd.resolve
      .catch (err)->
        handleErr 'Getting user', err.message, dfd
    dfd.promise
