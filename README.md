# ZoneBilling Connector for Workato

The ZoneBilling Connector for Workato is a Ruby-based connector that allows Workato users to connect to the [ZoneBilling API](https://zab-docs.zoneandco.com/) to perform various actions in their NetSuite account provisioned with ZoneBilling. 

Instructions for settings up the connector within the Workato Platform can be found [in the documentation file](DOCUMENTATION.md).

### Repository Information ###
* [GitHub Repository](https://github.com/Zone-Co/zonebilling-workato-connector) - **Primary** Development Repository
* [Bitbucket Repository](https://bitbucket.org/zone-co/zone-billing-workato-connector/src/master/) - _Copy_

### Overview ###
1. Pre-requisites
2. Connection Settings
3. Running connector code locally
4. Code Style & Formatting
5. Writing unit tests
6. Recording VSR Tapes

## Pre-requisites
1. Installing and understanding of the [Workato Connector SDK](https://docs.workato.com/developing-connectors/sdk.html) and [SDK CLI](https://docs.workato.com/developing-connectors/sdk/cli.html#sdk-cli)
2. You have received the `master.key` file from the lead developer on the project. **IMPORTANT** This key is used to decrypt all encrypted files such as those in `./tape_library` and `settings.yaml.enc`. Do not share this key with anyone outside your team

## Connection Settings
Connection settings consists of sensitive information like passwords or other secrets. For local development and testing, these connection settings are stored in the encrypted fil, e.g. `settings.yaml.enc`, which is natively decrypted by the `master.key` file when running the [Workato CLI](https://docs.workato.com/developing-connectors/sdk/cli.html#sdk-cli).

Run this command on terminal to create or update connection settings file:

```bash
EDITOR="nano" workato edit settings.yaml.enc
```

This is an example settings file (YAML format):

```yaml
account_id: 1234567-SB1
certificate_id: abcdefghijklmopqrstuvwxyz1234567890
client_id: abcdefghijklmopqrstuvwxyz1234567890
private_key: |
    -----BEGIN EC PRIVATE KEY-----
    exampleexampleexampleexampleexampleexampleexampleexampleexamplee
    xampleexampleexampleexampleexampleexampleexampleexampleexampleex
    ampleexampleexampleexampleexampleexa
    -----END EC PRIVATE KEY-----
```

This file's contents mock what properties are available with the `connection` attribute in the [connector.rb](connector.rb) code, influenced by the fields defined on the connection.

Please Note:
The `private_key` field is a multi-line string that is indented by 4 spaces. A leading `|` character is need to indicate that this is a multi-line string. This is important as the Workato CLI will not be able to decrypt the file if the `private_key` field is not indented properly.


## Running connector code locally
The [Workato CLI](https://docs.workato.com/developing-connectors/sdk/cli.html#sdk-cli) can be used to run connector actions locally. For example: we can run the `test` functionality of the connector:

```bash
workato exec test
```

Refer to [Connector SDK CLI Documentation](https://docs.workato.com/developing-connectors/sdk/cli/guides/getting-started.html) to learn about using the `workato` CLI.

## Code Style & Formatting

Use [RuboCop](https://rubocop.org/) to check your code style (linting) and to format your code based on the community-driven [Ruby Style Guide](https://rubystyle.guide/).

You can run `rubocop` manually with no arguments to check all Ruby source files in the current folder and subfolders:

```bash
$ bundle exec rubocop
```

Alternatively you can pass `rubocop` a specific file or folder to check:

```bash
$ bundle exec rubocop connector.rb
```

Refer to [RuboCop Documentation](https://docs.rubocop.org/rubocop/1.12/usage/basic_usage.html) to learn about using the `rubocop` CLI.

## Writing unit tests

[RSpec](https://rspec.info/) is used to for behaviour driven unit tests.

All unit test files (aka spec-files) files are in the `./spec` folder of your connector folder and filenames end with `_spec.rb`. Please reference the [Workato How-to Guide](https://docs.workato.com/developing-connectors/sdk/cli/guides/rspec/writing_tests.html).

The [Workato CLI](https://docs.workato.com/developing-connectors/sdk/cli/guides/rspec/writing_tests.html#generating-your-tests) can automatically generate shells of the unit test files by running:

```bash
workato generate test
```

You can run RSpec unit tests manually. Running `rspec .` from root of the repository will run all RSpec tests for all connectors:

```bash
$ bundle exec rspec spec/
```

Alternatively you can pass `rspec` a specific file or folder to check:

```bash
$ bundle exec rspec spec/connector_spec.rb
```

Refer to [RSpec Documentation](https://rspec.info/documentation/3.10/rspec-core/#basic-structure) to learn about creating unit tests and using the `rspec` CLI.

## Recording VSR Tapes

VSR Tapes are used to record the responses from the ZoneBilling API. These tapes are used to mock the API responses when running unit tests. This allows for the unit tests to be run without the need for a live connection to the ZoneBilling API, drastically decreasing the time it takes to run the tests.

To record a tape, you can execute the following with an indicated file path of the rspec test.
```bash
bundle exec rspec spec/
```

To receive the contents of your VCR tapes for review you can load them with the command `workato edit` with a `EDITOR` indicated and the file path of the tape. 
```bash
EDITOR="nano" workato edit tape_library/
```

## Git Management

### Branches
1. `main` - **Primary** branch for production code
2. `release/*` - Branches for release candidates
3. `feature/*` - Branches for feature development enhancements
4. `bugfix/*` - Branches for bug fixes

### Pull Requests
1. Active Feature Pull requests should be made from `feature/*` and `bugfix/*` branches to `release/*` branches for Zone internal development review
2. Finalize release pull requests should be made from `release/*` branches to `main` branch and reviewed by the Workato Connector Engineering team:
   1. Bennet Goh [GitHub](https://github.com/bennettgo) / [Email](mailto:bennett.goh@workato.com)
   2. Denis Sergeyev [GitHub](https://github.com/den-sergeyev-workao) / [Email](mailto:denis.sergeyev@workato.com)
   3. Pavel Abolmasov [GitHub](https://github.com/pavel-workato) / [Email](mailto:pavel.abolmasov@workato.com)
   4. Sergey Zaretskiy [GitHub](https://github.com/szaretsky) / [Email](mailto:szaretsky@workato.com)
