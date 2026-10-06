# Installation

EmbodiedRSI uses three separate environments: host orchestration, the RoboDojo
simulator, and a thin coding-agent container. Native XPolicyLab evaluation also
uses a small policy-server environment. Run the commands below from the checkout
root. No step needs access to the original private development repository.

## Host Python environment

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements-host.txt -e '.[dev]'
.venv/bin/python -m unittest discover -s tests -v
```

Python 3.11+ is required for orchestration. These tests use deterministic fakes
and CPU resources. The real XPolicyLab transport suite is skipped until that
external dependency is installed. Tests do not validate native physics or model
performance.

`requirements-host.txt` pins the host dependencies used for the export's CPU
validation (Python 3.12.7 on Linux). Keep those pins out of the simulator's
environment, which follows its own upstream dependency constraints.

## RoboDojo runtime and assets

First obtain a working installation using the official
[RoboDojo installation guide](https://robodojo-benchmark.com/doc/usage/install-and-download/).
Install the required assets and initialize the Isaac Lab, CuRobo and XPolicyLab
dependencies according to that revision's instructions. Keep a record of source
commits and asset revisions.

The included provisioning helper copies that installation into this repository:

```bash
bash scripts/prepare_robodojo.sh /path/to/RoboDojo /path/to/conda/envs/RoboDojo
```

It needs `conda`, `rsync`, and a working source conda environment. It creates
`.venv-robodojo/` and `vendor/robodojo/` as independent local installations, rebinds
editable dependencies, and runs the upstream asset-path generator on the new
copy. The original source installation is left in place. The helper retains the
source snapshot's `packaging==23.0` compatibility pin; validate that pin if using
a different native runtime revision.

`vendor/robodojo/.embodiedrsi-provisioned.json` records the source commit,
submodules and hash of pre-existing source patches. The source patch is kept
locally in `.embodiedrsi-source.patch`. These files and all vendor assets are
ignored by Git. Treat the provisioned source as read-only during experiments.

This distribution does not contain the simulator image or the exact historical
runtime patches. A different RoboDojo revision must be validated with the smoke
commands below; code export alone does not reproduce historical scores.

## Codex API configuration

Before starting agents, follow [Configure the Codex API](CODEX_API.md): select
the official API or a compatible gateway, create a dedicated configuration home,
save the API key, and check credentials and endpoint access. Ready-to-copy
templates are provided in `configs/codex.openai.example.toml` and
`configs/codex.custom.example.toml`.

The launcher stages `config.toml` and `auth.json`; a key exported only in the
host shell is not automatically passed to Docker. Keep `EMBODIEDRSI_CODEX_HOME`
set in the shell or job that launches the experiment. The task's `[agent]` model
and reasoning effort override defaults in the Codex configuration.

## Thin agent container

Install a standalone coding-agent CLI on the host and complete the API setup
above. For the included Codex image builder:

```bash
bash scripts/build_agent_image.sh "$(command -v codex)" embodiedrsi-agent:latest
```

The build context contains only the Dockerfile and CLI executables. The agent
image does not contain a simulator, task definitions, credentials or GPU tools.
Docker daemon access is required. The default image matches both task templates.

At runtime, the launcher stages provider configuration and authentication from
`EMBODIEDRSI_CODEX_HOME`, or the operator's normal Codex home if unset. Keep this
directory outside the checkout. Host plugins, memories and project configuration
are excluded from the staged agent home. Edit the explicit `model` and
`reasoning_effort` in the task TOML before starting a new run.

Optional site settings are environment variables:

| Variable | Purpose |
| --- | --- |
| `EMBODIEDRSI_CODEX_HOME` | External CLI configuration and authentication source |
| `EMBODIEDRSI_AGENT_HTTPS_PROXY` | Proxy used by the agent container |
| `EMBODIEDRSI_BUILD_HTTP_PROXY` | Proxy used during image construction |
| `EMBODIEDRSI_AGENT_BASE_IMAGE` | Python base image for the thin agent |
| `EMBODIEDRSI_RUNTIME_DIR` | Host directory for short-lived sockets and locks |
| `EMBODIEDRSI_USE_RECIPE` | `1` includes public task recipes; `0` omits them |

The agent's `filtered` network setting is a Docker bridge with outbound access;
it is not a destination allowlist. `none` disables container networking.

## Smoke check

Use an available GPU assigned to you. These diagnostics use the configured
Playground scene and do not open a formal Test plan or call a model:

```bash
.venv-robodojo/bin/python -m scripts.smoke_robodojo --env-task stack_bowls \
  --gpu 0 --run-dir "runs/$(date +%Y%m%d%H%M)_native_smoke"
.venv/bin/python -m scripts.smoke_session --task RoboDojo --env-task stack_bowls \
  --gpu 0 --run-dir "runs/$(date +%Y%m%d%H%M)_session_smoke"
```

Read each run's `smoke.json`; native simulator shutdown can mask an earlier
exception behind a zero process exit code. Do not report diagnostics as scores.

## Native evaluation policy server

RoboDojo's simulator and the XPolicyLab server can require different versions of
`websockets`. Keep the policy server in a separate environment:

```bash
python3 -m venv .venv-robodojo-policy
.venv-robodojo-policy/bin/python -m pip install -e '.[policy]'
```

The policy bootstrap imports the repository-local `vendor/robodojo/XPolicyLab`.
Install any additional dependencies required by that upstream revision in the
policy environment. See [the integration guide](../integrations/robodojo_policy/README.md)
for native evaluation and the optional image/Slurm route.
