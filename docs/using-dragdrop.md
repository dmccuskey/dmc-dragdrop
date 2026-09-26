# Using dmc-dragdrop

How a drag and drop works, and how to set one up. The [API reference](api.md) lists every call and option.

## The Parts of a Drag

```lua
local DragMgr = require 'dmc_corona.dmc_dragdrop'
```

The module is the **Drag Manager**, one object for the whole app (a singleton): you don't create it, you tell it about drags and drop targets. A drag has four parts:

- The **drag initiator**: the object the user touches to start a drag. Any display object with a touch listener.
- The **drag operation**: started with `DragMgr:doDrag()` from that touch listener. It can carry a `format` and `data`, so drop targets know what is being dragged.
- The **drag proxy**: what moves under the finger. It stands in for the initiator, which stays where it is. By default it is a grey square the size of the initiator.
- The **drop targets**: the places things can be dropped. Any display object (or [dmc-objects](https://github.com/dmccuskey/dmc-objects) component), registered with `DragMgr:register()` along with the events it wants.

Most of your code goes into the drop targets' event handlers.

## Starting a Drag

Call `doDrag()` from the initiator's touch listener, on the `'began'` phase, with the initiator and the touch event:

```lua
local function onTouch( event )
	if event.phase == 'began' then
		DragMgr:doDrag( event.target, event )
	end
	return true
end

item:addEventListener( 'touch', onTouch )
```

The Drag Manager places the proxy at the touch point and gives it the touch focus, so the rest of the touch (moves, release) goes to the proxy, not to the initiator. Your listener sees only `'began'`.

A third argument describes the drag:

```lua
DragMgr:doDrag( event.target, event, {
	proxy = myProxy,      -- a display object to drag instead of the grey square
	format = 'fruit',     -- what is being dragged, for the drop targets
	data = { name='apple', price=2 },  -- anything else they need
	yOffset = -30,        -- show the proxy above the finger
	alpha = 0.8,          -- the proxy's alpha (default 0.5)
} )
```

Create a new proxy for each drag: the Drag Manager removes it (`removeSelf()`) when the drag ends. The finger decides where a drop lands, not the proxy: with an offset, the proxy is drawn away from the touch point, but the target under the touch point is the one that counts.

## Drop Targets

Register each drop target with the handlers for the events it wants:

```lua
DragMgr:register( target, {
	dragStart = onDragStart,
	dragEnter = onDragEnter,  -- needed to accept anything
	dragOver = onDragOver,
	dragExit = onDragExit,
	dragDrop = onDragDrop,
	dragStop = onDragStop,
} )
```

Every handler is optional, but a target without `dragEnter` can never accept a drag, so it never gets `dragOver`, `dragExit` or `dragDrop`. Each handler receives an event:

```lua
{
	name = 'drag-drop-event',  -- DragMgr.EVENT
	target = <the drop target, as registered>,
	format = <the format given to doDrag()>,
	data = <the data given to doDrag()>,
}
```

`DragMgr:unregister( target )` removes a target. Do it before you remove the target from the screen, and not while a drag is over it ([Known Issues](api.md#known-issues)).

## The Drag and Drop Cycle

| Event | Sent to | When |
|---|---|---|
| `dragStart` | every target with a `dragStart` handler | `doDrag()` starts a drag |
| `dragEnter` | the target under the finger | the finger moves onto it. Call `DragMgr:acceptDragDrop()` here to accept the drag. |
| `dragOver` | the target under the finger, if it accepted | each move while the finger stays on it |
| `dragExit` | the target the finger left, if it accepted | the finger moves off it without dropping |
| `dragDrop` | the target under the finger, if it accepted | the finger is lifted over it |
| `dragStop` | every target with a `dragStop` handler | the drag ends, dropped or not |

In short: `dragStart` and `dragStop` bracket every drag, on every target, so a target can show whether it would take this drag before the finger gets there, and undo it afterwards. `dragEnter` and `dragExit` bracket the time the finger is over one target; `dragEnter` is where the target looks at `event.format` or `event.data` and accepts, or not. `dragDrop` is where the drop happens: add the item to the basket, the record to the list.

Some details:

- After `dragDrop` there is no `dragExit`: reset the target's look in `dragDrop` too (the examples call their `dragExit` handler from it).
- Only the touch point is tested, against each target's `contentBounds`. Where targets overlap, which one gets the drag isn't defined.
- When a drop is accepted, the proxy moves to the target's `x`, `y` and shrinks, in 100 ms. Otherwise it slides back to the initiator's `x`, `y`, in 300 ms. Then it is removed. `dragStop` is sent as the animation starts.

## Formats and Data

`format` is usually a short string that says what kind of thing is being dragged ("fruit", "database-record", "red"). Drop targets check it in `dragStart` (to highlight themselves) and in `dragEnter` (to accept):

```lua
local function onDragEnter( event )
	if event.format == 'fruit' then
		DragMgr:acceptDragDrop()
	end
end
```

For a simple drag, the format may be all a target needs. When it needs more, pass it in `data`: a string, a number, a table, a display object, a database record. It usually matters in `dragDrop`.

## Drop Targets as Objects

`register()` without a table of handlers calls the target's own methods instead, with the target as `self`:

```lua
local DropTarget = newClass( ComponentBase, { name='Drop Target' } )

function DropTarget:dragEnter( event )
	if event.format == self._format then
		DragMgr:acceptDragDrop()
	end
	return true
end

function DropTarget:dragDrop( event )
	self:_incrementScore()
	return true
end

-- ...
local target = DropTarget:new{ format='red' }
DragMgr:register( target )
```

Such a target doesn't have to be a display object. If it isn't one, the Drag Manager uses its `view` property (the display group of a [dmc-objects](https://github.com/dmccuskey/dmc-objects) component) for the hit test. For objects that keep their display object under another name, set it once: `DragMgr.display_name = 'display'`.

The [dmc-dragdrop-oop](../examples/) example is built this way, with three targets that accept different formats.
