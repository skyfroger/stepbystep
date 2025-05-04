local function writeEnvironments()
    if quarto.doc.is_format("html:js") then
        quarto.doc.add_html_dependency({
            name = "leader-line",
            version = "1.0.7",
            scripts = {
                { path = "leader-line.min.js", afterBody = "true" } },
        })
        quarto.doc.add_html_dependency({
            name = "alpine",
            version = "3.12",
            scripts = {
                { path = "alpine.min.js", afterBody = "true", attribs = { defer = true } } },
        })
        quarto.doc.add_html_dependency({
            name = "sbs",
            version = "1",
            stylesheets = { "sbs.css" }
        })
    end
end

function css_style(str)
    local top, left, width, height = str:match("(%-?%d+%.?%d*) (%-?%d+%.?%d*) (%-?%d+%.?%d*) (%-?%d+%.?%d*)")
    return string.format("style=\"top: %s%%; left: %s%%; width: %s%%; height: %s%%\"", top, left, width, height)
end

local function escapeHtmlDataAttribute(str)
    local entities = {
        ['"'] = "&quot;",
        ["'"] = "&#39;",
        ["<"] = "&lt;",
        [">"] = "&gt;",
        ["&"] = "&amp;",
        [" "] = "&#32;",
        ["\t"] = "&#9;",
        ["\n"] = "&#10;",
        ["\r"] = "&#13;"
    }

    return str:gsub('[&<>"\'\t\n\r ]', function(c)
        return entities[c] or c
    end)
end

-- Для случайных ID
function RandomStringID(length)
    local res = ""
    for i = 1, length do
        res = res .. string.char(math.random(97, 122))
    end
    return res
end

return {
    ['sbsreset'] = function(args, kwargs, meta)
        local html = [[
        <button
            class="sbs__button"
            x-data
            x-on:click="$dispatch('reset-actions');"
            >
            ↻ Показать все шаги
        </button>
        ]]
        return pandoc.RawBlock('html', html)
    end,
    ['pin'] = function(args, kwargs, meta)
        writeEnvironments()
        local pinTypesTable = {
            gpio = "gpio",
            power = "power",
            pow = "power",
            v = "power",
            gnd = "gnd",
            ground = "gnd"
        }
        local pinName = escapeHtmlDataAttribute(pandoc.utils.stringify(args[1]))
        local hl = pandoc.utils.stringify(kwargs["hl"])

        local pinType = "gpio"
        if args[2] ~= nil then
            pinType = pandoc.utils.stringify(args[2])
        end

        local pinTypeClassName = pinTypesTable["gpio"]
        if rawget(pinTypesTable, pinType) ~= nil then
            pinTypeClassName = pinTypesTable[pinType]
        end

        local hlHTML = [[]]
        if hl ~= nil and hl ~= "" then
            hlHTML = [[id="hl-]] ..
                hl .. [["
x-on:load.window="
const start = document.getElementById('hl-]] .. hl .. [[');
const finish = document.getElementById(']] .. hl .. [[');
line = new LeaderLine(start, finish, {hide: true, color: '#ffc100'})"
x-on:mouseenter="
    document.querySelector('#]] .. hl .. [[').classList.add('show-highlight');
    line.position();
    line.show()
"
x-on:mouseleave="document.querySelector('#]] .. hl .. [[').classList.remove('show-highlight'); line.hide()"]]
        end

        local html = [[<span x-data="{line: null}" class="pin__data ]] ..
            pinTypeClassName .. [[" ]] .. hlHTML .. [[>]] .. pinName .. [[</span>]]
        return pandoc.RawBlock('html', html)
    end,
    ['element'] = function(args, kwargs, meta)
        writeEnvironments()
        local text = escapeHtmlDataAttribute(pandoc.utils.stringify(args[1]))
        local hl = pandoc.utils.stringify(kwargs["hl"])

        local hlHTML = [[]]
        if hl ~= nil then
            hlHTML = [[id="hl-]] ..
                hl .. [["
x-on:load.window="
const start = document.getElementById('hl-]] .. hl .. [[');
const finish = document.getElementById(']] .. hl .. [[');
line = new LeaderLine(start, finish, {hide: true, color: '#ffc100'})"
x-on:mouseenter="
    document.querySelector('#]] .. hl .. [[').classList.add('show-highlight');
    line.position();
    line.show();
"
x-on:mouseleave="document.querySelector('#]] .. hl .. [[').classList.remove('show-highlight'); line.hide();"]]
        end

        local html = [[<span x-data="{line: null}" class="scheme__element"]] .. hlHTML .. [[>]] .. text .. [[</span>]]
        return pandoc.RawBlock('html', html)
    end,
    ['hl'] = function(args, kwargs, meta)
        local elementId = escapeHtmlDataAttribute(pandoc.utils.stringify(args[1]))
        local pos = pandoc.utils.stringify(kwargs["pos"])

        local style = css_style(pos)
        local hover = [["
x-on:load.window="
    const start = document.getElementById(']] .. elementId .. [[');
    const finish = document.getElementById('hl-]] .. elementId .. [[');
    line = new LeaderLine(start, finish, {hide: true, color: '#ffc100'})"
x-on:mouseenter="
    document.querySelector('#hl-]] ..
            elementId .. [[').classList.add('show-element-highlight');
    line.position();
    line.show()
"
x-on:mouseleave="document.querySelector('#hl-]] ..
            elementId .. [[').classList.remove('show-element-highlight'); line.hide()"]]

        local html = [[<div x-data="{line: null}" class="highlight" id="]] .. elementId .. [["
        ]] .. style .. [[]] .. hover .. [[></div>]]

        return pandoc.RawBlock('html', html)
    end,
    ['hs'] = function(args, kwargs, meta)
        writeEnvironments()
        local text = pandoc.utils.stringify(args[1])
        local left = args[2]
        local top = args[3]

        -- произвольный текст маркера
        local marker = pandoc.utils.stringify(kwargs["marker"])

        if marker == '' then
            marker = '🖈'
        end

        if left == nil then
            left = 0
        end

        if top == nil then
            top = 0
        end

        local tipId = RandomStringID(8)

        local hsHTML = [[<div id="]] ..
            tipId .. [[" class="sbs__hotspot" style="left: ]] .. left ..
            [[%; top: ]] .. top .. [[%;">]] .. marker .. [[</div>]]

        hsHTML = hsHTML .. [[
        <script>
        tippy('#]] .. tipId .. [[', {
            content: "]] .. text .. [[",
            maxWidth: 250,
            theme: 'sbshs',
            hideOnClick: false,
            interactive: true,
            interactiveBorder: 30,
        });
        </script>
        ]]

        return pandoc.RawBlock('html', hsHTML)
    end
}
