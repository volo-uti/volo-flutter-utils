---
name: add-component
description: Use when adding a function, extension or helper to volo_flutter_utils. Follows the order of file layout, barrel export, tests and index update.
---

# Add a utility

Paths are relative to the repository root.

1. Look in the `AGENTS.md` index first for an existing utility that fits. If there is none, say what you searched for, then build.
2. Pick the section: `extensions` (an extension on a core type, named `V<Type>Extension`), `helpers` (a class or function of its own) or `validators`. Write `lib/src/<section>/<file>.dart`. Give every public declaration a `///` first sentence of at most 90 characters (the index and docs are built from it).
3. Export the file from the barrel `lib/volo_flutter_utils.dart`, under the comment of its section.
4. Write the test `test/<section>/<file>_test.dart`. Model it on an existing test in the same section. If the behavior depends on the time zone, add the case to `test/extensions/datetime_dst_test.dart`, which `make test` also runs under `TZ=America/New_York`.
5. From the repository root, run `make index` to rewrite the index and docs, and finish with `make check`.

Never edit `doc/` by hand.
