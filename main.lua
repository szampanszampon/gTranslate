local ui = require "ui"
local net = require "net"
local translations = require "translations"
local File = embed and embed.File or sys.File

local languageCodes = {
    {"en", "English"},
    {"es", "Spanish (~)"},
    {"ru", "Russian (~)"},
    {"de", "German (~)"},
    {"fr", "French"},
    {"pl", "Polish"},
    {"cs", "Czech (~)"},
    {"sk", "Slovak (~)"},
    {"ar", "Arabic (~)"},
    {"pt-BR", "Portuguese (Brazil)"},
}

local themesTable = {
    {"light", "Light Mode"},
    {"dark", "Dark Mode"},
    {"auto", "Auto"}
}

function getLanguageCode(selectedIndex)
    if selectedIndex < 1 or selectedIndex > #languageCodes then
        return languageCodes[1][1]
    else
        return languageCodes[selectedIndex][1]
    end
end

local win = ui.Window("gTranslate", "single", 840 * ui.dpi, 480 * ui.dpi)
local picture = ui.Picture(win, "bg.png", 0, 0, 840 * ui.dpi, 480 * ui.dpi)
local buttonTranslate = ui.Button(win, "Translate", 0, 480 * ui.dpi - 32 * ui.dpi, 708 * ui.dpi, 32 * ui.dpi)
local buttonSettings = ui.Button(win, "Settings", 708 * ui.dpi, 480 * ui.dpi - 32 * ui.dpi, 132 * ui.dpi, 32 * ui.dpi)
local entry = ui.Entry(win, "", 20 * ui.dpi, 20 * ui.dpi, 380 * ui.dpi, 64 * ui.dpi)
local outputEntry = ui.Entry(win, "Translated text here", 420 * ui.dpi, 20 * ui.dpi, 400 * ui.dpi, 64 * ui.dpi)
outputEntry.enabled = false

function setData(languageCode, theme)
    if theme ~= "auto" then
        ui.theme = theme
    else
        ui.theme = ui.systheme
    end
    if ui.theme == "dark" then
        win.bgcolor = 0x171717
    elseif ui.theme == "light" then
        win.bgcolor = 0xc9c9c9
    else
        theme = auto
    end
    buttonTranslate.text = currentTranslations.buttonTranslate
    buttonSettings.text = currentTranslations.buttonSettings
    outputEntry.text = currentTranslations.outputEntry
end

function loadSavedData()
    local file = sys.File("data.x")
    if file.size == 0 then
        local file = sys.File("data.x")
        file:open("write")
        file:write("1_3")
        file:flush()
        file:close()
        languageIndex, themeIndex = 1, 3
        languageCode = "en"
        theme = "auto"
        currentTranslations = translations[languageCode] or translations["en"]
        setData(languageCode, theme)
    else
        file:open("read")
        local data = file:read()
        file:close()
        languageIndex, themeIndex = data:match("(%d+)_(%d+)")
        languageCode = languageCodes[tonumber(languageIndex)][1]
        theme = themesTable[tonumber(themeIndex)][1]
        currentTranslations = translations[languageCode] or translations["en"]
        setData(languageCode, theme)
    end
end

loadSavedData()

function translate(text, source_lang, target_lang)
    net.Http("https://translate.googleapis.com"):get(
            string.format("/translate_a/single?client=gtx&sl=%s&tl=%s&dt=t&q=%s", source_lang, target_lang, text)
        ).after = function(client, response)
        _, _, rest = string.find(response.content, '^....(.-)".*$')
        if rest == "l,null," then
            outputEntry.text = currentTranslations.outputEntry
        else
            outputEntry.text = rest
        end
    end
end

local combo = ui.Combobox(win, {}, 20 * ui.dpi, 84 * ui.dpi, 158 * ui.dpi, 128 * ui.dpi)
local combo2 = ui.Combobox(win, {}, 420 * ui.dpi, 84 * ui.dpi, 158 * ui.dpi, 128 * ui.dpi)



for i, v in ipairs(languageCodes) do
    -- TRANSLATE FROM:
    combo:add(v[2])
    local file = embed and embed.File()
    combo.items[i]:loadicon(sys.currentdir .. "/icons/languages/" .. i .. ".ico")
    combo.style = "icons"
    combo.selected = combo.items[1]
    -- TRANSLATE TO:
    combo2:add(v[2])
    combo2.items[i]:loadicon(sys.currentdir .. "/icons/languages/" .. i .. ".ico")
    combo2.style = "icons"
    combo2.selected = combo2.items[2]
end

function buttonTranslate:onClick()
    outputEntry.text = "!@#$%^&*()"
    translate(entry.text, getLanguageCode(combo.selected.index), getLanguageCode(combo2.selected.index))
end

function buttonSettings:onClick()
    buttonSettings.enabled = false
    local winSettings = ui.Window("gTranslate - " .. buttonSettings.text, "fixed", 320 * ui.dpi, 280 * ui.dpi)
    winSettings.topmost = true
    if ui.theme == "dark" then
        winSettings.bgcolor = 0x171717
    elseif ui.theme == "light" then
        winSettings.bgcolor = 0xc9c9c9
    end
    
    function winSettings:onClose()
        buttonSettings.enabled = true
    end
    winSettings:center()
    local labelSettings = ui.Label(winSettings, "App Language: ", 20 * ui.dpi, 25 * ui.dpi)
    labelSettings.fontsize = math.floor(9 * ui.dpi) -- decimal values on font sizes crash the app [!]
    labelSettings:autosize()
    local comboSettings = ui.Combobox(winSettings, {}, 164 * ui.dpi, 20 * ui.dpi, 128 * ui.dpi, 128 * ui.dpi)
    for i, v in ipairs(languageCodes) do
        comboSettings:add(v[2])
        comboSettings.items[i]:loadicon(sys.currentdir .. "/icons/languages/" .. i .. ".ico")
        comboSettings.style = "icons"
        comboSettings.selected = comboSettings.items[languageIndex]
    end
    local labelSettings2 = ui.Label(winSettings, "Theme: ", 20 * ui.dpi, 69 * ui.dpi)
    labelSettings2.fontsize = math.floor(9 * ui.dpi) -- decimal values on font sizes crash the app [!]
    labelSettings2:autosize()
    local comboSettings2 = ui.Combobox(winSettings, {}, 164 * ui.dpi, 64 * ui.dpi, 128 * ui.dpi, 128 * ui.dpi)
    for i, v in ipairs(themesTable) do
        comboSettings2:add(v[2])
        comboSettings2.items[i]:loadicon(sys.currentdir .. "/icons/themes/" .. i .. ".ico")
        comboSettings2.style = "icons"
        comboSettings2.selected = comboSettings2.items[themeIndex]
    end
    local buttonSave = ui.Button(winSettings, "Save settings", 0, 280 * ui.dpi - 32 * ui.dpi, 320 * ui.dpi, 32 * ui.dpi)
    buttonSave.fontsize = math.floor(12 * ui.dpi)
    local labelSettings3 = ui.Label(winSettings, "gTranslate 0.2", 0 * ui.dpi, 218 * ui.dpi, 320 * ui.dpi, 32 * ui.dpi)
    labelSettings3.textalign = "center"
    labelSettings.text = currentTranslations.labelSettings
    labelSettings2.text = currentTranslations.labelSettings2
    buttonSettings.text = currentTranslations.buttonSettings
    buttonSave.text = currentTranslations.buttonSave

    function buttonSave:onClick()
        local file = sys.File("data.x")
        file:open("write")
        file:write(comboSettings.selected.index .. "_" .. comboSettings2.selected.index)
        file:flush()
        file:close()
        loadSavedData()
        labelSettings.text = currentTranslations.labelSettings
        labelSettings2.text = currentTranslations.labelSettings2
        buttonSettings.text = currentTranslations.buttonSettings
        buttonSave.text = currentTranslations.buttonSave
        winSettings.title = "gTranslate - " .. buttonSettings.text
        if ui.theme == "dark" then
            winSettings.bgcolor = 0x171717
        elseif ui.theme == "light" then
            winSettings.bgcolor = 0xc9c9c9
        end
    end
    ui.run(winSettings):wait()
end



entry.fontsize = math.floor(14 * ui.dpi) -- decimal values on font sizes crash the app [!]
outputEntry.fontsize = math.floor(14 * ui.dpi) -- decimal values on font sizes crash the app [!]
buttonTranslate.fontsize = math.floor(12 * ui.dpi) -- decimal values on font sizes crash the app [!]
buttonSettings.fontsize = math.floor(12 * ui.dpi) -- decimal values on font sizes crash the app [!]

win:center()
picture:toback()
ui.run(win):wait()
