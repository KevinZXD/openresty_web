---
--- Generated by EmmyLua(https://github.com/EmmyLua)
--- Created by xudong12.
--- DateTime: 2020/2/26 1:34 PM
---
-----------------------------------------------------------------------------
-- 定义各场景和对应的模块信息以及处理文件
-- sm -> service module
-----------------------------------------------------------------------------

module(..., package.seeall)

-----------------------------------------------------------------------------

-- Input
-- @param
-- Returns
-- @return
-----------------------------------------------------------------------------
scene = {
    modules = {
        ['account'] = 'trends.sm.account',
        ['ad'] = 'trends.sm.ad',
    },
    context = '',
    init = '',
    prerender = '',
    scheduler = '',
    strategy = 'strategy.scene',
    render = '',
    postrequest = '',
    resp_raw_data = true,
}






