[![English](https://img.shields.io/badge/lang-en-blue.svg)](README.md)
[![Русский](https://img.shields.io/badge/lang-ru-red.svg)](README.ru.md)

# Stepbystep

**Stepbystep** is an extension for [Quarto](https://quarto.org/) that provides tools for organizing step-by-step tasks, tracking exercise progress, and visually styling instructions with image element highlighting.

## Installation

Add the extension to your Quarto project:

```bash
quarto add skyfroger/stepbystep
```

After installation, shortcodes and filters will be available once `stepbystep` is connected to the project or a specific page.

## Localization

To localize the extension's UI elements, specify the `lang` attribute in YAML. English is used by default. Russian is also available:

```yaml
lang: ru
```

## Task Steps and Self-Study

To format a set of actions as a single instruction step, wrap each action in a block with the `.sbsaction` class:

```markdown
:::{.sbsaction}
First action.
:::

Explanations

:::{.sbsaction}
Second action.
:::
```

Tasks for independent completion are placed inside a block with the `.sbstask` class:

```markdown
:::{.sbstask}
What needs to be done independently.
:::
```

Each block has a checkbox that the learner can use to mark a completed step. This helps track task progress.

The `sbsreset` shortcode adds a button that removes all checkmarks from completed blocks:

```markdown
{{{< sbsreset >}}}
```

## Image Element Highlighting

The `element` and `pin` shortcodes create styling elements that point to highlighted areas of an image:

```markdown
Connect the {{{< element photoresistor hl="ldr" >}}} with one of its contacts to pin {{{< pin 14 hl="pin14-02" >}}}.
```

Parameters:

| Parameter | Description |
|-----------|-------------|
| *(first argument)* | Element name or pin number. |
| `hl` | ID of the element to highlight. Optional parameter. |

The image whose elements need to be highlighted is placed in a block with the `.hl-container` class. Inside the container, `hl` shortcodes are placed:

```markdown
:::{.hl-container}

![](images/img.png)

{{{< hl pin14-02 pos="39 75.3 3 5" >}}}

{{{< hl ldr pos="56 22.3 18 11" >}}}

:::
```

Parameters of the `hl` shortcode:

| Parameter | Description |
|-----------|-------------|
| *(first argument)* | ID of the highlight element (must match the `hl` parameter in the `element` or `pin` shortcode). |
| `pos` | Values of the `top`, `left`, `width`, and `height` attributes, separated by spaces. Specified in percentages. |

> **Important:** identifier names in the `hl` parameter and in the corresponding shortcode must be unique. Otherwise, arrows and highlighting will not work correctly.

## Hotspot (Interactive Points)

The `hs` shortcode allows you to add an active point with a tooltip popup to an image:

```markdown
{{{< hs "Tooltip text" left top marker="1" >}}}
```

Parameters:

| Parameter | Description |
|-----------|-------------|
| *(first argument)* | Tooltip text. |
| `left` | Relative offset from the left edge of the image (in percentages). |
| `top` | Relative offset from the top edge of the image (in percentages). |
| `marker` | Text inside the marker. The value must be enclosed in **quotes**. |

A block with the `.sbshs` class allows you to place arbitrary markup inside a hotspot, including code blocks. Used inside `.hl-container`:

````markdown
:::{.hl-container}

![](images/img.png)

{{{< hs "LED with a current-limiting resistor." 73 66 marker="1" >}}}

{{{< hs "The photoresistor changes its resistance depending on the light level." 19.5 55 >}}}

:::{.sbshs left=45 top=20 marker=2}

The following code will turn on the LED:

```python
from machine import Pin
led = Pin(12, Pin.OUT)
led.on()
```

:::

:::
````

## Page-by-Page Tutorial (`pagebypage`)

The `pagebypage` block allows you to split instructions for learners into a set of paginated slides. Each page starts with a heading of the configured level (default: level 3).

### Configuration

By default, pages are split at level 3 headings (`###`). You can change this with the `headers-level` option in the document's YAML header or in `_quarto.yml`:

```yaml
stepbystep:
  headers-level: 4
```

### Markup
Wrap the entire tutorial content in a block with the .pagebypage class. Each page must start with a heading of the configured level:

```markdown
:::{.pagebypage}

### First Page

Content of the first page...

:::{.sbsaction}
First action.
:::

### Second Page

Content of the second page...

:::{.sbstask}
Task for independent work.
:::

:::
```

### Navigation

The tutorial provides a navigation menu with numbered page indicators and "Previous"/"Next" buttons. Completed pages are marked visually.

### Combining with Other Elements

Inside .pagebypage you can use any other stepbystep elements: .sbsaction, .sbstask, .hl-container, element, pin, hs, and sbshs.

## Markup Tips

1. **Identifier uniqueness.** Names in the `hl` parameter of the `element`, `pin`, and `hl` shortcodes must be unique.
2. **Percentage coordinates.** The `pos` parameter in the `hl` shortcode and the `left`/`top` attributes in `hs`/`sbshs` are specified as percentages relative to the image dimensions.
3. **Quotes for marker.** The `marker` parameter value in the `hs` shortcode must be enclosed in quotes, even if it is a number.
4. **Container nesting.** For `sbshs` with code, use 4 colons (`::::`) for the outer block to avoid conflicts with inner blocks of 3 colons (`:::`).
5. **Filter in YAML.** Don't forget to add `filters: - stepbystep` to the document header.

## Credits

The following third-party libraries and modules were used in the development of the extension:

- [Alpine.js](https://alpinejs.dev) for UI reactivity. MIT license.
- [LeaderLine](https://github.com/anseki/leader-line) for dynamic arrows. MIT license.