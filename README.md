# grommunio-archive (Debian packaging)

Debian packaging for grommunio Archive — [grommunio](https://grommunio.com/)'s
rebrand and extension of [Piler](https://piler.io/) ([jsuto/piler](https://github.com/jsuto/piler))
for long-term email archiving, integrated with grommunio's own
authentication, Keycloak/OIDC SSO, and Postfix copy-to-archive setup.

## Platform

Built and packaged for Debian 13 (trixie); not tested on other
distributions or Debian releases.

## Repository structure

This repository contains both the upstream Piler source and the
Debian packaging on top of it:

- **`upstream` branch** — piler's own git history, unmodified, from
  [jsuto/piler](https://github.com/jsuto/piler), currently at tag
  `piler-1.4.9`. Piler's own README is kept as `README.upstream.md`
  (this file would otherwise be overwritten by a merge from that
  branch).
- **`main` branch** (this one) — the `upstream` branch merged with
  `debian/` (patches, changelog, maintainer scripts, systemd units)
  added on top. This is what gets packaged.

Grommunio itself does not publish Piler as git (only as a patched
source RPM in their community repository), so this repo clones real
upstream directly and tracks grommunio's patches as our own
`debian/patches/` on top of it, instead of only carrying the
packaging and fetching the source tarball separately at build time.

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
dpkg-source -b .
sbuild <resulting>.dsc
```

(Run from a checkout of the `main` branch — the source tree and
`debian/` are both already here, no separate tarball fetch needed.)

## Updating to a newer piler release

```
git fetch piler-upstream tag piler-1.4.X
git branch -f upstream piler-1.4.X
git checkout main
git merge upstream
# resolve any conflicts in README.upstream.md/.gitignore if upstream changed them,
# rebase debian/patches/ against the new source, bump debian/changelog
```

## Provenance

Packaging and the patches listed above: Louis van Belle. Everything
else carried forward from grommunio's own community packaging - see
`debian/copyright` for the full attribution, including upstream
Piler's own (jsuto, sj@acts.hu).
