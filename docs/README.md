# dmc-dragdrop Documentation

New here? The [Quick Start](../README.md#quick-start) sets up a drag and a drop target in about 10 minutes.

## Start

- [Quick Start](../README.md#quick-start): copy the library in, drag onto a target, accept only some drags

## Use

- [Using dmc-dragdrop](using-dragdrop.md): initiators, proxies and drop targets, starting a drag, the drag and drop cycle, formats and data, drop targets as objects
- [API reference](api.md): `doDrag()`, `register()`, `unregister()`, `acceptDragDrop()`, events, constants, configuration, known issues
- [Examples](../examples/): a basic drop target with a score, and drop targets as dmc-objects classes that accept different formats

## Contribute

- [Development](development.md): which files are generated, building, testing, possible future changes
- [Issues](https://github.com/dmccuskey/dmc-dragdrop/issues)

## Project Structure

```text
README.md                   landing page and Quick Start
LICENSE
docs/                       this documentation
└── images/                 screenshots for the README
dmc_corona/                 what apps copy
├── dmc_dragdrop.lua        the Drag Manager (source)
├── dmc_objects.lua         } libraries dmc-dragdrop uses (generated copies)
├── dmc_states_mix.lua      }
└── lib/dmc_lua/            DMC Lua library (generated copy)
dmc_corona_boot.lua         loader, from dmc-corona-boot (generated copy)
dmc_corona.cfg              library configuration
examples/                   sample apps, each with its own generated dmc_corona/
└── screenshots/            one per app, for examples/README.md
Snakefile                   build rules for the generated copies
```
