local typedefs = require "kong.db.schema.typedefs"


local schema = {
  name = "appid-header",
  fields = {
    { run_on = typedefs.run_on_first },
    { protocols = typedefs.protocols_http },
    { config = {
        -- The 'config' record is the custom part of the plugin schema
        type = "record",
        fields = {
        },
      },
    },
  },
}

return schema