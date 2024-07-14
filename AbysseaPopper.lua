-- Copyright © 2023-2024, Shasta
-- All rights reserved.

-- Redistribution and use in source and binary forms, with or without
-- modification, are permitted provided that the following conditions are met:

--     * Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--     * Redistributions in binary form must reproduce the above copyright
--       notice, this list of conditions and the following disclaimer in the
--       documentation and/or other materials provided with the distribution.
--     * Neither the name of Metronome nor the
--       names of its contributors may be used to endorse or promote products
--       derived from this software without specific prior written permission.

-- THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
-- ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
-- DISCLAIMED. IN NO EVENT SHALL Shasta BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
-- (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
-- LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
-- ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
-- (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

_addon.name = 'AbysseaPopper'
_addon.author = 'Shasta'
_addon.version = '1.0.0'
_addon.commands = {'ap','apop','abysseapopper'}

-------------------------------------------------------------------------------
-- Includes/imports
-------------------------------------------------------------------------------
require('tables')
require('sets')

res = require('resources')
packets = require('packets')
-- inspect = require('inspect')

chat_purple = string.char(0x1F, 200)
chat_grey = string.char(0x1F, 160)
chat_red = string.char(0x1F, 167)
chat_white = string.char(0x1F, 001)
chat_green = string.char(0x1F, 214)
chat_yellow = string.char(0x1F, 036)
chat_d_blue = string.char(0x1F, 207)
chat_pink = string.char(0x1E, 5)
chat_l_blue = string.char(0x1E, 6)

inline_white = '\\cs(255,255,255)'
inline_red = '\\cs(255,0,0)'
inline_green = '\\cs(0,255,0)'
inline_blue = '\\cs(0,0,255)'
inline_gray = '\\cs(170,170,170)'

abyssea_areas = S{
  'Abyssea - Konschtat',
  'Abyssea - Tahrongi',
  'Abyssea - La Theine',
  'Abyssea - Attohwa',
  'Abyssea - Misareaux',
  'Abyssea - Vunkerl',
  'Abyssea - Altepa',
  'Abyssea - Uleguerand',
  'Abyssea - Grauberg',
}

-- Index by spawn point ID
pop_info = T{
  -- La Theine Liege
  [17318479] = {id=17318479, name='La Theine Liege', required_items=S{2897}, required_key_items=S{}},
  -- Baba Yaga
  [17318480] = {id=17318480, name='Baba Yaga', required_items=S{2898}, required_key_items=S{}},
  -- Carabosse
  [17318486] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318489] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318492] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
}
-- Replace required_items and required_key_items with more detailed objects
for entry in pop_info:it() do
  local req_items = entry.required_items:copy(true)
  entry.required_items = S{}
  for item_id in req_items:it() do
    local res_item = res.items[item_id]
    if res_item then
      local new_item = {id=res_item.id, en=res_item.en, enl=res_item.enl, ja=res_item.ja, jal=res_item.jal}
      entry.required_items:append(new_item)
    end
  end

  local req_ki = entry.required_key_items:copy(true)
  entry.required_key_items = S{}
  for ki_id in req_ki:it() do
    local res_item = res.key_items[ki_id]
    if res_item then
      local new_item = {id=res_item.id, en=res_item.en, ja=res_item.ja}
      entry.required_key_items:append(new_item)
    end
  end
end

function init(force_init)
  player = {} -- Player status
  world = {} -- World info
  update_player_info()
  refresh_ffxi_info()
end

-- Update player info
function update_player_info()
  local player_info = windower.ffxi.get_player()
  if player_info then
    player.id = player_info.id
    player.name = player_info.name
  end
end

function refresh_ffxi_info()
  local info = windower.ffxi.get_info()
  local zone = info['zone']
  if zone and res.zones[zone] then
    world.zone = res.zones[zone].en
    world.area = world.zone
  end
end

function get_target()
  local npc = windower.ffxi.get_mob_by_target('t')
  if npc then
    if math.sqrt(npc.distance) < 6 then
      return npc
    else
      windower.add_to_chat(001, chat_red..'AbysseaPopper: Target out of range.')
    end
  end
end

-- Attempt to pop NM based on current target
function pop_target()
  -- Get target info
  local t = get_target()
  if t then
    local info = pop_info[t.id]
    if info then
      -- If NM requires items to pop, attempt to trade
      if info.required_items:length() > 0 then
        if info.required_items:length() == 1 then
          -- If only 1 required item, we can use in-game command to pop
          local req_item = info.required_items[1]
          windower.send_command('@input /item "'..req_item.en..'" <t>')
        end
      elseif info.required_key_items:length() > 0 then
        -- If NM requires key items to pop, deal with the popup menu
      end
    end
  end
end

function is_in_abyssea()
  if abyssea_areas:contains(world.area) then
    return true
  end

  return false
end

-- Takes optional target_id
function get_pop_info(target_id)
  if is_in_abyssea() then
    if target_id then
      return pop_info[target_id]
    else
      local target = get_target()
      if target then
        return pop_info[target.id]
      else
        return 'missing_target'
      end
    end
  end

  return nil
end

windower.register_event('load', function()
  if windower.ffxi.get_player() then
    init()
  end
end)

windower.register_event('zone change', function(new_id, old_id)
  world.zone = res.zones[new_id].en
  world.area = world.zone
end)

windower.register_event('addon command', function(cmd, ...)
  local cmd = cmd and cmd:lower()
  local args = {...}
  -- Force all args to lowercase
  for k,v in ipairs(args) do
    args[k] = v:lower()
  end

  if cmd then
    if S{'reload', 'r'}:contains(cmd) then
      windower.send_command('lua r abysseapopper')
      windower.add_to_chat(001, chat_d_blue..'AbysseaPopper: Reloading.')
    elseif S{'trade', 'pop', 'spawn'}:contains(cmd) then
      -- If in Abyssea, attempt to pop target
      if is_in_abyssea() then
        pop_target()
      end
    elseif 'info' == cmd then
      local pop_info = get_pop_info()
      if pop_info then
        if pop_info == 'missing_target' then
          windower.add_to_chat(001, chat_d_blue..'AbysseaPopper: No target selected.')
        else
          windower.add_to_chat(001, chat_d_blue..'AbysseaPopper: '..pop_info.name..' pops here.')
        end
      else
        windower.add_to_chat(001, chat_d_blue..'AbysseaPopper: This is not a supported pop location.')
      end
    elseif 'test' == cmd then
    elseif 'help' == cmd then
      windower.add_to_chat(6, ' ')
      windower.add_to_chat(6, chat_d_blue.. 'AbysseaPopper Commands available:' )
      windower.add_to_chat(6, chat_l_blue..	'//ap help ' .. chat_white .. ': Display this help menu again')
      windower.add_to_chat(6, chat_l_blue..	'//ap r' .. chat_white .. ': Reload addon')
      windower.add_to_chat(6, chat_l_blue..	'//ap pop' .. chat_white .. ': Pop NM at targeted point')
      windower.add_to_chat(6, chat_l_blue..	'//ap info' .. chat_white .. ': Report which NM pops at targeted point')
    else
      windower.send_command('abysseapopper help')
    end
  else
    windower.send_command('abysseapopper help')
  end
end)
