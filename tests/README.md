# Tests

Characterization tests: they pin what `entrypoint.sh` renders **today**, bugs
included, so any change to the generator shows up as a diff.

One directory per case, holding its input and its expected output:

```
tests/<case>/env                     the environment, passed as --env-file
tests/<case>/existing.ini            optional, mounted at the config path
tests/<case>/expected/pgbouncer.ini  what the entrypoint renders
tests/<case>/expected/userlist.txt
tests/<case>/expected/output.txt     for cases the entrypoint is meant to reject
```

- `run.sh` — renders every case and compares it to `expected/`
  - directives, read from comments at the top of an `env`:
    - `# boot: yes` — pgbouncer must start with the rendered file
    - `# boot: fails` — pgbouncer must refuse it
    - `# expect: failure` — the entrypoint itself must exit non-zero, and its
      output is compared against `expected/output.txt`
  - `existing.ini` is an input, mounted at the config path, to assert the
    entrypoint leaves an already-present config alone
- `coverage.sh` — fails when `entrypoint.sh` reads a variable no case sets
  - line coverage would not catch that: the ~70 knobs share two `printf`
    statements, so any case marks them all covered
- `live.sh` — one postgres, one pooler, a real query through it
  - asserts `SHOW CONFIG` and `SHOW DATABASES` off the running pooler, not the
    generated text, so a setting the entrypoint writes but pgbouncer ignores
    cannot pass
  - its expectations live in `tests/live/expected/`, and they move when the
    pinned pgbouncer version changes; that diff is the review signal for a bump

`run.sh` and `live.sh` take `IMAGE` (default `edoburu/pgbouncer:test`) and
`UPDATE_EXPECTED=1`. `live.sh` also takes `POSTGRES_IMAGE`, which CI runs over
the two latest majors; both produce the same expectations.

```bash
make docker-x86 IMAGE_VERSION=test
tests/coverage.sh
tests/run.sh
tests/live.sh
```

## Behaviours pinned as-is

- `CLIENT_ENCODING` renders `client_encoding = ...` inside `[databases]`, where
  pgbouncer reads it as a database entry and refuses to load the file. Setting
  that variable means the container never starts — see `client-encoding/env`.
- `DATABASE_URLS` entries are parsed in one subshell, so `DB_PORT`, `DB_USER`,
  `DB_PASSWORD` and `DB_NAME` carry over from the previous URL when the next one
  omits them. In `database-urls-multiple/env` a port-less third URL inherits
  `5433` from the second, while the same URL alone defaults to `5432`.
- `[databases]` entries carry no `pool_size` and no `dbname`, so every pool
  inherits `default_pool_size` and an alias must be a real database name.
