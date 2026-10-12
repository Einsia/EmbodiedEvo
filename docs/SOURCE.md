# Source provenance and release scope

Prepared on 2026-10-06 from the local development working tree. The export includes
selected uncommitted implementation changes; it is not an archive of `HEAD` alone.
[SOURCE_MANIFEST.json](../SOURCE_MANIFEST.json) records the base commit, original
file hashes and hashes of the current files. The EmbodiedEvo naming update on
2026-10-13 refreshed current paths and hashes (`path` / `sha256`); original
source paths, hashes and the base commit remain unchanged. `prepared_on` records
the export date and `updated_on` records the latest manifest refresh.
The manifest contains no private remote URL.
The original file paths in that manifest retain historical policy names for
traceability; runtime and package names use EmbodiedEvo.

The exported source was prepared as an independent copy with its own Git
directory, no configured remote at export, no inherited commit history, and no
links or hardlinks to the development checkout. All preparation edits were made
in the new directory.

## Included

- RoboDojo four-primitives adapter and persistent Python execution.
- Playground, frozen Skills/Lessons and independent Test sessions.
- Test-only baseline and handwritten workspace templates.
- XPolicyLab policy, local native evaluation, and the shared single-scene image
  executor with an existing-allocation GPU check.
- Thin agent image definition, runtime setup/diagnostic scripts and CPU tests.
- Unmodified public recipe text, its license and checksum manifest.

## Excluded

Other benchmark backends, experiment outputs, logs, videos, dashboards, report
archives, virtual environments, simulator source/assets/images, model credentials,
private configuration, cluster schedulers, historical recovery scripts and the
private distributed Final deployment are not part of this source export.
No frozen learned harnesses or reported-score artifacts are included.

## Preparation changes

The package, CLI, policy name, environment variables, container names, network
and socket names use `embodiedevo` / `EMBODIEDEVO` / `EmbodiedEvo`. The scientific
protocol identifier remains `workspace-session-v1`. Only RoboDojo is registered.
Task goals, budgets, primitive manuals and recipe contents are preserved.

The private campaign scheduler is omitted; its small GPU-index parser is retained
for the optional Slurm executor. Native logging pipe reservation is extracted
into `pipe_capacity.py`, independent of the private Final launcher. Historical
image installations may have an extension cache under `/opt/eah/kit-ext-cache/3`;
that compatibility default is an image path, and can be replaced through
`kit_ext_cache` in the supplied runtime profile.

Host-specific tests now use temporary fixtures. Shared CPU tests no longer import
an optional transport-test module, and native transport tests explicitly skip
until their external dependencies are installed. Packaging includes the policy
and script modules and excludes the dashboard. Use an editable source install.

## Validation at export

- Fresh temporary Python environment: editable install and `pip check` passed.
- Unit tests: 88 discovered; 87 passed and one optional XPolicyLab suite skipped.
- CLI help, Python/TOML parsing, shell syntax, local-module imports and critical
  undefined-name checks passed.
- Both task configurations prepare with their default recipes; all 42 recipe
  hashes match the original manifest.
- Source/configuration screening excluded private host paths, provider endpoints,
  credential files and prior experiment evidence.

No GPU simulator, Docker image build or model call was run for this export.
Native runtime compatibility and historical result reproduction remain unverified.
Choose the project-wide license before publishing; the recipe license remains
separate.
