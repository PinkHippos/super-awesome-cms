module.exports = (passport) ->
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

  passport.use 'local', localAuth
