express = require 'express'
app     = express()
######
# Add Routes and middleware here
######
require("#{__dirname}/config/middleware") app
require("#{__dirname}/routes/authRoutes") app

module.exports = app
