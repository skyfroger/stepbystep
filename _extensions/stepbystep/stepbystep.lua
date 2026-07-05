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
  table.insert(tutorialContent, pandoc.RawBlock("html",[[
    <div x-data="pagebypage(]] .. (stepsCount + 1) .. [[,]].. headersLevel ..[[)"
    x-ref="main"
    @answer-notification.stop="catchAnswers"
    class="pbp">]]
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
              <span x-show="isPageLocked(current + 1)" x-text="`🔒(${taskCompletion[current]})`"></span>
              <span x-show="!isPageLocked(current + 1)" style="font-weight: bold;">]]..l10n("next")..[[:</span>
              <span x-html="stepHeaders[current + 1]"></span>
            </button>
            <svg x-show="current === total - 1" width="64px" height="64px" viewBox="0 0 64 64" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" xml:space="preserve" xmlns:serif="http://www.serif.com/" style="fill-rule:evenodd;clip-rule:evenodd;stroke-linecap:round;stroke-linejoin:round;stroke-miterlimit:1.5;">
                <path d="M29.818,4.108C31.168,3.329 32.832,3.329 34.182,4.108C38.854,6.806 49.803,13.127 54.746,15.981C56.293,16.874 57.246,18.525 57.246,20.311L57.246,43.689C57.246,45.475 56.293,47.126 54.746,48.019C49.912,50.81 39.334,56.917 34.5,59.708C32.953,60.601 31.047,60.601 29.5,59.708C24.666,56.917 14.088,50.81 9.254,48.019C7.707,47.126 6.754,45.475 6.754,43.689L6.754,20.311C6.754,18.525 7.707,16.874 9.254,15.981C14.197,13.127 25.146,6.806 29.818,4.108Z" style="fill:url(#_Radial1);"/>
                <g transform="matrix(1,0,0,0.991525,-4.468313,-3.569753)">
                    <path d="M22.337,34.47L34.336,48.654L51.3,23.683" style="fill:none;stroke:rgb(240,223,120);stroke-width:7.63px;"/>
                </g>
                <defs>
                    <radialGradient id="_Radial1" cx="0" cy="0" r="1" gradientUnits="userSpaceOnUse" gradientTransform="matrix(-26.515901,37.226258,-37.226258,-26.515901,41.06088,18.313874)"><stop offset="0" style="stop-color:rgb(135,211,162);stop-opacity:1"/><stop offset="1" style="stop-color:rgb(135,181,123);stop-opacity:1"/></radialGradient>
                </defs>
            </svg>
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




