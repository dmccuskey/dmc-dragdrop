# Changelog

## 0.6.0 (2026-10-01)

### Fixed

- Unregistering the drop target a drag is over no longer breaks the drag. Every later touch event of that drag raised `attempt to index local 'ds' (a nil value)`, and the proxy stayed on the screen holding the touch focus; now the drag carries on as if over nothing. Unregistering from inside a handler works too.
- Several drags at once: each drag keeps its own drop target and acceptance, and the proxy gets the focus of its own touch only (`stage:setFocus( proxy, event.id )`), so two fingers no longer mix up each other's drags. `acceptDragDrop()` applies to the drag being handled.
- The end animation goes to the centre of the target (or of the initiator) on the screen, so it lands in the right place inside moved or scaled groups. A proxy inside a group follows the finger correctly too.
- Registering a target twice no longer sends it `dragStart` and `dragStop` twice: the second `register()` replaces the first.
- Setting `DragMgr.ANIMATE_TIME_FAST` or `ANIMATE_TIME_SLOW` takes effect.
- A target with no display object (no `view`) is skipped, with one warning, instead of crashing the hit test.
- The module no longer sets the global `_extend`; its unused copy of `Utils.extend()` and the unread `debug_active` setting are gone.

### Added

- `doDrag()` options `fillColor`, `strokeColor` and `strokeWidth`, for the default proxy.
- `DragMgr.VERSION`.
- Unit tests (stand-in display, stage and transition), and `tests/run_unit.sh` to run them with plain Lua 5.1.

### Changed

- Rebuilt against the current dmc-corona-boot, DMC-Lua-Library and dmc-objects.
