# Security Policy

## Supported versions

Security fixes go into the latest release of `volo_flutter_utils` and into the default branch. Older releases are not patched; upgrade to the latest one.

## Reporting a vulnerability

Please do not open a public issue, pull request or discussion for a security problem.

Report it privately through GitHub:

1. Open this repository's **Security** tab.
2. Choose **Report a vulnerability**
   ([direct link](https://github.com/volo-uti/volo-flutter-utils/security/advisories/new)).
3. Describe the problem.

Please include:

- the package and version affected (`volo_flutter_utils`), and the Flutter and Dart versions you use
- the platform where it happens (iOS, Android, macOS, Windows or Linux)
- the steps to reproduce it, with a minimal example if you can
- what you expect the impact to be

## What to expect

- We acknowledge your report within 7 days.
- We then confirm whether it is a vulnerability, tell you what we plan to do, and keep you informed until it is resolved.
- We fix confirmed problems in a new release and publish a GitHub security advisory that credits you, unless you prefer to stay anonymous.
- Please give us a reasonable time to ship a fix before you disclose the problem publicly. We will coordinate the date with you.

## Scope

The package is client-side utility code. It makes no network requests of their own and do not collect or transmit data. Reports that fit this scope include:

- a vulnerable dependency that the package pulls in
- functions that mishandle untrusted input, for example a crash or a hang on malformed text
- a problem in the publishing workflow that could affect the released package

Bugs that are not security problems belong in the [issue tracker](https://github.com/volo-uti/volo-flutter-utils/issues).
