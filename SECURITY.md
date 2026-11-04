# Security policy

## Supported versions

Only the latest release gets security fixes. A fix lands in a new release,
never in an older version; update with `swift package update` or Xcode's
**File, Packages, Update to Latest Package Versions**.

## Report a vulnerability

Report it privately through GitHub's
[private vulnerability reporting](https://github.com/Vernum-Projecten/simple-icons-swift/security/advisories/new)
(the repository's **Security** tab, **Report a vulnerability**). Do not open a
public issue, pull request or comment about it.

Include what you can: the package version, what an attacker can do and what
they need first, the steps or a proof of concept, and any idea for a fix.

## What happens next

- an acknowledgement within a week;
- a first assessment, and whether it is accepted, within two weeks;
- a fix in a release as soon as it is ready, with a GitHub security advisory
  published at the same time, crediting you unless you prefer otherwise.

Please keep the report private until the advisory is published.

## Scope

In scope:

- **The package**: the SVG path parser and the SVG it writes (for example
  path data that makes the parser hang or use unbounded memory, or a
  `fill` value that escapes its attribute in `svg(fill:)`).
- **The supply chain of the icons**: `scripts/dev/update-icons.sh`, the
  generator and `.github/workflows/icons.yml`, which download the
  simple-icons npm package and check it against its sha512.
- **The release lane**: the workflows and scripts that publish a release.

Out of scope:

- the icons themselves and their data: report to
  [Simple Icons](https://github.com/simple-icons/simple-icons/security);
- the trademarks of the brands, which are a legal question, not a security
  one (see the README's legal section).
