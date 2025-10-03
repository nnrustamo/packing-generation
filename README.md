# PackingGeneration (Unix fork)

Linux/Unix focused revival of the original hard‑sphere packing generator by Vasili Baranov.

Removed abandoned Visual Studio artifacts and supply a simple portable build so the code can still be compiled and used on modern systems.

Key changes:
- Dropped Visual Studio artifacts
- Added straightforward `Makefile`
- Added `.gitignore`
- No algorithm logic touched

Quick build:
```bash
make              # release
make debug        # debug
PARALLEL=1 make   # enable MPI if toolchain has it
```
Run (searches for `generation.conf` files recursively):
```bash
./bin/packing_generation
```

For algorithms, parameters, documentation, and citation details (DOI 10.5281/zenodo.580324) see the original upstream project. Cite the original authors for any scientific use.

License: MIT (see `LICENSE.txt`).

Further modernization (warnings cleanup, CMake, tests, CI) intentionally left for future incremental contributions.

Future work (planned):
- Usable Python interface (bindings for generation + analysis)
- Unified VTK & HDF5 output pipeline (structured + binary scientific data)
- Systematic warning & error cleanup
- Performance optimizations
