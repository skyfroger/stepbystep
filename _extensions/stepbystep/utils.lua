local M = {}

function M.writeEnvironments()
    if quarto.doc.is_format("html:js") then
        quarto.doc.add_html_dependency({
            name = "sbs-components",
            version = "1.0.0",
            scripts = {
                { path = "sbs-components.js" } },
        })
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
                { path = "sort-alpine.min.js", afterBody = "true" },
                { path = "alpine.min.js", afterBody = "true"  } },
        })
        quarto.doc.add_html_dependency({
            name = "sbs",
            version = "1",
            stylesheets = { "sbs.css" }
        })
    end
end

function M.RandomStringID(length)
  local res = ""
  for i = 1, length do
    res = res .. string.char(math.random(97, 122))
  end
  return res
end

function M.css_style(str)
    local top, left, width, height = str:match("(%-?%d+%.?%d*) (%-?%d+%.?%d*) (%-?%d+%.?%d*) (%-?%d+%.?%d*)")
    return string.format("style=\"top: %s%%; left: %s%%; width: %s%%; height: %s%%\"", top, left, width, height)
end

function M.escapeHtmlDataAttribute(str)
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

return M