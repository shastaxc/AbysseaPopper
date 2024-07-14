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
require('pack')

res = require('resources')
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

allowed_trade_status = S{
  0, --Idle
  33, --Resting
  47, --Sitting
  48, --Kneeling
  63, --Sitchair 0
  64, --Sitchair 1
  65, --Sitchair 2
  66, --Sitchair 3
  67, --Sitchair 4
  68, --Sitchair 5
  69, --Sitchair 6
  70, --Sitchair 7
  71, --Sitchair 8
  72, --Sitchair 9
  73, --Sitchair 10
  74, --Sitchair 11
  75, --Sitchair 12
}

-- Index by spawn point ID
pop_info = T{
  -- Abyssea - Konschtat
  -- Abyssea - Tahrongi
  -- Abyssea - La Theine
  [17318479] = {id=17318479, name='La Theine Liege', required_items=S{2897}, required_key_items=S{}},
  [17318480] = {id=17318480, name='Baba Yaga', required_items=S{2898}, required_key_items=S{}},
  [17318486] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318489] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318492] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  -- Abyssea - Attohwa
  -- Abyssea - Misareaux
  [17662564] = {id=17662564, name='Karkatakam', required_items=S{3093, 3094}, required_key_items=S{}},
  -- Abyssea - Vunkerl
  -- Abyssea - Altepa
  -- Abyssea - Uleguerand
  -- Abyssea - Grauberg
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
    world.zone_id = zone
    world.area_id = zone
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

-- Returns table of the required items (indexed by item ID) that includes
-- their position in player inventory. If item is not found, it is excluded
-- from the returned table.
-- items_to_find: Set (required)
function items_in_inventory(items_to_find)
  local inventory = windower.ffxi.get_items(0)
  local found_items = T{}
  if inventory then
    for k,required_item in pairs(items_to_find) do
      for _,inv_item in pairs(inventory) do
        if inv_item and type(inv_item) == 'table' and inv_item.id == required_item.id then
          found_items[inv_item.id] = inv_item
          break
        end
      end
    end
  else
    windower.add_to_chat(001, chat_red..'AbysseaPopper: Inventory still loading.')
  end

  return found_items
end

-- Required items in resource file format. Set.
-- Found_items in windower.ffxi.get_items(bag) format. Meta Table.
-- Both lists have "id" field that can be used for comparison.
function str_missing_items(required_items, found_items)
  local str = ''
  local num_missing = 0
  for _,req_item in pairs(required_items) do
    if not found_items[req_item.id] then
      num_missing = num_missing + 1
      -- Item is missing, add to list
      -- Add delineator if not the first missing item.
      if num_missing > 1 then
        str = str..', '
      end
      str = str..req_item.en
    end
  end

  return str
end

-- Attempt to pop NM based on current target
function pop_target()
  -- Get target info
  local target = get_target()
  if target then
    local info = pop_info[target.id]
    if info then
      -- If NM requires items to pop, attempt to trade
      if info.required_items:length() > 0 then
        -- Check if items are in inventory. If not, display warning.
        local found_inv_items = items_in_inventory(info.required_items)
        if found_inv_items:length() < info.required_items:length() then
          -- Not all items found in inventory. Display warning.
          local missing_items = str_missing_items(info.required_items, found_inv_items)
          windower.add_to_chat(001, chat_d_blue..'AbysseaPopper: Missing items ['..missing_items..'].')
        else -- Not missing items
          if info.required_items:length() == 1 then
            -- If only 1 required item, we can use in-game command to pop
            local req_item = info.required_items[1]
            windower.send_command('@input /item "'..req_item.en..'" <t>')
          else
            -- Trade multiple items, bypassing trade window.
            send_trade_packet(target, found_inv_items)
          end
        end
      elseif info.required_key_items:length() > 0 then
        -- If spawn point requires key items, maybe handle this in the future
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

-- Returns true if player if in a status that is allowed to perform trades.
-- For example, will return false if player is dead or mounted.
function is_status_valid()
  local player_status = windower.ffxi.get_mob_by_target('me').status
  return allowed_trade_status:contains(player_status)
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

-- Input: Meta Table. Indexed by item ID. Format of windower.ffxi.get_items(0).
-- The input table includes the item ID and position in inventory, needed to trade.
function send_trade_packet(target, found_inv_items)
  -- Quantity array (first item is gil)
  local qty = {
    [1] = 0,
  }
  -- Inventory index array (first item is gil)
  local ind = {
    [1] = 0,
  }

  -- Count of items to trade
  local count = 0

  for item_id, item in pairs(found_inv_items) do
    count = count + 1
    qty[count + 1] = 1
    ind[count + 1] = item.slot
  end

  -- Fill the rest of the arrays
  for i=count+2,9 do
    qty[i] = 0
    ind[i] = 0
  end

  local menu_item = ('C4I11C10HI'):pack(0x36,0x20,0x00,0x00, target.id,
      qty[1],qty[2],qty[3],qty[4],qty[5],qty[6],qty[7],qty[8],qty[9],0x00,
      ind[1],ind[2],ind[3],ind[4],ind[5],ind[6],ind[7],ind[8],ind[9],0x00,
      target.index, count+1)

  windower.packets.inject_outgoing(0x36, menu_item)
end

windower.register_event('load', function()
  if windower.ffxi.get_player() then
    init()
  end
end)

windower.register_event('zone change', function(new_id, old_id)
  world.zone_id = new_id
  world.area_id = new_id
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
      if is_in_abyssea() and is_status_valid() then
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
