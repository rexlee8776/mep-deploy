local BasePlugin = require "kong.plugins.base_plugin"
local jwt_decoder = require "kong.plugins.jwt.jwt_parser"


local kong = kong
local type = type
local re_gmatch = ngx.re.gmatch

local AddAppIdHeaderHandler = {}


AddAppIdHeaderHandler.VERSION  = "1.0.0"
AddAppIdHeaderHandler.PRIORITY = 10


local function retrieve_token(conf)
  local request_headers = kong.request.get_headers()
  local token_header = request_headers["authorization"]
  if token_header then
    if type(token_header) == "table" then
      token_header = token_header[1]
    end
    local iterator, iter_err = re_gmatch(token_header, "\\s*[Bb]earer\\s+(.+)")
    if not iterator then
      kong.log.err(iter_err)
    end

    local m, err = iterator()
    if err then
      kong.log.err(err)
    end

    if m and #m >0 then
      return m[1]
    end
  end
end


local function add_app_id(conf)
  local token, err = retrieve_token(conf)
  if err then
    kong.log.err(err)
    return kong.response.exit(500, { message = "Unexpected error." })
  end

  local jwt, err = jwt_decoder:new(token)

  local claims = jwt.claims
  
  local app_id = claims["sub"]
  kong.log("****app_id=****XXXXXXXXXX", app_id)

  local set_header = kong.service.request.set_header
  local clear_header = kong.service.request.clear_header
  clear_header("X-AppinstanceID")
  set_header("X-AppinstanceID", app_id)
  return true
end


function AddAppIdHeaderHandler:access(conf)
  local ok, err = add_app_id(conf)
  if err then
    kong.log.err(err)
    return kong.response.exit(500, { message = "Unexpected error."})
  end
end

return AddAppIdHeaderHandler
