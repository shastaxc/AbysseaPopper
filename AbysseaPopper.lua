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

function init(force_init)
  player = {} -- Player status
  tracker = {} -- Tracks enemies' step debuffs, keyed by enemy actor ID
  update_player_info()
end

-- Update player info
function update_player_info()
  local player_info = windower.ffxi.get_player()
  if player_info then
    player.id = player_info.id
    player.name = player_info.name
    player.main_job = player_info.main_job
    player.main_job_level = player_info.main_job_level
    player.sub_job = player_info.sub_job
    player.sub_job_level = player_info.sub_job_level
    player.merits = player_info.merits
    player.job_points = player_info.job_points
  end
end

windower.register_event('load', function()
  if windower.ffxi.get_player() then
    init()
  end
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
    elseif 'test' == cmd then
    elseif 'help' == cmd then
      windower.add_to_chat(6, ' ')
      windower.add_to_chat(6, chat_d_blue.. 'AbysseaPopper Commands available:' )
      windower.add_to_chat(6, chat_l_blue..	'//ap r' .. chat_white .. ': Reload addon')
      windower.add_to_chat(6, chat_l_blue..	'//met vis ' .. chat_white .. ': Toggle UI visibility')
      windower.add_to_chat(6, chat_l_blue..	'//met show ' .. chat_white .. ': Show UI')
      windower.add_to_chat(6, chat_l_blue..	'//met hide ' .. chat_white .. ': Hide UI')
      windower.add_to_chat(6, chat_l_blue..	'//met resetpos ' .. chat_white .. ': Reset position of UI to default')
      windower.add_to_chat(6, chat_l_blue..	'//met jobs ' .. chat_white .. ': Display show/hide based on job being DNC or not.')
      windower.add_to_chat(6, chat_l_blue..	'//met help ' .. chat_white .. ': Display this help menu again')
    else
      windower.send_command('met help')
    end
  else
    windower.send_command('met help')
  end
end)
