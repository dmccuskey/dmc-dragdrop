# Development

How dmc-dragdrop is built and tested, and what could change.

## Where the Code Lives

Only `dmc_corona/dmc_dragdrop.lua` is written in this repository, along with the example apps' own files (`main.lua`, `drop_target.lua`, `assets/`). The rest of `dmc_corona/`, `dmc_corona_boot.lua`, and each example's copy of them are generated: they are copied from the repositories that own them by the build below. Fix a generated file in its own repository, then rebuild:

| file | owner |
|---|---|
| `dmc_objects.lua` | [dmc-objects](https://github.com/dmccuskey/dmc-objects) |
| `dmc_states_mix.lua` | [dmc-states-mixin](https://github.com/dmccuskey/dmc-states-mixin) (used by dmc-objects) |
| `dmc_utils.lua` (dmc-dragdrop-oop only) | [dmc-utils](https://github.com/dmccuskey/dmc-utils) |
| `dmc_corona_boot.lua` | [dmc-corona-boot](https://github.com/dmccuskey/dmc-corona-boot) |
| `lib/dmc_lua/` | [DMC-Lua-Library](https://github.com/dmccuskey/DMC-Lua-Library) |

The `dmc_corona.cfg` files, at the root and in each example, aren't generated: edit them here.

## Building

The `Snakefile` lists this library's files, the libraries it requires, and the example apps. The build rules are in [DMC-Corona-Library](https://github.com/dmccuskey/DMC-Corona-Library) (`snakemake/Snakefile`), which expects every required repository checked out next to this one. From this repository:

```sh
snakemake --cores 1 build_all     # dmc_corona/ and every examples/*/dmc_corona/
snakemake --cores 1 -n build_all  # dry run: show what would be copied
```

The build copies the sibling checkouts as they are on disk, on whatever branch each one has checked out.

## Testing

The tests are in `tests/dmc_dragdrop_spec.lua` ([lunatest](https://github.com/silentbicycle/lunatest)). Run them with plain Lua 5.1, with stand-ins for the Solar2D globals they touch (`display`, the stage's `setFocus()`, `transition.to()`); it needs the `dkjson` rock:

```sh
tests/run_unit.sh                  # uses ../tools/lua51/bin/lua
LUA=lua5.1 tests/run_unit.sh       # or another Lua 5.1
```

Then run both examples in the Solar2D Simulator and drag onto each target, and away from it. A drag can also be scripted, to test without a mouse or for a screenshot: after `doDrag()`, the proxy is the top child of the stage, and it takes touch events from `dispatchEvent()`:

```lua
local function touch( o, phase, x, y )
	o:dispatchEvent{ name='touch', phase=phase, target=o, x=x, y=y }
end

DragMgr:doDrag( item, { x=160, y=400 } )
local stage = display.getCurrentStage()
local proxy = stage[ stage.numChildren ]
touch( proxy, 'moved', 160, 200 )
touch( proxy, 'ended', 160, 200 )
```

## Possible Future Changes

Each needs discussion and a concrete use case before it is worked on.

- Give overlapping targets a defined order: the one drawn on top, or a priority ([#1](https://github.com/dmccuskey/dmc-dragdrop/issues/1)).
