---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 1:25 PM
---
--local core_t = require('trends.core')
--local core = core_t:new()
--core:run()
ENV_DATACENTER = os.getenv('ENV_DATACENTER')
ngx.say(ENV_DATACENTER)