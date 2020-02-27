---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 11:45 AM
---

local _M = {}

function _M.new(self)
    return setmetatable({
        cjson = require('cjson'),
        utils = require('lib.utils'),
        file_name = '',
    }, { __index = _M })
end

function _M.get_idc(self)
    local idc_config = require('config.idc')
    local value, msg = self:load_json(self.file_name)
    if not value then
        --ngx.log(ngx.ALERT, 'File does not exist ' .. msg .. self.file_name)
        return idc_config.default
    end
    local server_addr = value.server_addr
    local _a, _b, _c, _d = server_addr:match('(%d+).(%d+).(%d+).(%d+)')
    local prefix_ip = _a .. '.' .. _b

    local ip_idc_map = idc_config.idc_ip_map_config
    for ip, idc in pairs(ip_idc_map) do
        if ip == prefix_ip then
            return idc
        end
    end
    return idc_config.default

end

function _M.get_server_addr(self)
    local value, msg = self:load_json(self.file_name)
    if not value then
        ngx.log(ngx.ALERT, 'File does not exist ' .. self.file_name)
    end
    return value.server_addr or '127.0.0.1'
end


function _M._file_exists(file_name)
    local f = io.open(file_name,"r")
    if f ~= nil then
        io.close(f)
        return true
    else
        return false
    end
end


function _M._load_json(self, file_name)
    if not self._file_exists(file_name) then
        return nil, string.format("File %s: No such file or directory ", file_name)
    end
    local f = io.open(file_name, "r")
    local text = f:read("*a")
    local d = self.cjson.decode(text)
    return d,""
end

function _M.load_json(self, file_name)
    local status, value, msg = pcall(self._load_json, self, file_name)
    if not status then
        return nil, nil
    end
    return value, msg
end




return _M
