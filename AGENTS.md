# EmbodiedEvo development boundaries

This repository contains the RoboDojo reproduction source. Read README.md and
docs/PROTOCOL.md before changing execution or evaluation behavior.

- Preserve `workspace-session-v1`: persistent Python sessions and exactly four
  primitives: `get_instruction()`, `get_observation()`, `step(action)`, and
  Playground-only `reset()`. Keep the primitive manual handwritten.
- Only `skills/` and `lessons/` transfer from Playground to Test. Freeze them
  before selecting Test scenes. Each Test gets a fresh agent, workspace and
  simulator; knowledge is read-only, and reset and cross-scene learning are forbidden.
- Preserve task goals, native action limits, success checks and raw feedback.
  Do not add a model to summarize observations or videos.
- Keep ledgers, private rewards, scene plans and simulator sources outside the
  agent workspace. The agent image has no simulator or GPU access.
- Treat `vendor/` as read-only after provisioning. Put compatibility adapters
  in `simulators/` or `integrations/`; do not redirect to another project checkout.
- Every invocation needs an explicit `--run-dir` with a `YYYYMMDDHHMM` prefix.
  Never copy results, credentials, environments or machine configuration into Git.
- Preserve failed attempts. Model-written code failures count as model failures.
  Only confirmed infrastructure failures are candidates for an explicitly recorded
  rerun; crashes, timeouts and missing reports alone do not establish causation.
- Use `python -m unittest discover -s tests -v` for CPU validation. GPU experiments,
  container builds and model calls are separate operations requiring actual resources.
- Keep the third-party recipe text, license and checksums unchanged. Record its use
  as supplied task knowledge, separately from learned Skills/Lessons.
