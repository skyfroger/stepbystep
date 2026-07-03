local EXTENSION_NAME = "stepbystep"

local utils = require("./utils")
local l10n  = require("./localize")

function createStep(stepNumber, header, stepTable)
local content = {}

  if header ~= nil then
    table.insert(content, header)
  end

  for _, el in ipairs(stepTable) do
    table.insert(content, el)
  end

  return pandoc.Div(content, pandoc.Attr("", {"step"},
  {[":class"] = string.format("{ active: current === %d, prev: current > %d }", stepNumber, stepNumber)}))
end

function createPbP(div, options)
  utils.writeEnvironments()
  local tutorialContent = {}
  local currentStep = {}
  local currentHeader = nil
  local allSteps = {}

  local stepsCount = 0

  local headersLevel = tonumber(options["headers-level"])

  for i, el in ipairs(div.content) do
    if el.t == "Header" and currentHeader == nil then
      currentHeader = el
    elseif el.t == "Header" and el.level == headersLevel then
      table.insert(allSteps, createStep(stepsCount, currentHeader, currentStep))
      currentHeader = el
      currentStep = {}
      stepsCount = stepsCount + 1
    elseif el.t ~= "Header" and i == #div.content then
      table.insert(currentStep, el)
      table.insert(allSteps, createStep(stepsCount, currentHeader, currentStep))
    else
      table.insert(currentStep, el)
    end
  end

  -- Открывающий тег с буквальными x-data и x-ref
  table.insert(tutorialContent, pandoc.RawBlock("html", 
    '<div x-data="pagebypage(' .. (stepsCount + 1) .. ','.. headersLevel ..')" x-ref="main" class="pbp">'
  ))

  -- Меню
  table.insert(tutorialContent, pandoc.RawBlock("html", [[
      <div class="pbp__menu">
        <template x-for="(header, index) in stepHeaders" :key="index">
          <div
            class="menu__item"
            :class="{ active: current === index, prev: current > index }"
            @click="go(index)"
          >
            <span x-text="(index + 1).toString().padStart(2, '0');"></span>
          </div>
        </template>
      </div>]]))

  table.insert(tutorialContent, pandoc.RawBlock("html", [[
  <div class="pbp__page">
      <div class="steps-viewport" :style="`height: ${viewportHeight}px`" x-ref="viewport">]]))
      table.insert(tutorialContent, pandoc.Div(allSteps))
      table.insert(tutorialContent, pandoc.RawBlock("html",
      [[</div>]]))


  table.insert(tutorialContent, pandoc.RawBlock("html", [[
      <div class="navigation">
          <div>
            <button
              class="pbp__button left"
              @click="prev"
              x-show="current !== 0"
            >
              <span style="font-weight: bold;">]]..l10n("previous")..[[:</span><span x-html="stepHeaders[current - 1]"></span>
            </button>
          </div>
          <div>
            <button
              class="pbp__button right"
              @click="next"
              x-show="current !== total - 1"
            >
              <span style="font-weight: bold;">]]..l10n("next")..[[:</span><span x-html="stepHeaders[current + 1]"></span>
            </button>
          </div>
        </div>]]))


  -- Закрывающий тег внешнего контейнера
  table.insert(tutorialContent, pandoc.RawBlock("html", "</div></div>"))

  -- Возвращаем список блоков — Pandoc заменит им исходный Div
  return tutorialContent
end

function createSbsAction(div)
  utils.writeEnvironments()

  local labelId = utils.RandomStringID(8)
  local actionContent = {}

  table.insert(actionContent, pandoc.RawBlock("html", [[<div
    class="sbs__action"
    x-data="{
      isCompleted: false
    }"
    x-on:reset-actions.window="isCompleted = false"
    >
  <div :class="isCompleted ? 'sbs__completed': ''" class="sbs__data">
]]))
  table.insert(actionContent, div)
  table.insert(actionContent, pandoc.RawBlock("html", [[
  </div>
    <div class="sbs__completion__container" style="text-align: right">
      <div class="checkbox-wrapper-19">
        <input type="checkbox" id="]] .. labelId .. [[" x-model="isCompleted"/>
        <label for="]] .. labelId .. [[" class="check-box">
      </div>
    </div>
</div>
]]))
  return pandoc.Div(actionContent)
end

function createSbsTask(div)
  utils.writeEnvironments()

  local labelId = utils.RandomStringID(8)
  local actionContent = {}

  local g = ""
  if div.attributes["g"] ~= nil then
    g = div.attributes["g"]
  end

  table.insert(actionContent, pandoc.RawBlock("html", [[<div

    class="sbs__task"
    data-group="]] .. g .. [["
    x-data="{
      isCompleted: false,
      get caption(){
        return this.isCompleted ? '👏 ]].. l10n("done") ..[[' : '✍️ ]].. l10n("task") ..[[';
      }
    }"
    x-init="$watch('isCompleted', value => {
        $dispatch('task-notification', {
            isCompleted: isCompleted,
            group: ']] .. g .. [[',
        });
    });"
    x-on:reset-actions.window="isCompleted = false"
    >
    <div class="badge__container" >
        <span class="sbs__badge" :class="isCompleted ? 'sbs__badge__completed': ''" x-text="caption"></span>
    </div>
    <div class="sbs__task__body" :class="isCompleted ? 'sbs__task__completed': ''">
]]))
  table.insert(actionContent, div)
  table.insert(actionContent, pandoc.RawBlock("html", [[
    </div>
    <div class="sbs__completion__container" style="text-align: right">
      <div class="checkbox-wrapper-19">
        <input type="checkbox" id="]] .. labelId .. [[" x-model="isCompleted"/>
        <label for="]] .. labelId .. [[" class="check-box">
      </div>
    </div>
</div>
]]))
  return pandoc.Div(actionContent)
end

function createSbsHotspot(div)
  utils.writeEnvironments()
  local hsContent = {}
  local tipId = utils.RandomStringID(8)

  local marker = '🖈'
  if div.attributes["marker"] ~= nil then
    marker = div.attributes["marker"]
  end

  local left = 0
  if div.attributes["left"] ~= nil then
    left = div.attributes["left"]
  end

  local top = 0
  if div.attributes["top"] ~= nil then
    top = div.attributes["top"]
  end

  table.insert(hsContent, pandoc.RawBlock("html", [[
  <div id="]] .. tipId ..
    [[" class="sbs__hotspot" style="left: ]]
    .. left .. [[%; top: ]] .. top .. [[%;">]] .. marker .. [[</div>]]
  ))

  table.insert(hsContent, pandoc.RawBlock("html", [[
  <script>
    tippy('#]] .. tipId .. [[', {
        content: `]]
  ))

  table.insert(hsContent, div)

  table.insert(hsContent, pandoc.RawBlock("html", [[`,
        maxWidth: 400,
        theme: 'sbshs',
        allowHTML: true,
        hideOnClick: false,
        interactive: true,
        interactiveBorder: 30,
    });
  </script>]]
  ))

  return pandoc.Div(hsContent)
end


local function render_elements(options)

  l10n.load(options.lang)

  return {
    Div = function(div)
      if quarto.doc.isFormat("html:js") then
        if div.classes:includes("pagebypage") then
          return createPbP(div, options)
        end

        if div.classes:includes("sbsaction") then
          return createSbsAction(div)
        end

        if div.classes:includes("sbstask") then
          return createSbsTask(div)
        end

        if div.classes:includes("sbshs") then
          return createSbsHotspot(div)
        end

        return nil
      end
    end
  }
end


function Pandoc(doc)
  -- default options
  local options = {
    ["headers-level"] = 3,
    lang = pandoc.utils.stringify(doc.meta.lang)
  }

  -- replace default option with local 
  local globalOptions = doc.meta[EXTENSION_NAME]
  if type(globalOptions) == "table" then
    for k, v in pairs(globalOptions) do
      options[k] = pandoc.utils.stringify(v)
    end
  end

  return doc:walk(render_elements(options))
end




