# grommunio-archive (Debian packaging)

Debian packaging for grommunio Archive — [grommunio](https://grommunio.com/)'s
rebrand and extension of [Piler](https://piler.io/) ([jsuto/piler](https://github.com/jsuto/piler))
for long-term email archiving, integrated with grommunio's own
authentication, Keycloak/OIDC SSO, and Postfix copy-to-archive setup.

This repository contains **only the Debian packaging** (`debian/`:
patches, changelog, maintainer scripts, systemd units) — not the
upstream source. The orig tarball comes from the grommunio community
source repository at build time; see `debian/changelog` for the exact
upstream tag/commit each release tracks.

## What the patches do

Most patches in `debian/patches/` are carried forward unchanged from
grommunio's own community packaging (branding, web UI paths,
spool/directory creation, the OIDC login flow, the 2FA/four-eyes login
page). A few are specific to this packaging:

- **`0006-debian-mysql-socket.patch`** — points at Debian's own MySQL
  socket path instead of the RPM-distribution default.
- **`0009-audit-mysql-without-rt.patch`** — real bugfix: Piler 1.4.6
  moved the audit trail to the Manticore real-time (RT) index and
  returns early when `RT=0`. An install using the plain Sphinx index
  (`RT=0`, the Debian default here) silently lost the audit viewer,
  CSV export, and per-hour download/restore limits, since they read an
  index that never existed. With `RT=0`, this reads/writes the MySQL
  audit table instead, as Piler 1.3.x did; `RT=1` installs are
  unaffected.

See `debian/changelog` for the full history, including an earlier fix
to the community's own `use_libxls.patch` (dropped in favor of
catdoc's `xls2csv`, which actually takes its arguments in the order
Piler calls it with — the libxls tool's `xls2csv` does not).

## Building

```
# Fetch the upstream source tarball matching the version in
# debian/changelog (see that entry for which upstream tag/commit),
# then:
dpkg-source -b <extracted-source-dir>
sbuild <resulting>.dsc
```

## Provenance

Packaging and the patches listed above: Louis van Belle. Everything
else carried forward from grommunio's own community packaging - see
`debian/copyright` for the full attribution, including upstream
Piler's own (jsuto, sj@acts.hu).
