# [1.8.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.7.0...v1.8.0) (2026-11-08)


### Bug Fixes

* currently only allow social providers ([4077a50](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/4077a50f3da869b71481d1ca0a3429ed7cf6b82d))


### Features

* add login with amazon ([fd2a876](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/fd2a876a39e0facc6c44ec8e44a7487d394908ad))
* allow other login providers ([34af07e](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/34af07e71deb7dde8c274b92546425e39e68eed6))

# [1.7.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.6.0...v1.7.0) (2026-11-08)


### Bug Fixes

* fix outputs, add local decision, fix ocmments ([dab390a](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/dab390a44de33f0294367529a64a283be9036955))


### Features

* add edge client module ([2c1381b](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/2c1381b9db2f251dbf122855b8d55be2fac79504))
* add edge client module ([ab6ac1b](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/ab6ac1b4cdb94e3d841faea5feef8fc67a902dfe))
* edge client to public or private client ([21b2b36](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/21b2b366ec672f4a12e91fd1a4e21075fb34278f))
* remove edge client ([605820f](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/605820fc6dc93672f1de6e882c53bf9008062bc5))

# [1.6.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.5.0...v1.6.0) (2026-11-08)


### Features

* edge cognito client ([50b0e6b](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/50b0e6be11c3354b9c768d94fd1ddb62e096cbe3))
* edge cognito client, remove public ([b7bb6ad](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/b7bb6ad5cbb73d68b0e4030ef9e7490326285eab))

# [1.5.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.4.0...v1.5.0) (2026-11-08)


### Features

* add cognito auth modle ([a15c779](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/a15c779d8db1e83c001dfcfe23c45a6bb9db4ef6))

# [1.4.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.3.0...v1.4.0) (2026-11-08)


### Bug Fixes

* disallow friendly name starting with hyphen ([75c2bb7](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/75c2bb74aaf8b521083ef66df4ca9e2811981988))
* name fixes and char length restrcitions ([696207a](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/696207a487892ba45b8c8264ee12ba14e3b2accb))
* user lower for dist name ([3aef8f6](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/3aef8f6eb18cb0e267d1c630df542785e0f7189d))


### Features

* enforce friendly name for length restrictions ([ad21d82](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/ad21d82c5521f31944303f26a2277adef65dcd84))

# [1.3.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.2.4...v1.3.0) (2026-11-08)


### Bug Fixes

* addlow more variable customizations ([0384571](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/03845710a5abd25f18ea0fc23d95233d99995425))
* limit domain length, remove -distribution from s3 name ([91fdc1e](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/91fdc1e4a6f42c80ec226e67eaa68c866e9ae72b))
* order certificate validation ([78d3ec6](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/78d3ec6fbf920960186bd1a77f13287bb93e879c))
* remove partition, restore caller identity ([eb10c9e](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/eb10c9ede58d99b6040f69ff1634f134a925db93))
* remove unused resources ([ed6dc01](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/ed6dc011510e1853fb1d68714a4c1e83520cdeeb))
* spelling and output fixes ([0c6961d](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/0c6961de931ed811fe1c6c994a19724cff3724b0))
* udpate tag order and enforce dual region kms if selected ([39ff55a](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/39ff55a22908e08460946ed7deba88f2d2866405))
* update validations and comments ([ee26b4a](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/ee26b4a91354c01d3ffd85850a92454d05893332))
* use current versions ([689dd55](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/689dd55bef3bdd41b296354e0f08a6255b77b906))


### Features

* add dns validation and records ([a5869cc](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/a5869cc42dacb979c9376637e83382b7bb696d71))
* updated headless cloudfront distro with s3 failover ([5255360](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/525536004f090f684d4023c157a6ffada40155be))
* updated headless cloudfront distro with s3 failover ([9ac2eba](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/9ac2eba6978600c919943ff1c5470e5708b9262f))

## [1.2.4](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.2.3...v1.2.4) (2024-09-11)


### Bug Fixes

* **testing:** Test readd policy. ([a1dddec](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/a1dddec41ff4a53d7cc0c4488705ab8ea307c8c4))

## [1.2.3](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.2.2...v1.2.3) (2024-09-11)


### Bug Fixes

* **testing:** Test readd dns. ([e587040](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/e587040491405b1b6ddcab40bc18caa79b7fc099))

## [1.2.2](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.2.1...v1.2.2) (2024-09-11)


### Bug Fixes

* **testing:** Remove iam roles for now. ([2647e8c](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/2647e8c7cbbc77e4205f1e58386fe2beb608dfd2))

## [1.2.1](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.2.0...v1.2.1) (2024-09-10)


### Bug Fixes

* **resolves #19:** Add missing providers. ([5b8c007](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/5b8c0076c0cc1e51af99fdd8e6a3708000f4d529)), closes [#19](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/19)

# [1.2.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.6...v1.2.0) (2024-09-10)


### Features

* **resolves #17:** Github deployment role. ([b66dc7c](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/b66dc7c2866fa5c70f35b8e8008103ad44d24688)), closes [#17](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/17)

## [1.1.6](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.5...v1.1.6) (2024-09-09)


### Bug Fixes

* **resolves #15:** Use AES256. ([a1c6309](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/a1c630986730cabc61701075398349b4953d1447)), closes [#15](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/15)

## [1.1.5](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.4...v1.1.5) (2024-09-08)


### Bug Fixes

* **resolves #13:** Upgrade to s3 3.0.1. ([796ec9e](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/796ec9eefde5e8cf4ffde4ab416ab76780be559e)), closes [#13](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/13)

## [1.1.4](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.3...v1.1.4) (2024-09-08)


### Bug Fixes

* **resolves #11:** Switch from aws_s3_bucket_object to aws_s3_object. ([e576ffb](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/e576ffb6f214add7dc763b5cfcd50ff5d41dfd55)), closes [#11](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/11)

## [1.1.3](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.2...v1.1.3) (2024-09-08)


### Bug Fixes

* **resolves #9:** Test index.html option. ([d8f90b2](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/d8f90b2138394d1218e3c07bfd14c8bc8bcecf1e)), closes [#9](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/9)

## [1.1.2](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.1...v1.1.2) (2024-09-08)


### Bug Fixes

* **resolves #7:** Fix hosted zone lookup provider. ([28b4ff4](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/28b4ff481ed59f6fb8969d83ecd14ccf89057395)), closes [#7](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/7)

## [1.1.1](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.1.0...v1.1.1) (2024-09-08)


### Bug Fixes

* **resolves #5:** Fix domain validation options. ([df65077](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/df65077cde02b69022209e76f115856ce4d2a4d9)), closes [#5](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/5)

# [1.1.0](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/compare/v1.0.0...v1.1.0) (2024-09-08)


### Features

* **resolves #3:** Add dns and outputs. ([9844010](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/9844010bf98bf40dd7ff5a13aebdb7054f450a99)), closes [#3](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/3)

# 1.0.0 (2024-09-08)


### Features

* **resolves #1:** Initial implementation. ([458179b](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/commit/458179bee1c60e35b1ce5763ef7bb5bc12c1c58a)), closes [#1](https://github.com/flagscript/terraform-aws-flagscript-headless-distribution/issues/1)
