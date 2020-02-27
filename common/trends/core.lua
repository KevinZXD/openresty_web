---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 1:27 PM
---
-----------------------------------------------------------------------------
-- 网关处理器的核心处理文件
-- 组装处理默认的数据项
--
-----------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------
-- 构造方法
-- Input
-- @param self 自身对象
-- Returns
-- @return table 返回的对象里面包含程序处理开始时间，和默认返回结构
-----------------------------------------------------------------------------
function new(self)
    local utils = require('lib.utils')
    return setmetatable({ errno = 0, err = '', start_time = ngx.now(), final_resp = {} }, { __index = self })
end

-----------------------------------------------------------------------------
-- 组装处理默认的数据项
-- Input
-- @param self 自身对象
-- Returns
-- @return
-----------------------------------------------------------------------------
function run(self)
    local request_r = require('lib.request') -- request请求数据处理
    local init = require('trends.init') -- 给self常用几个字段赋值，初始化常用数据
    local services = require('config.services') -- 场景名称和处理文件对照表
    local strategy = require('trends.strategy') -- 场景策略
    local params_r = require('service.params') -- 格式化参数，场景和参数对应起来
    local scheduler = require('trends.scheduler') -- 并行调度处理各个请求
    local cjson = require('cjson') -- 引入json处理类

    self.request = request_r:new() -- 初始化请求参数
    self.services = services -- 场景和模块对应关系
    init.init(self) --初始化请求参数，此方法里面用到了self.request和self.services

    self:whiteList()

    self.pro_params, self.ex_product = params_r.get_product(self) -- 组装请求（可能有同时对多个产品线发起请求）里面的产品线和对应的参数
    -- pro -> product,ex -> exists.

    --scheduler  处理流程， services下多个modules的配置， 具体的调用在sm(service module)下面， 最后并行调用
    self.scheduler = scheduler.init(self)
    self.scheduler:run() -- 生成当前存在的产品线的各处理文件的对象，并执行调度方法
    self.strategy = strategy.init(self) -- 场景策略 services 配置（产品PM对一些场景提出的一些数据配置策略在此模块处理）
    local _resp = { ['errno'] = 0, ['error'] = '', ['data'] = {} }

    if self.scheduler.modules then -- 将各module返回的数据封装到data里
        for _, mo in pairs(self.scheduler.modules) do
            if mo.data  then
                for _, d in pairs(mo.data) do
                    table.insert(_resp.data, d)
                end
            elseif mo.data then
                table.insert(_resp.data, mo.data)
            end
        end
    end
    local f, resp_str = pcall(cjson.encode, _resp)
    if not f then
        resp_str = '{"errno": 99, "error":"encode error"}'
    end

    self.resp_str = resp_str
    ngx.print(resp_str) -- 返回给客户端请求处理结果数据
    ngx.eof()
    --self:finish()
end


----------------------------------------------------------------------------
-- 白名单定投工具返回定投数据
-- Input
-- @param self 自身对象
-- Returns
-- @return
----------------------------------------------------------------------------
function whiteList(self)
    ngx.say('执行白名单操作')

end
