--[[
    Author: flightwusel
    License: use for anything but acknowledge me
]]

--[[ runtime variables ]]
local scriptName = debug.getinfo(1, "S").source:match("([^/\\]*)[.]lua$")

local const = {
    cacheDir = SYSTEM_DIRECTORY .. "Output" .. DIRECTORY_SEPARATOR .. "caches",
    presetsFilePath = SCRIPT_DIRECTORY .. scriptName .. DIRECTORY_SEPARATOR .. "presets.lua",
    colors = {
        default = 0xFF6F4725,
        text = 0xFFFFFFFF,
        active = 0x99FFA800,
        highlight = 0xfffa9642,
        defaultCheckboxBg = 0xff4b311e,
        checkMarkPartly = 0xff694d3b,
    },
}
const['defaultsFilePath'] = const['cacheDir'] .. DIRECTORY_SEPARATOR .. scriptName .. "_X-Plane_defaults.cache.lua"
const['runtimeFilePath'] = const['cacheDir'] .. DIRECTORY_SEPARATOR .. scriptName .. "_runtime.cache.lua"

local settings = {
    loadPresetsOnStartup = false,
    addMacrosForPreset = false,
    window_dx = 1200,
    window_dy = 150,
}

local presets
local settings_wnd = nil

--[[ local ]]
local function log(msg, level)
    -- @see https://stackoverflow.com/questions/9168058/how-to-dump-a-table-to-console
    local function dump(o)
        if type(o) == 'table' then
            local s = '{ '
            for k,v in pairs(o) do
                if type(k) ~= 'number' then k = '"'..k..'"' end
                s = s .. '['..k..'] = ' .. dump(v) .. ','
            end
            return s .. '} '
        else
            return tostring(o)
        end
    end

    local msg = msg or ''
    local level = level or ""
    local filePath = debug.getinfo(2, "S").source
    local fileName = filePath:match("[^/\\]*[.]lua$")
    local functionName = debug.getinfo(2, "n").name
    logMsg(
        string.format(
            "%s::%s() %s%s",
            fileName,
            functionName,
            level,
            dump(msg)
        )
    )
end

local function err(msg)
    log(msg, "[ERROR] ")
end

-- try to load X-Plane defaults from file
-- @return table | nil
local function tryLoadDefaults()
    log("trying to load defaults from " .. const['defaultsFilePath'])
    local contents = loadfile(const['defaultsFilePath'])
    if contents then
        return contents()
    end
    return nil
end

-- @return table | nil
local function tryLoadRuntimeSettings()
    log("trying to load defaults from " .. const['runtimeFilePath'])
    local contents = loadfile(const['runtimeFilePath'])
    if contents then
        return contents()
    end
    return nil
end

-- save X-Plane defaults to file to keep them across situation loads
-- this is called a) on startup or b) no settings could be loaded
local function populateAndWriteDefaults()
    log("writing to " .. const['defaultsFilePath'])

    -- capture current values of all used dataRefs and add to "Default" preset
    presets["Default"] = {}
    for presetName, dataRefs in pairs(presets) do
        for dataRef, value in pairs(presets[presetName]) do
            if dataRef ~= "_includes" then
                presets["Default"][dataRef] = get(dataRef)
            end
        end
    end

    local file = io.open(const['defaultsFilePath'], "w")
    if not file then
        err("could not open " .. const['defaultsFilePath'] .. " for writing")
    end

    file:write("-- This gets rewritten on X-Plane startup. We need it to remember the initial values across situation loads. You can savely delete it.\n")
    file:write("return {\n")
    file:write("  ['Default'] = {\n")
    for p,v in pairs(presets["Default"]) do
        file:write(string.format("    [%q] = %f,\n", p, v))
    end
    file:write("  }\n")
    file:write("}\n")
    file:close()
end

local function pairsAlphabetical(t, f)
    local a = {}
    for n in pairs(t) do table.insert(a, n) end
    table.sort(a, f)
    local i = 0      -- iterator variable
    local iter = function ()   -- iterator function
        i = i + 1
        if a[i] == nil then return nil
        else return a[i], t[a[i]]
        end
    end
    return iter
end

local function addMacroAndCommand(cmdRef, title, eval)
    log(
        string.format(
            "Adding macro '%s' (cmdRef '%s')",
            title,
            cmdRef
        )
    )
    create_command(cmdRef, title, eval, '', '')
    add_macro(title, eval)
end

-- @return < 0: no; 0: partly; > 0: fully
local function isPresetActive(presetName)
    local _hasNonMatches = false
    local _hasMatches = false

    if presets[presetName] == nil then
        return 1
    end

    -- load included presets
    if presets[presetName]["_includes"] ~= nil then
        for _, _presetName in pairs(presets[presetName]["_includes"]) do
            local _isPresetActive = isPresetActive(_presetName)
            _hasNonMatches = _hasNonMatches or (_isPresetActive <= 0)
            _hasMatches = _hasMatches or (_isPresetActive >= 0)
        end
    end

    for dataRef, value in pairs(presets[presetName]) do
        if dataRef ~= "_includes" then
            -- float fuzzy
            if math.abs(get(dataRef) - value) > 0.00001 then
                _hasNonMatches = true
            else
                _hasMatches = true
            end
        end
    end

    return (_hasNonMatches and not _hasMatches) and -1
        or (_hasNonMatches and _hasMatches) and 0
        or (not _hasNonMatches and _hasMatches) and 1
        or 1 -- default if no DataRefs where included somehow
end

local function callPreset(presetName, isSubCall)
    local isSubCall = isSubCall or false

    log(string.format("%s:", presetName))

    if presets[presetName] == nil then
        err(string.format("preset '%s' not defined in '%s'", presetName, const.presetsFilePath))
        return
    end

    -- load included presets
    if presets[presetName]["_includes"] ~= nil then
        for _, _presetName in pairs(presets[presetName]["_includes"]) do
            log(string.format("(%s) loading preset from _includes: %s", presetName, _presetName))
            callPreset(_presetName, true)
        end
    end

    for dataRef, value in pairs(presets[presetName]) do
        if dataRef ~= "_includes" then
            log(string.format("  %s=%s", dataRef, value))
            set(dataRef, value)
        end
    end

    -- save selected preset
    if not isSubCall then
        local file = io.open(const['runtimeFilePath'], "w")
        if not file then
            err("could not open " .. const['runtimeFilePath'] .. " for writing")
        end

        file:write("-- This saves the latest selected preset to restore it on load. You can savely delete it.\n")
        file:write("return {\n")
        file:write(string.format("  ['preset'] = '%s'\n", presetName))
        file:write("}\n")
        file:close()
    end
end

local function resetDataRefsFromPreset(presetName)
    log(string.format("%s:", presetName))

    if presets[presetName] == nil then
        err(string.format("preset '%s' not defined in '%s'", presetName, const.presetsFilePath))
        return
    end

    -- reset included presets
    if presets[presetName]["_includes"] ~= nil then
        for _, _presetName in pairs(presets[presetName]["_includes"]) do
            log(string.format("(%s) resetting preset from _includes: %s", presetName, _presetName))
            resetDataRefsFromPreset(_presetName, true)
        end
    end

    for dataRef, _ in pairs(presets[presetName]) do
        if dataRef ~= "_includes" then
            if presets['Default'][dataRef] == nil then
                err(string.format("  we don't have the default value for %s. Probably the presets have been changed after X-Plane has been loaded.", dataRef))
            else
                log(string.format("  %s=%s", dataRef, presets['Default'][dataRef]))
                set(dataRef, presets['Default'][dataRef])
            end
        end
    end
end

local function init()
    if not SUPPORTS_FLOATING_WINDOWS then
        -- to make sure the script doesn't stop old FlyWithLua versions
        err("imgui not supported by your FlyWithLua version")
        return
    end

    if io.open(const['cacheDir'], 'r') == nil then
        -- don't know how to do that more portable...
        os.execute("mkdir '" .. const['cacheDir'] .. "'")
    end

    log("loading presets from " .. const['presetsFilePath'])
    -- listing all files:  table = directory_to_table( “path” )
    local _presets = loadfile(const['presetsFilePath'])
    if not _presets then
        err("could not load presets. Aborting.")
        return
    end
    presets = _presets()

    local isStartup = LUA_RUN == 1
    log(string.format("isStartup = %s", isStartup))

    local defaults = tryLoadDefaults()
    if defaults and not isStartup then
        presets["Default"] = defaults["Default"]
    else
        populateAndWriteDefaults()
    end

    local runtimeSettings = tryLoadRuntimeSettings()
    if runtimeSettings then
        if runtimeSettings["preset"] and runtimeSettings["preset"] ~= "Default" then
            log(string.format("Loading last used preset '%s'", runtimeSettings["preset"]))
            callPreset(runtimeSettings["preset"])
        end
    end

    addMacroAndCommand(
        scriptName .. "/OpenSettings",
        scriptName .. ": Toggle Settings window",
        "dataRefPresets_openSettingsWindow()"
    )

    -- add commands and macros for presets
    if settings.addMacrosForPreset then
        for presetName, dataRefs in pairsAlphabetical(presets) do
            local _title = presetName
            if presetName == "Default" then
                _title = "X-Plane Default -- resets all used DataRefs"
            end

            addMacroAndCommand(
                scriptName .. "/" .. presetName,
                scriptName .. ": " .. _title,
                "dataRefPresets_callPreset('" .. presetName .. "')"
            )
        end
    end
end

--[[ global ]]
function dataRefPresets_callPreset(presetName)
    callPreset(presetName)
end

function dataRefPresets_imgui_callback(wnd, x, y)
    -- imGui
    -- https://pixtur.github.io/mkdocs-for-imgui/site/api-imgui/ImGui--Dear-ImGui-end-user/
    -- Lua Bindings https://github.com/X-Friese/FlyWithLua/blob/master/src/imgui/imgui_iterator.inl

    imgui.BeginTabBar("MainTabBar");
    if imgui.BeginTabItem("Presets") then
        local x = 0

        for presetName, dataRefs in pairsAlphabetical(presets) do
            local _title = presetName
            if presetName == "Default" then
                _title = "X-Plane Default"
            end

            local _isActive = isPresetActive(presetName)

            local _width, _ = imgui.CalcTextSize(_title) + 8 + 16 -- for checkbox

            if (x + _width < imgui.GetWindowWidth() - 28) then -- leave space for eventual horizontal scroll bar, too
                if presetName ~= "Default" then
                    imgui.SameLine()
                end
            else
                x = 0
            end

            if _isActive == 0 then -- some DataRefs are set to this preset's values
                imgui.PushStyleColor(imgui.constant.Col.CheckMark, const.colors.checkMarkPartly)
            end
            if presetName == "Default" then
                imgui.PushStyleColor(imgui.constant.Col.Text, const.colors.highlight)
            end
            if imgui.Checkbox(_title, _isActive >= 0) then
                if _isActive > 0 then
                    -- set DataRefs back to default
                    resetDataRefsFromPreset(presetName)
                else
                    dataRefPresets_callPreset(presetName)
                end
            end
            imgui.PopStyleColor(
                (presetName == "Default" and 1 or 0)
                + (_isActive == 0 and 1 or 0)
            )

            -- imgui.GetCursorPos() does not seem to advance in X with SameLine() ?!
            local _lastWidth, _ = imgui.GetItemRectSize()
            x = x + _lastWidth + 8
        end

        -- play around with scattering
        imgui.TextUnformatted("Scattering")
        local turbidity = get("sim/private/controls/scattering/override_turbidity_t")
        local turbiditySliderChanged, turbiditySliderNewVal = imgui.SliderFloat("turbidity",turbidity,0,5,"%.1f")
        if turbiditySliderChanged then
            set("sim/private/controls/scattering/override_turbidity_t",turbiditySliderNewVal)
        end

        local single = get("sim/private/controls/scattering/single_rat")
        local singleSliderChanged, singleSliderNewVal = imgui.SliderFloat("single",single,0,5,"%.1f")
        if singleSliderChanged then
            set("sim/private/controls/scattering/single_rat",singleSliderNewVal)
        end

        local multi = get("sim/private/controls/scattering/multi_rat")
        local multiSliderChanged, multiSliderNewVal = imgui.SliderFloat("multi",multi,0,5,"%.1f")
        if multiSliderChanged then
            set("sim/private/controls/scattering/multi_rat",multiSliderNewVal)
        end

        imgui.EndTabItem()
    end



    if imgui.BeginTabItem("Settings") then
        if imgui.TreeNode("Information") then
            imgui.PushTextWrapPos(imgui.GetWindowWidth() - 24)
            imgui.TextUnformatted(
                string.format(
                    "Presets file: '%s'",
                    const.presetsFilePath
                )
            )
            imgui.PopTextWrapPos()
            imgui.Spacing()
            imgui.TreePop()
        end

        if imgui.Checkbox("Restore presets on startup", settings.loadPresetsOnStartup) then
            settings.loadPresetsOnStartup = not settings.loadPresetsOnStartup
        end

        imgui.EndTabItem()
    end


    if imgui.BeginTabItem("Test") then

--     imgui.SliderFloat("const char* label", v, float v_min, float v_max, const char* format = "%.3f", float power = 1.0f)     --  adjust format to decorate the value with a prefix or a suffix for in-slider labels or unit display. Use power!=1.0 for logarithmic sliders
--         local changed, newVal = imgui.SliderFloat("Slider Caption", sliderVal, -180, 180, "Value: %.2f")
--         if changed then
--             sliderVal = newVal
--         end
--

        if imgui.Button("Button One") then  -- Standard size button
            imgui.OpenPopup("khkuhuh")
        end
        if imgui.Button("aButton One") then  -- Standard size button
            imgui.OpenPopup("akhkuhuh")
        end
        if imgui.BeginPopup("akhkuhuh") then
            imgui.Button("Button One")
            imgui.Button("Button One")
            local changed, newVal, a = imgui.DragFloat("Float accelerated", sliderVal, .01 * math.max(.1, math.abs(sliderVal)), -0., 0., "Value: %.2f")
            if changed then
                sliderVal = newVal
            end

            imgui.EndPopup()
        end
        if imgui.BeginPopup("khkuhuh") then
            if imgui.Button("aButton One") then  -- Standard size button
                imgui.OpenPopup("akhkuhuh")
            end
            local changed, newVal, a = imgui.DragFloat("Float accelerated", sliderVal, .01 * math.max(.1, math.abs(sliderVal)), -0., 0., "Value: %.2f")
            if changed then
                sliderVal = newVal
            end

            imgui.EndPopup()
        end

        local changed, newVal, a = imgui.DragFloat("Float accelerated", sliderVal, .01 * math.max(.1, math.abs(sliderVal)), -0., 0., "Value: %.2f")
        if changed then
            sliderVal = newVal
        end

        -- Additionally, it is possible to create a non-linear slider by specifying the power of the slider:
        local changed, newVal = imgui.SliderFloat("Power Slider", sliderVal2, -180, 180, "Value: %.2f", 2)
        if changed then
            sliderVal2 = newVal
        end

        -- For non-decimals:
        local changed, newVal = imgui.SliderInt("Int Slider", sliderVal3, -180, 180, "Value: %.0f")
        if changed then
            sliderVal3 = newVal
        end

        -- For angles:
        local changed, newVal = imgui.SliderAngle("Angle Slider", angle, -180, 180, "Value: %.0f")
        if changed then
            angle = newVal
        end

        imgui.EndTabItem()
    end
end

sliderVal = 0
sliderVal2 = 0
sliderVal3 = 0
angle = 0


function dataRefPresets_imguiTest_callback()
    imgui.PushStyleColor(imgui.constant.Col.WindowBg, 0x004b311e)

    imgui.TextUnformatted("öoih öoih öoih oöih oöihoi hoih oöihö ")
    imgui.TextUnformatted("öoih öoih öoih oöih oöihoi hoih oöihö ")
    imgui.TextUnformatted("öoih öoih öoih oöih oöihoi hoih oöihö ")
    imgui.TextUnformatted("öoih öoih öoih oöih oöihoi hoih oöihö ")
    imgui.TextUnformatted("öoih öoih öoih oöih oöihoi hoih oöihö ")
    imgui.TextUnformatted("öoih öoih öoih oöih oöihoi hoih oöihö ")
    if imgui.Button("Button One") then  -- Standard size button
        imgui.OpenPopup("khkuhuh")
    end
    if imgui.BeginPopup("khkuhuh") then
        imgui.Button("Button One")
        imgui.Button("Button One")

        imgui.EndPopup()
    end
    --imgui.PopStyleColor()
end

-- function dataRefPresets_testClick_callback(x, y, z, zz, zzz)
--     log ({x, y, z, zz, zzz, RESUME_MOUSE_CLICK, MOUSE_WHEEL_NUMBER})
--     RESUME_MOUSE_CLICK = false
--     return true
-- end

function dataRefPresets_openSettingsWindow()
--     local aaa = float_wnd_create(SCREEN_WIDTH, SCREEN_HEIGHT, 0, true)
--     float_wnd_set_position(aaa, 0, 0)
--     float_wnd_set_imgui_builder(aaa, "dataRefPresets_imguiTest_callback")
--     float_wnd_set_onclick(aaa, "dataRefPresets_testClick_callback")

    if settings_wnd ~= nil then
        float_wnd_destroy(settings_wnd)
        return
    end

    settings_wnd = float_wnd_create(settings.window_dx, settings.window_dy, 1, true)
    float_wnd_set_onclose(settings_wnd, "dataRefPresets_closeSettingsWindow_callback")
    float_wnd_set_title(settings_wnd, scriptName .. " Settings")
    float_wnd_set_imgui_builder(settings_wnd, "dataRefPresets_imgui_callback")
end

function dataRefPresets_closeSettingsWindow_callback()
    settings_wnd = nil
end

init()
