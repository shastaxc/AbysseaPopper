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
  [16839087] = {id=16839087, name='Alkonost', required_items=S{2912}, required_key_items=S{}},
  [16839088] = {id=16839088, name='Arimaspi', required_items=S{2913}, required_key_items=S{}},
  [16839078] = {id=16839078, name='Ashtaerh the Gallvexed', required_items=S{2914}, required_key_items=S{}},
  [16839092] = {id=16839092, name='Bloodeye Vileberry', required_items=S{1467}, required_key_items=S{}},
  [16839095] = {id=16839095, name='Bloodeye Vileberry', required_items=S{1467}, required_key_items=S{}},
  [16839098] = {id=16839098, name='Bloodeye Vileberry', required_items=S{1467}, required_key_items=S{}},
  [16839084] = {id=16839084, name='Bloodguzzler', required_items=S{2903}, required_key_items=S{}},
  [16839080] = {id=16839080, name='Bombadeel', required_items=S{2909}, required_key_items=S{}},
  [16839085] = {id=16839085, name='Clingy Clare', required_items=S{2907}, required_key_items=S{}},
  [16839090] = {id=16839090, name='Eccentric Eve', required_items=S{}, required_key_items=S{1459, 1460, 1461, 1462, 1463}},
  [16839093] = {id=16839093, name='Eccentric Eve', required_items=S{}, required_key_items=S{1459, 1460, 1461, 1462, 1463}},
  [16839096] = {id=16839096, name='Eccentric Eve', required_items=S{}, required_key_items=S{1459, 1460, 1461, 1462, 1463}},
  [16839089] = {id=16839089, name='Fear Gorta', required_items=S{2905}, required_key_items=S{}},
  [16839081] = {id=16839081, name='Hexenpilz', required_items=S{2908}, required_key_items=S{}},
  [16839082] = {id=16839082, name='Keratyrannos', required_items=S{2910}, required_key_items=S{}},
  [16839091] = {id=16839091, name='Kukulkan', required_items=S{}, required_key_items=S{1464, 1465, 1466}},
  [16839094] = {id=16839094, name='Kukulkan', required_items=S{}, required_key_items=S{1464, 1465, 1466}},
  [16839097] = {id=16839097, name='Kukulkan', required_items=S{}, required_key_items=S{1464, 1465, 1466}},
  [16839083] = {id=16839083, name='Lentor', required_items=S{2904}, required_key_items=S{}},
  [16839079] = {id=16839079, name='Sarcophilus', required_items=S{2911}, required_key_items=S{}},
  [16839086] = {id=16839086, name='Siranpa-kamuy', required_items=S{2906}, required_key_items=S{}},
  -- Abyssea - Tahrongi
  [16961961] = {id=16961961, name='Abas', required_items=S{2922}, required_key_items=S{}},
  [16961962] = {id=16961962, name='Alectryon', required_items=S{2923, 2949}, required_key_items=S{}},
  [16961957] = {id=16961957, name='Cannered Noz', required_items=S{2918}, required_key_items=S{}},
  [16961966] = {id=16961966, name='Chloris', required_items=S{}, required_key_items=S{1468, 1469, 1470, 1471}},
  [16961969] = {id=16961969, name='Chloris', required_items=S{}, required_key_items=S{1468, 1469, 1470, 1471}},
  [16961972] = {id=16961972, name='Chloris', required_items=S{}, required_key_items=S{1468, 1469, 1470, 1471}},
  [16961959] = {id=16961959, name='Gancanagh', required_items=S{2920}, required_key_items=S{}},
  [16961967] = {id=16961967, name='Glavoid', required_items=S{}, required_key_items=S{1472, 1473, 1474, 1475}},
  [16961970] = {id=16961970, name='Glavoid', required_items=S{}, required_key_items=S{1472, 1473, 1474, 1475}},
  [16961973] = {id=16961973, name='Glavoid', required_items=S{}, required_key_items=S{1472, 1473, 1474, 1475}},
  [16961954] = {id=16961954, name='Halimede', required_items=S{2915}, required_key_items=S{}},
  [16961960] = {id=16961960, name='Hedetet', required_items=S{2921, 2948}, required_key_items=S{}},
  [16961965] = {id=16961965, name='Lachrymater', required_items=S{2926}, required_key_items=S{}},
  [16961968] = {id=16961968, name='Lacovie', required_items=S{}, required_key_items=S{1476, 1477}},
  [16961971] = {id=16961971, name='Lacovie', required_items=S{}, required_key_items=S{1476, 1477}},
  [16961974] = {id=16961974, name='Lacovie', required_items=S{}, required_key_items=S{1476, 1477}},
  [16961964] = {id=16961964, name='Muscaliet', required_items=S{2925, 2950}, required_key_items=S{}},
  [16961956] = {id=16961956, name='Ophanim', required_items=S{2917, 2945, 2946}, required_key_items=S{}},
  [16961963] = {id=16961963, name='Tefenet', required_items=S{2924}, required_key_items=S{}},
  [16961958] = {id=16961958, name='Treble Noctules', required_items=S{2919, 2947}, required_key_items=S{}},
  [16961955] = {id=16961955, name='Vetehinen', required_items=S{2916}, required_key_items=S{}},
  -- Abyssea - La Theine
  [17318476] = {id=17318476, name='Adamaster', required_items=S{2894}, required_key_items=S{}},
  [17318480] = {id=17318480, name='Baba Yaga', required_items=S{2898}, required_key_items=S{}},
  [17318485] = {id=17318485, name='Briareus', required_items=S{}, required_key_items=S{1482, 1483, 1484}},
  [17318488] = {id=17318488, name='Briareus', required_items=S{}, required_key_items=S{1482, 1483, 1484}},
  [17318491] = {id=17318491, name='Briareus', required_items=S{}, required_key_items=S{1482, 1483, 1484}},
  [17318486] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318489] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318492] = {id=17318489, name='Carabosse', required_items=S{}, required_key_items=S{1485, 1486}},
  [17318479] = {id=17318479, name='La Theine Liege', required_items=S{2897}, required_key_items=S{}},
  [17318473] = {id=17318473, name='Dozing Dorian', required_items=S{2891}, required_key_items=S{}},
  [17318478] = {id=17318478, name='Grandgousier', required_items=S{2896}, required_key_items=S{}},
  [17318490] = {id=17318490, name='Hadhayosh', required_items=S{}, required_key_items=S{1478, 1479, 1480, 1481}},
  [17318484] = {id=17318484, name='Lugarhoo', required_items=S{2902}, required_key_items=S{}},
  [17318475] = {id=17318475, name='Megantereon', required_items=S{2893}, required_key_items=S{}},
  [17318481] = {id=17318481, name='Nguruvilu', required_items=S{2899}, required_key_items=S{}},
  [17318477] = {id=17318477, name='Pantagruel', required_items=S{2895}, required_key_items=S{}},
  [17318482] = {id=17318482, name='Poroggo Dom Juan', required_items=S{2900}, required_key_items=S{}},
  [17318483] = {id=17318483, name='Toppling Tuber', required_items=S{2901}, required_key_items=S{}},
  [17318474] = {id=17318474, name='Trudging Thomas', required_items=S{2892}, required_key_items=S{}},
  -- Abyssea - Attohwa
  [17658359] = {id=17658359, name='Berstuk', required_items=S{3080}, required_key_items=S{}},
  [17658352] = {id=17658352, name='Blazing Eruca', required_items=S{3073}, required_key_items=S{}},
  [17658356] = {id=17658356, name='Drekavac', required_items=S{3077}, required_key_items=S{}},
  [17658354] = {id=17658354, name='Gaizkin', required_items=S{3075}, required_key_items=S{}},
  [17658351] = {id=17658351, name='Granite Borer', required_items=S{3072}, required_key_items=S{}},
  [17658367] = {id=17658367, name='Itzpapalotl', required_items=S{}, required_key_items=S{1488, 1489, 1490}},
  [17658371] = {id=17658371, name='Itzpapalotl', required_items=S{}, required_key_items=S{1488, 1489, 1490}},
  [17658375] = {id=17658375, name='Itzpapalotl', required_items=S{}, required_key_items=S{1488, 1489, 1490}},
  [17658358] = {id=17658358, name='Kampe', required_items=S{3079}, required_key_items=S{}},
  [17658355] = {id=17658355, name='Kharon', required_items=S{3076}, required_key_items=S{}},
  [17658360] = {id=17658360, name='Maahes', required_items=S{3081}, required_key_items=S{}},
  [17658363] = {id=17658363, name='Mielikki', required_items=S{3084}, required_key_items=S{}},
  [17658361] = {id=17658361, name='Nightshade', required_items=S{3082}, required_key_items=S{}},
  [17658353] = {id=17658353, name='Pallid Percy', required_items=S{3074}, required_key_items=S{}},
  [17658364] = {id=17658364, name='Smok', required_items=S{}, required_key_items=S{1497}},
  [17658368] = {id=17658368, name='Smok', required_items=S{}, required_key_items=S{1497}},
  [17658372] = {id=17658372, name='Smok', required_items=S{}, required_key_items=S{1497}},
  [17658357] = {id=17658357, name='Svarbhanu', required_items=S{3078}, required_key_items=S{}},
  [17658365] = {id=17658365, name='Titlacauan', required_items=S{}, required_key_items=S{1493, 1494, 1495, 1496}},
  [17658369] = {id=17658369, name='Titlacauan', required_items=S{}, required_key_items=S{1493, 1494, 1495, 1496}},
  [17658373] = {id=17658373, name='Titlacauan', required_items=S{}, required_key_items=S{1493, 1494, 1495, 1496}},
  [17658366] = {id=17658366, name='Ulhuadshi', required_items=S{}, required_key_items=S{1491, 1492}},
  [17658370] = {id=17658370, name='Ulhuadshi', required_items=S{}, required_key_items=S{1491, 1492}},
  [17658374] = {id=17658374, name='Ulhuadshi', required_items=S{}, required_key_items=S{1491, 1492}},
  [17658362] = {id=17658362, name='Wherwetrice', required_items=S{3083}, required_key_items=S{}},
  -- Abyssea - Misareaux
  [17662569] = {id=17662569, name='Amhuluk', required_items=S{}, required_key_items=S{1501, 1502, 1503}},
  [17662573] = {id=17662573, name='Amhuluk', required_items=S{}, required_key_items=S{1501, 1502, 1503}},
  [17662577] = {id=17662577, name='Amhuluk', required_items=S{}, required_key_items=S{1501, 1502, 1503}},
  [17662563] = {id=17662563, name='Avalerion', required_items=S{3092}, required_key_items=S{}},
  [17662560] = {id=17662560, name='Cep-Kamuy', required_items=S{3089}, required_key_items=S{}},
  [17662568] = {id=17662568, name='Cirein-croin', required_items=S{}, required_key_items=S{1504, 1505}},
  [17662572] = {id=17662572, name='Cirein-croin', required_items=S{}, required_key_items=S{1504, 1505}},
  [17662576] = {id=17662576, name='Cirein-croin', required_items=S{}, required_key_items=S{1504, 1505}},
  [17662558] = {id=17662558, name='Funereal Apkallu', required_items=S{3087}, required_key_items=S{}},
  [17662561] = {id=17662561, name='Ironclad Observer', required_items=S{3090}, required_key_items=S{}},
  [17662571] = {id=17662571, name='Ironclad Pulverizer', required_items=S{}, required_key_items=S{1506, 1507}},
  [17662575] = {id=17662575, name='Ironclad Pulverizer', required_items=S{}, required_key_items=S{1506, 1507}},
  [17662579] = {id=17662579, name='Ironclad Pulverizer', required_items=S{}, required_key_items=S{1506, 1507}},
  [17662564] = {id=17662564, name='Karkatakam', required_items=S{3093, 3094}, required_key_items=S{}},
  [17662559] = {id=17662559, name='Manohra', required_items=S{3088}, required_key_items=S{}},
  [17662556] = {id=17662556, name='Minax Bugard', required_items=S{3085}, required_key_items=S{}},
  [17662562] = {id=17662562, name='Nehebkau', required_items=S{3091}, required_key_items=S{}},
  [17662565] = {id=17662565, name='Nonno', required_items=S{3095}, required_key_items=S{}},
  [17662567] = {id=17662567, name='Npfundlwa', required_items=S{3097}, required_key_items=S{}},
  [17662557] = {id=17662557, name='Sirrush', required_items=S{3086}, required_key_items=S{}},
  [17662570] = {id=17662570, name='Sobek', required_items=S{}, required_key_items=S{1498, 1499, 1500}},
  [17662574] = {id=17662574, name='Sobek', required_items=S{}, required_key_items=S{1498, 1499, 1500}},
  [17662578] = {id=17662578, name='Sobek', required_items=S{}, required_key_items=S{1498, 1499, 1500}},
  [17662566] = {id=17662566, name='Tuskertrap', required_items=S{3096}, required_key_items=S{}},
  -- Abyssea - Vunkerl
  [17666585] = {id=17666585, name='Armillaria', required_items=S{3107}, required_key_items=S{}},
  [17666596] = {id=17666596, name='Bukhis', required_items=S{}, required_key_items=S{1508, 1509, 1510}},
  [17666588] = {id=17666588, name='Bukhis', required_items=S{}, required_key_items=S{1508, 1509, 1510}},
  [17666592] = {id=17666592, name='Bukhis', required_items=S{}, required_key_items=S{1508, 1509, 1510}},
  [17666584] = {id=17666584, name='Chhir Batti', required_items=S{3106}, required_key_items=S{}},
  [17666590] = {id=17666590, name='Durinn', required_items=S{}, required_key_items=S{1513, 1514, 1515}},
  [17666594] = {id=17666594, name='Durinn', required_items=S{}, required_key_items=S{1513, 1514, 1515}},
  [17666598] = {id=17666598, name='Durinn', required_items=S{}, required_key_items=S{1513, 1514, 1515}},
  [17666579] = {id=17666579, name='Dvalinn', required_items=S{3101}, required_key_items=S{}},
  [17666587] = {id=17666587, name='Gnawtooth Gary', required_items=S{3109}, required_key_items=S{}},
  [17666578] = {id=17666578, name='Iku-Turso', required_items=S{3100}, required_key_items=S{}},
  [17666580] = {id=17666580, name='Kadraeth the Hatespawn', required_items=S{3102}, required_key_items=S{}},
  [17666591] = {id=17666591, name='Karkadann', required_items=S{}, required_key_items=S{1516, 1517}},
  [17666595] = {id=17666595, name='Karkadann', required_items=S{}, required_key_items=S{1516, 1517}},
  [17666599] = {id=17666599, name='Karkadann', required_items=S{}, required_key_items=S{1516, 1517}},
  [17666576] = {id=17666576, name='Khalkotaur', required_items=S{3098}, required_key_items=S{}},
  [17666586] = {id=17666586, name='Pascerpot', required_items=S{3108}, required_key_items=S{}},
  [17666577] = {id=17666577, name='Quasimodo', required_items=S{3099}, required_key_items=S{}},
  [17666581] = {id=17666581, name='Rakshas', required_items=S{3103}, required_key_items=S{}},
  [17666589] = {id=17666589, name='Sedna', required_items=S{}, required_key_items=S{1511, 1512}},
  [17666593] = {id=17666593, name='Sedna', required_items=S{}, required_key_items=S{1511, 1512}},
  [17666597] = {id=17666597, name='Sedna', required_items=S{}, required_key_items=S{1511, 1512}},
  [17666582] = {id=17666582, name='Seps', required_items=S{3104}, required_key_items=S{}},
  [17666583] = {id=17666583, name='Xan', required_items=S{3105}, required_key_items=S{}},
  -- Abyssea - Altepa
  [17670592] = {id=17670592, name='Amarok', required_items=S{3231, 3232, 3238}, required_key_items=S{}},
  [17670604] = {id=17670604, name='Bennu', required_items=S{}, required_key_items=S{1522}},
  [17670608] = {id=17670608, name='Bennu', required_items=S{}, required_key_items=S{1522}},
  [17670612] = {id=17670612, name='Bennu', required_items=S{}, required_key_items=S{1522}},
  [17670600] = {id=17670600, name='Bugul Noz', required_items=S{3243}, required_key_items=S{}},
  [17670598] = {id=17670598, name='Chickcharney', required_items=S{3240}, required_key_items=S{}},
  [17670603] = {id=17670603, name='Dragua', required_items=S{}, required_key_items=S{1521}},
  [17670607] = {id=17670607, name='Dragua', required_items=S{}, required_key_items=S{1521}},
  [17670611] = {id=17670611, name='Dragua', required_items=S{}, required_key_items=S{1521}},
  [17670594] = {id=17670594, name='Emperador de Altepa', required_items=S{3234, 3244}, required_key_items=S{}},
  [17670591] = {id=17670591, name='Ironclad Smiter', required_items=S{3230, 3236}, required_key_items=S{}},
  [17670602] = {id=17670602, name='Orthrus', required_items=S{}, required_key_items=S{1520}},
  [17670606] = {id=17670606, name='Orthrus', required_items=S{}, required_key_items=S{1520}},
  [17670610] = {id=17670610, name='Orthrus', required_items=S{}, required_key_items=S{1520}},
  [17670601] = {id=17670601, name='Rani', required_items=S{}, required_key_items=S{1518, 1519}},
  [17670605] = {id=17670605, name='Rani', required_items=S{}, required_key_items=S{1518, 1519}},
  [17670609] = {id=17670609, name='Rani', required_items=S{}, required_key_items=S{1518, 1519}},
  [17670596] = {id=17670596, name='Sharabha', required_items=S{3237}, required_key_items=S{}},
  [17670593] = {id=17670593, name='Shaula', required_items=S{3233, 3242}, required_key_items=S{}},
  [17670595] = {id=17670595, name='Tablilla', required_items=S{3235}, required_key_items=S{}},
  [17670599] = {id=17670599, name='Vadleany', required_items=S{3241}, required_key_items=S{}},
  [17670597] = {id=17670597, name='Waugyl', required_items=S{3239}, required_key_items=S{}},
  -- Abyssea - Uleguerand
  [17813956] = {id=17813956, name='Anemic Aloysius', required_items=S{3255}, required_key_items=S{}},
  [17813960] = {id=17813960, name='Apademak', required_items=S{}, required_key_items=S{1525}},
  [17813964] = {id=17813964, name='Apademak', required_items=S{}, required_key_items=S{1525}},
  [17813968] = {id=17813968, name='Apademak', required_items=S{}, required_key_items=S{1525}},
  [17813958] = {id=17813958, name='Audumbla', required_items=S{3258}, required_key_items=S{}},
  [17813951] = {id=17813951, name='Blanga', required_items=S{3248, 3257}, required_key_items=S{}},
  [17813957] = {id=17813957, name='Chillwing Hwitti', required_items=S{3256}, required_key_items=S{}},
  [17813950] = {id=17813950, name='Dhorme Khimaira', required_items=S{3246, 3247, 3253}, required_key_items=S{}},
  [17813949] = {id=17813949, name='Ironclad Triturator', required_items=S{3245, 3251}, required_key_items=S{}},
  [17813961] = {id=17813961, name='Isgebind', required_items=S{}, required_key_items=S{1526}},
  [17813965] = {id=17813965, name='Isgebind', required_items=S{}, required_key_items=S{1526}},
  [17813969] = {id=17813969, name='Isgebind', required_items=S{}, required_key_items=S{1526}},
  [17813953] = {id=17813953, name='Koghatu', required_items=S{3250}, required_key_items=S{}},
  [17813959] = {id=17813959, name='Pantokrator', required_items=S{}, required_key_items=S{1523, 1524}},
  [17813963] = {id=17813963, name='Pantokrator', required_items=S{}, required_key_items=S{1523, 1524}},
  [17813967] = {id=17813967, name='Pantokrator', required_items=S{}, required_key_items=S{1523, 1524}},
  [17813962] = {id=17813962, name='Resheph', required_items=S{}, required_key_items=S{1527}},
  [17813966] = {id=17813966, name='Resheph', required_items=S{}, required_key_items=S{1527}},
  [17813970] = {id=17813970, name='Resheph', required_items=S{}, required_key_items=S{1527}},
  [17813954] = {id=17813954, name='Upas-Kamuy', required_items=S{3252}, required_key_items=S{}},
  [17813955] = {id=17813955, name='Veri Selen', required_items=S{3254}, required_key_items=S{}},
  [17813952] = {id=17813952, name='Yaguarogui', required_items=S{3249, 3259}, required_key_items=S{}},
  -- Abyssea - Grauberg
  -- [00000000] = {id=00000000, name='Alfard', required_items=S{}, required_key_items=S{1530}},
  -- [00000000] = {id=00000000, name='Amphitrite', required_items=S{}, required_key_items=S{1532}},
  -- [00000000] = {id=00000000, name='Azdaja', required_items=S{}, required_key_items=S{1531}},
  -- [00000000] = {id=00000000, name='Azdaja', required_items=S{}, required_key_items=S{1531}},
  -- [00000000] = {id=00000000, name='Azdaja', required_items=S{}, required_key_items=S{1531}},
  -- [00000000] = {id=00000000, name='Bomblix Flamefinger', required_items=S{3274, 3264}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Burstrox Powderpate', required_items=S{3273}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Ika-Roa', required_items=S{3270}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Ironclad Sunderer', required_items=S{3260, 3266}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Lorelei', required_items=S{3271}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Minaruja', required_items=S{3267}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Ningishzida', required_items=S{3261, 3262, 3268}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Raja', required_items=S{}, required_key_items=S{1528, 1529}},
  -- [00000000] = {id=00000000, name='Teekesselchen', required_items=S{3265}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Teugghia', required_items=S{3263, 3272}, required_key_items=S{}},
  -- [00000000] = {id=00000000, name='Xibalba', required_items=S{3269}, required_key_items=S{}},
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
