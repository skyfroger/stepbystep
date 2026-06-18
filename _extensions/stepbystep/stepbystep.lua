local path = require("pandoc.path")
local ext_dir = path.directory(PANDOC_SCRIPT_FILE)
local utils = dofile(ext_dir .. "/utils.lua")

function createStep(stepNumber, all, header, stepTable)
  table.insert(all, pandoc.RawBlock('html', [[
  <div x-show="currentStep === ]] .. stepNumber .. [[" x-transition >]]))
  table.insert(all, header)
  for i, el in ipairs(stepTable) do
    table.insert(all, el)
  end
  table.insert(all, pandoc.RawBlock("html", [[</div>]]))
end

function createSbs(div)
  utils.writeEnvironments()
  local scrollId = utils.RandomStringID(8)
  local tutorialContent = {}
  local currentStep = {}
  local currentHeader = nil
  local allSteps = {}

  local stepsCount = 0

  for i, el in ipairs(div.content) do
    if el.t == "Header" and currentHeader == nil then
      currentHeader = el
    elseif el.t == "Header" and el.level == 3 then
      createStep(stepsCount, allSteps, currentHeader, currentStep)
      currentHeader = el
      currentStep = {}
      stepsCount = stepsCount + 1
    elseif el.t ~= "Header" and i == #div.content then
      table.insert(currentStep, el)
      createStep(stepsCount, allSteps, currentHeader, currentStep)
    else
      table.insert(currentStep, el)
    end
  end

  table.insert(tutorialContent, pandoc.RawBlock("html", [[<div x-data="{
      currentStep: 0
    }">
  <div x-ref="]] .. scrollId .. [["></div>
]]))

  for i, el in ipairs(allSteps) do
    table.insert(tutorialContent, el)
  end

  table.insert(tutorialContent, pandoc.RawBlock("html", [[
      <div class="controls">
      <button
        x-on:click="
        currentStep--;
        $refs.]] .. scrollId .. [[.scrollIntoView({ behavior: 'smooth'})"
      >
        prev
      </button>
      <button
        x-on:click="
        currentStep++;
        $refs.]] .. scrollId .. [[.scrollIntoView({ behavior: 'smooth'})"
      >
        next
      </button>
    </div>
  </div>]]))

  return pandoc.Div(tutorialContent, { class = "sbs__ready" })
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
        return this.isCompleted ? '👏 Выполнено' : '✍️ Сделайте самостоятельно';
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

if quarto.doc.isFormat("html:js") then
  Div = function(div)
    if div.classes:includes("stepbystep") then
      return createSbs(div)
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