# API Reference

Everything dmc-dragdrop provides. [Using dmc-dragdrop](using-dragdrop.md) explains how to use it.

## Quick Reference

| Name | In short |
|---|---|
| [`DragMgr:doDrag()`](#dragmgrdodrag-initiator-event--options-) | start a drag from a touch |
| [`DragMgr:register()`](#dragmgrregister-target--handlers-) | make something a drop target |
| [`DragMgr:unregister()`](#dragmgrunregister-target-) | stop it being one |
| [`DragMgr:acceptDragDrop()`](#dragmgracceptdragdrop) | in `dragEnter`: accept the drag |
| [`DragMgr.display_name`](#dragmgrdisplay_name) | the property holding a non-display target's display object |
| [Events](#events) | `dragStart`, `dragEnter`, `dragOver`, `dragExit`, `dragDrop`, `dragStop` |
| [Constants](#constants) | `EVENT`, colors |
| [Configuration](#configuration) | no settings |

## The Module

```lua
local DragMgr = require 'dmc_corona.dmc_dragdrop'
```

The module is the Drag Manager itself, created when it is first required. There is one for the app.

### DragMgr:doDrag( initiator, event [, options] )

Starts a drag. Call it from a touch listener on the `'began'` phase.

- `initiator`: the object the drag starts from. Its `width` and `height` size the default proxy; an unaccepted drag slides the proxy back to its `x`, `y`.
- `event`: the touch event. The proxy is placed at `event.x`, `event.y` (plus the offsets) and given the touch focus.
- `options`, a table, all optional:

| Option | Default | Meaning |
|---|---|---|
| `proxy` | a light grey square with a grey border, the initiator's size | the display object that follows the finger. It is removed when the drag ends. |
| `format` | `nil` | what is being dragged, usually a string; given to the drop targets as `event.format` |
| `data` | `nil` | any value; given to the drop targets as `event.data` |
| `xOffset`, `yOffset` | `0` | where the proxy is drawn, relative to the touch point |
| `alpha` | `0.5` | the proxy's alpha |

`dragStart` is sent to the targets before `doDrag()` returns.

### DragMgr:register( target [, handlers] )

Makes `target` a drop target. `target` is a display object, or an object whose `view` property (see [`display_name`](#dragmgrdisplay_name)) is one, such as a dmc-objects component.

`handlers` is a table with any of the [event](#events) names as keys and functions as values; each is called as `handler( event )`. Without `handlers`, the target's own methods of those names are called, as `target:dragEnter( event )`.

### DragMgr:unregister( target )

Removes a drop target. Call it before removing the target from the screen.

### DragMgr:acceptDragDrop()

Accepts the current drag for the target that is receiving `dragEnter`. Call it in `dragEnter`; without it, the target gets no `dragOver`, `dragExit` or `dragDrop` for this visit.

### DragMgr.display_name

Setting it changes the name of the property that holds the display object of a drop target that isn't one itself. Default `'view'`.

```lua
DragMgr.display_name = 'display'
```

## Events

Each handler gets a table with:

| Field | Value |
|---|---|
| `name` | `DragMgr.EVENT` (`'drag-drop-event'`) |
| `target` | the drop target, as registered |
| `format` | the `format` given to `doDrag()` |
| `data` | the `data` given to `doDrag()` |

| Event | Sent to | When |
|---|---|---|
| `dragStart` | every target with a handler for it | a drag starts |
| `dragEnter` | the target under the touch point | the touch moves onto it |
| `dragOver` | that target, if it accepted | each move while on it |
| `dragExit` | that target, if it accepted | the touch moves off it |
| `dragDrop` | that target, if it accepted | the touch ends on it |
| `dragStop` | every target with a handler for it | the drag ends |

The handlers' return values aren't needed.

## Constants

| Name | Value |
|---|---|
| `DragMgr.EVENT` | `'drag-drop-event'`, the events' `name` |
| `DragMgr.COLOR_BLUE`, `COLOR_LIGHTBLUE`, `COLOR_GREEN`, `COLOR_LIGHTGREEN`, `COLOR_RED`, `COLOR_LIGHTRED`, `COLOR_GREY`, `COLOR_LIGHTGREY` | `{ r, g, b }` tables (0 to 1) for `setFillColor( unpack( ... ) )`, used by the examples |

## Configuration

dmc-dragdrop has no settings. Its `dmc_corona.cfg` section, `[DMC_DRAGDROP]`, can be left out or left empty. The file's format, and the `[DMC_CORONA]` section every DMC library uses, are described in [dmc-corona-boot's Configuration](https://github.com/dmccuskey/dmc-corona-boot/blob/master/docs/configuration.md).

## Known Issues

- **Unregistering the target under the finger breaks the drag.** If `unregister()` is called for the target a drag is over (for example from a timer), every later touch event of that drag raises `attempt to index local 'ds' (a nil value)`: the proxy stays on the screen and holds the touch focus. The basic example unregisters its target after 10 seconds, but a drag at that moment has to be over the target to hit this.
- **One drag at a time.** The Drag Manager keeps one current drop target, so two drags with different fingers at once get mixed up.
- **The end animation uses `x`, `y`.** The proxy moves to the drop target's (or the initiator's) `x` and `y`, which are relative to its parent group. For an object inside a moved or scaled group, the proxy goes to the wrong place.
- **Registering a target twice** sends it `dragStart` and `dragStop` twice.
- **Overlapping targets:** which one gets the drag isn't defined.
- The default proxy's colors can't be changed: pass your own `proxy` instead. Changing `DragMgr.ANIMATE_TIME_SLOW` or `ANIMATE_TIME_FAST` has no effect.
- `DEBUG_ACTIVE` in older copies of `dmc_corona.cfg` isn't read. The module doesn't export its version (0.5.0), and it leaks the global `_extend`.
