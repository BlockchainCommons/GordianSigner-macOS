# Blockchain Commons GordianCosigner-macOS

### _by [Peter Denton](https://github.com/Fonta1n3) and [Christopher Allen](https://github.com/ChristopherA)_
* <img src="https://github.com/BlockchainCommons/Gordian/blob/master/Images/logos/gordian-icon.png" width=16 valign="bottom"> ***part of the [gordian](https://github.com/BlockchainCommons/gordian/blob/master/README.md) technology family***

![](https://raw.githubusercontent.com/BlockchainCommons/GordianSigner-Catalyst/master/images/logos/gordian-signer-screen.jpg)

**Gordian Cosigner** allows users to participate in a multisig by adding a signature to an otherwise unsigned or partially signed PSBT, where they did not initiate the transaction. It can also be used for signing a single-signature PSBT. It's largely intended as an offline signing tool, which allows signing without the usage of a full node: a real wallet is need to both initiate an account map and to initiate a transaction.

## Additional Information

This is a companion app for the Gordian system:

* [Gordian system](https://github.com/BlockchainCommons/Gordian) — A self-sovereign Bitcoin wallet and node

**Gordian Cosigner** is a multiplatform utility that's also available as:

* [GordianCosigner for Android](https://github.com/BlockchainCommons/GordianSigner-Android)
* [GordianCosigner for iOS](https://github.com/BlockchainCommons/GordianSigner-Catalyst)

Some of Cosigner's functioanlity has been superceded by the newer Gordian SeedTool app:

* [Gordian SeedTool](https://github.com/BlockchainCommons/GordianSeedTool-iOS) — An app for storing seeds and for signing PSBTs with those seeds

However, they both remain useful reference apps for demonstrating the use of Gordian Principles and Blockchain Commons specifications.

## Gordian Principles

**Gordian Cosigner** is a reference implementation meant to display the [Gordian Principles](https://github.com/BlockchainCommons/Gordian#gordian-principles), which are philosophical and technical underpinnings to Blockchain Commons' Gordian technology. This includes:

* **Independence.** Cosigner allows you to sign PSBTs in a way you see fit.
* **Privacy.** Cosigner keeps your signing totally offline.
* **Resilience.** Cosigner also keeps your seeds offline, just communicating signatures through airgaps.
* **Openness.** Cosigner communicates through airgaps via URs and QRs, for maximum interoperability.

Blockchain Commons apps do not phone home and do not run ads. Some are available through various app stores; all are available in our code repositories for your usage.

## Status - Active Development

**GordianCosigner-macOS** is currently under active development. It should not be used for production tasks until it has had further testing and auditing.

We expect this to be a temporary repo. We also a [Catalyst repo](https://github.com/BlockchainCommons/GordianSigner-Catalyst), which we'd prefer to use for macOS, to totally standardize our code base, but currently we're unable to do so because of security locks on the desktop camera.

## Origin, Authors, Copyright & Licenses

Unless otherwise noted (either in this [/README.md](./README.md) or in the file's header comments) the contents of this repository are Copyright © 2020 by Blockchain Commons, LLC, and are [licensed](./LICENSE) under the [spdx:BSD-2-Clause Plus Patent License](https://spdx.org/licenses/BSD-2-Clause-Patent.html).

In most cases, the authors, copyright, and license for each file reside in header comments in the source code. When it does not, we have attempted to attribute it accurately in the table below.

This table below also establishes provenance (repository of origin, permalink, and commit id) for files included from repositories that are outside of this repo. Contributors to these files are listed in the commit history for each repository, first with changes found in the commit history of this repo, then in changes in the commit history of their repo of their origin.

| File      | From                                                         | Commit                                                       | Authors & Copyright (c)                                | License                                                     |
| --------- | ------------------------------------------------------------ | ------------------------------------------------------------ | ------------------------------------------------------ | ----------------------------------------------------------- |
| exception-to-the-rule.c or exception-folder | [https://github.com/community/repo-name/PERMALINK](https://github.com/community/repo-name/PERMALINK) | [https://github.com/community/repo-name/commit/COMMITHASH]() | 2020 Exception Author  | [MIT](https://spdx.org/licenses/MIT)                        |

### Dependencies

To build **GordianCosigner-macOS** you'll need to use the following tools:

- Xcode - ([Xcode](https://apps.apple.com/id/app/xcode/id497799835?mt=12)).
- macOS 10.15

### Derived from…

This **GordianCosigner-macOS** project is either derived from or was inspired by:

- [BlockchainCommons/GordianWallet-iOS](https://github.com/BlockchainCommons/GordianWallet-iOS) — Bitcoin wallet powered by your own node over Tor, from [BlockchainCommons](https://github.com/BlockchainCommons).

### Used with…

These are other projects that work with or leverage **GordianCosigner-macOS**:

- [BlockchainCommons/bc-libwally-core](https://github.com/BlockchainCommons/bc-libwally-core) — Used for signing PSBT's offline, from [ElementsProject](https://github.com/ElementsProject).

- [BlockchainCommons/bc-libwally-swift](https://github.com/BlockchainCommons/bc-libwally-swift) — A swift wrapper built around Libwally-core, from [blockchain](https://github.com/blockchain).

## Financial Support

**GordianCosigner-macOS** is a project of [Blockchain Commons](https://www.blockchaincommons.com/). We are proudly a "not-for-profit" social benefit corporation committed to open source & open development. Our work is funded entirely by donations and collaborative partnerships with people like you. Every contribution will be spent on building open tools, technologies, and techniques that sustain and advance blockchain and internet security infrastructure and promote an open web.

To financially support further development of **GordianCosigner-macOS** and other projects, please consider becoming a Patron of Blockchain Commons through ongoing monthly patronage as a [GitHub Sponsor](https://github.com/sponsors/BlockchainCommons). You can also support Blockchain Commons with bitcoins at our [BTCPay Server](https://btcpay.blockchaincommons.com/).

## Contributing

We encourage public contributions through issues and pull requests! Please review [CONTRIBUTING.md](./CONTRIBUTING.md) for details on our development process. All contributions to this repository require a GPG signed [Contributor License Agreement](./CLA.md).

### Discussions

The best place to talk about Blockchain Commons and its projects is in our GitHub Discussions areas.

[**Gordian User Community**](https://github.com/BlockchainCommons/Gordian/discussions). For users of the Gordian reference apps, including [Gordian Coordinator](https://github.com/BlockchainCommons/iOS-GordianCoordinator), [Gordian Seed Tool](https://github.com/BlockchainCommons/GordianSeedTool-iOS), [Gordian Server](https://github.com/BlockchainCommons/GordianServer-macOS), [Gordian Wallet](https://github.com/BlockchainCommons/GordianWallet-iOS), and [SpotBit](https://github.com/BlockchainCommons/spotbit) as well as our whole series of [CLI apps](https://github.com/BlockchainCommons/Gordian/blob/master/Docs/Overview-Apps.md#cli-apps). This is a place to talk about bug reports and feature requests as well as to explore how our reference apps embody the [Gordian Principles](https://github.com/BlockchainCommons/Gordian#gordian-principles).

[**Blockchain Commons Discussions**](https://github.com/BlockchainCommons/Community/discussions). For developers, interns, and patrons of Blockchain Commons, please use the discussions area of the [Community repo](https://github.com/BlockchainCommons/Community) to talk about general Blockchain Commons issues, the intern program, or topics other than those covered by the [Gordian Developer Community](https://github.com/BlockchainCommons/Gordian-Developer-Community/discussions) or the 
[Gordian User Community](https://github.com/BlockchainCommons/Gordian/discussions).

### Other Questions & Problems

As an open-source, open-development community, Blockchain Commons does not have the resources to provide direct support of our projects. Please consider the discussions area as a locale where you might get answers to questions. Alternatively, please use this repository's [issues](./issues) feature. Unfortunately, we can not make any promises on response time.

If your company requires support to use our projects, please feel free to contact us directly about options. We may be able to offer you a contract for support from one of our contributors, or we might be able to point you to another entity who can offer the contractual support that you need.

### Credits

The following people directly contributed to this repository. You can add your name here by getting involved. The first step is learning how to contribute from our [CONTRIBUTING.md](./CONTRIBUTING.md) documentation.

| Name              | Role                | Github                                            | Email                                                       | GPG Fingerprint                                    |
| ----------------- | ------------------- | ------------------------------------------------- | ----------------------------------------------------------- | -------------------------------------------------- |
| Christopher Allen | Principal Architect | [@ChristopherA](https://github.com/ChristopherA) | \<ChristopherA@LifeWithAlacrity.com\>                       | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |
| Peter Denton      | Project Lead        | [@Fonta1n3](https://github.com/Fonta1n3)          | <[FontaineDenton@gmail.com](mailto:FontaineDenton@gmail.com)> | 1C72 2776 3647 A221 6E02  E539 025E 9AD2 D3AC 0FCA  |

## Responsible Disclosure

We want to keep all of our software safe for everyone. If you have discovered a security vulnerability, we appreciate your help in disclosing it to us in a responsible manner. We are unfortunately not able to offer bug bounties at this time.

We do ask that you offer us good faith and use best efforts not to leak information or harm any user, their data, or our developer community. Please give us a reasonable amount of time to fix the issue before you publish it. Do not defraud our users or us in the process of discovery. We promise not to bring legal action against researchers who point out a problem provided they do their best to follow the these guidelines.

### Reporting a Vulnerability

Please report suspected security vulnerabilities in private via email to ChristopherA@BlockchainCommons.com (do not use this email for support). Please do NOT create publicly viewable issues for suspected security vulnerabilities.

The following keys may be used to communicate sensitive information to developers:

| Name              | Fingerprint                                        |
| ----------------- | -------------------------------------------------- |
| Christopher Allen | FDFE 14A5 4ECB 30FC 5D22  74EF F8D3 6C91 3574 05ED |

You can import a key by running the following command with that individual’s fingerprint: `gpg --recv-keys "<fingerprint>"` Ensure that you put quotes around fingerprints that contain spaces.
