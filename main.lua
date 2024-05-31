local ui = require "ui"
local net = require "net"

local languageCodes = {
  {"en", "English"},
  {"es", "Spanish"},
  {"ru", "Russian"},
  {"de", "German"},
  {"fr", "French"},
  {"pl", "Polish"},
  {"cs", "Czech"},
  {"sk", "Slovak"},
  {"ar", "Arabic"},
}

function translate(text, source_lang, target_lang)
  net.Http("https://translate.googleapis.com"):get(string.format("/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s", source_lang, target_lang, text)).after = function (client, response)
    _, _, rest = string.find(response.content, "^....(.-)\".*$")
  end
  waitall()
  return rest
end

function comboToIndex(combo)
    local i = tonumber(combo, 16)
    return i
end

local win = ui.Window("gTranslate", "single", 840*ui.dpi, 480*ui.dpi)
win.bgcolor = 0x313338
local button = ui.Button(win, "Przetłumacz", 0, 480*ui.dpi-32*ui.dpi, 840*ui.dpi, 32*ui.dpi)
local entry = ui.Entry(win, "Wpisz co chcesz przetłumaczyć", 20*ui.dpi, 20*ui.dpi, 380*ui.dpi, 64*ui.dpi)
local outputEntry = ui.Entry(win, "Translated text here", 420*ui.dpi, 20*ui.dpi, 400*ui.dpi, 64*ui.dpi)
ui.theme = "dark"
outputEntry.enabled = false

local combo = ui.Combobox(win, {
    languageCodes[1][2],
    languageCodes[2][2],
    languageCodes[3][2],
    languageCodes[4][2],
    languageCodes[5][2],
    languageCodes[6][2],
    languageCodes[7][2],
    languageCodes[8][2],
    languageCodes[9][2],
}, 20*ui.dpi, 84*ui.dpi, 128*ui.dpi, 128*ui.dpi)
for i, v in ipairs(languageCodes) do
  combo.items[i]:loadicon(i..".ico")
end
combo.style = "icons"
combo.selected = combo.items[1]

local combo2 = ui.Combobox(win, {
    languageCodes[1][2],
    languageCodes[2][2],
    languageCodes[3][2],
    languageCodes[4][2],
    languageCodes[5][2],
    languageCodes[6][2],
    languageCodes[7][2],
    languageCodes[8][2],
    languageCodes[9][2],
}, 420*ui.dpi, 84*ui.dpi, 128*ui.dpi, 128*ui.dpi)
for i, v in ipairs(languageCodes) do
  combo2.items[i]:loadicon(i..".ico")
end
combo2.style = "icons"
combo2.selected = combo2.items[2]

function button:onClick()
	outputEntry.text = translate(entry.text, "pl", "en")
end

entry.fontsize = math.floor(14*ui.dpi)
outputEntry.fontsize = math.floor(14*ui.dpi)
button.fontsize = math.floor(12*ui.dpi)
win:show()
win:center()

repeat
    ui.update()
until not win.visible