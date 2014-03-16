Hapi = require 'hapi'
Nipple = require 'nipple'
querystring = require 'querystring'
_ = require 'lodash'
{parseString} = require 'xml2js'
{log} = console

server = Hapi.createServer 'localhost', 8000,
  cache: 'catbox-redis'
  cors: true
  json:
    space: 2

getBggEndpoint = (endpoint, params, next)->
  query = querystring.stringify params
  url = "http://boardgamegeek.com/xmlapi2/#{endpoint}?#{query}"
  opts = {}

  log "making request to: #{url}"
  Nipple.get url, opts, (err, res, payload)->
    if err
      return next err

    parseString payload, (err, result) ->
      next if err then err else result

MINUTE = 60 * 1000
HOUR = 60 * MINUTE
server.method 'getBggEndpoint', getBggEndpoint,
  cache:
    expiresIn: 6 * HOUR
  generateKey: (endpoint, params)->
    endpoint + JSON.stringify(params)

bggRoute = (name)->
  server.route
    method: 'GET'
    path: "/api/v1/#{name}"
    handler: (request, reply)->
      server.methods.getBggEndpoint name, request.query, (err, result)->
        reply if err then err else result

bggRoute route for route in [
  'thing'
  'family'
  'forumlist'
  'forum'
  'thread'
  'user'
  'guild'
  'plays'
  'collection'
  'hot'
  'search'
]

server.start()