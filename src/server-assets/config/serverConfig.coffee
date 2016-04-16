_ = require 'lodash'

module.exports =
  port: process.env.PORT || process.env.EXPRESS_PORT || 9999
  logger: (req, res, next)->
    console.log "#{req.method} request to >>>> #{req.originalUrl}"
    if !_.isEmpty req.body
      console.log 'REQ BODY >>>>', req.body
    if !_.isEmpty req.params
      console.log 'REQ PARAMETERS >>>>', req.params
    next()
