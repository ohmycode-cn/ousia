# ousia

A small C23 project scaffold with a CMake build and a helper script for creating source/header pairs.

## Layout

```
project/
├── inc/          # production headers
├── src/          # production sources
└── test/
    ├── api/      # reserved for test framework API
    ├── ife/      # test entry (main when UNIT_TEST=ON)
    ├── inc/      # test headers
    └── src/      # test sources
```

Binaries are written to `output/bin/ousia`.

## Build

```bash
cmake -S . -B build
cmake --build build
./output/bin/ousia
```

### Options

| Option | Default | Meaning |
|--------|---------|---------|
| `UNIT_TEST` | `ON` | Collect and compile sources under `project/test` |

Disable tests:

```bash
cmake -S . -B build -DUNIT_TEST=OFF
cmake --build build
```

Optional machine-local CMake overrides may be placed in `local.require.cmake` (git-ignored).

## Create files

`makefs.sh` scaffolds `.h` / `.c` pairs under the project tree:

```bash
# production: project/inc/foo.h + project/src/foo.c
bash makefs.sh --file foo

# test: project/test/inc/foo.h + project/test/src/foo.c
bash makefs.sh --type --file foo

# .c only, no paired header include
bash makefs.sh --file foo --not-h
```

Flags: `--path/-p`, `--file/-f`, `--type/-t`, `--not-h`, `--help/-h`. Argument order is free.

## License

All rights reserved unless otherwise noted.
