---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 11:34 AM
---

-----------------------------------------------------------------------------
-- 处理ngx.ctx.log_data里面的日志数据字符串
-- 在log_by_lua_file指令集中使用
-- 在log_by_lua_code中不允许使用redis的tcp、udp，所以在下面代码中，使用timer定时器变通实现
--
-----------------------------------------------------------------------------

local logData = ngx.ctx.log_data
if logData == nil then
    return
end


--local cjson = require('cjson')
--local t_logData = cjson.decode(logData)
--ngx.log(ngx.ERR, 'processStartTime: '..t_logData.processStartTime .. ' processEndTime: '..t_logData.processEndTime .. ' processTotalTime: '..t_logData.processTotalTime )

local uid = ngx.ctx.uid -- 用户的uid
local whitelist_r = require('config.whitelist')
local uids = whitelist_r.uids -- 白名单列表
local utils_r = require('lib.utils')
local logger_r = require('api.log')
local logger = logger_r:new()

-----------------------------------------------------------------------------
-- 发送日志到Redis协议收集机
-- 白名单中的发送到Redis
-- Input
-- @param logData 日志字符串
-- Returns
-- @return
-----------------------------------------------------------------------------
local function sendToRedis(premature, logData)
    logger:logToRedis(logData)
end

-----------------------------------------------------------------------------
-- 发送日志到kafka收集机
-- 不在白名单中的发送到kafka
-- Input
-- @param logData 日志字符串
-- Returns
-- @return
-----------------------------------------------------------------------------
local function sendToKafka(premature, logData)
    logger:logToKafka(logData)
end

if uid ~= nil and utils_r.in_table(uid, uids) then
    local ok, err = ngx.timer.at(0, sendToRedis, logData)
    --    if not ok then
    --        ngx.log(ngx.ERR, "failed to create timer: ", err)
    --        return
    --    end
else
    -- 白名单以外的数据按照1‰的比例写redis
    local namespace = ngx.ctx.namespace or ''
    local ratio = namespace == 'log_100' and 1000 or 10;  --灰度比例，如果是tag 就灰度1000 否则灰度10
    local reTime = tostring(ngx.now()):reverse()
    local seed = reTime:sub(1, 3) .. reTime:sub(5, 7)
    math.randomseed(seed)
    local rand = math.random(1000)
    if rand <= ratio then
        local ok, err = ngx.timer.at(0, sendToRedis, logData)
    end
end

-- 这里加一个控制开关，用在特殊时期调节写磁盘的日志比例
local randomNum = math.random(1000)
if uid ~= nil and utils_r.in_table(uid, uids) or randomNum <= 10 then
    -- 日志全量写到文件里面
    local logger_r = require('api.log')
    local logger = logger_r:new()
    local logData = ngx.ctx.log_data
    local uid = ngx.ctx.uid
    local mid = ngx.ctx.mid
    local mark = ngx.ctx.mark
    local request_id = ngx.ctx.request_id
    local ad_uid = ngx.ctx.ad_uid
    logger:logToFile(logData, uid, mid, mark, request_id, ad_uid)
end

