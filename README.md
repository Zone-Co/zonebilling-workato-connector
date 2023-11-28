# ZoneBilling Connector for Workato

The ZoneBilling Connector for Workato is a Ruby-based connector that allows Workato users to connect to the [ZoneBilling API](https://zab-docs.zoneandco.com/) to perform various actions in their NetSuite account provisioned with ZoneBilling. 

Instructions for settings up the connector within the Workato Platform can be found [in the documentation file](DOCUMENTATION.md).

## About

### Name
ZoneBilling for NetSuite

### Categories
1. Finance And Accounting
2. Sales And Marketing

### Search Keywords
1. NetSuite
2. ZoneBilling
3. Billing

### Details
The ZoneBilling for NetSuite Workato Connector allows you to interact with NetSuite with the full power of the [ZoneBilling API](https://zab-docs.zoneandco.com/). Requires version 2023.07.20.1 or later of the [ZoneBilling NetSuite SuiteApp](https://www.suiteapp.com/ZoneBilling). For more information, [please visit our help documentation](https://help.zoneandco.com/hc/en-us/sections/17022714320155-Workato).

### What can you do with this connector
1. Create, Update, and Upsert records into NetSuite, including Standard, ZoneBilling, or any other custom record type within your environment.
2. Leverage our Bulk API to insert large volumes of records into your NetSuite account
3. Fetch records from preconfigured out-of-the-box & custom saved searches within your NetSuite account
4. Retrieve Documents from your NetSuite environment, such as Invoice PDFs.
5. Execute ZoneBilling Automated Processes such as Transaction Creation & Subscription Rating
6. Leverage advanced API features such as [External Keys](https://zab-docs.zoneandco.com/#bda27caf-e45e-4bc6-bc10-93b11628b755) and [External References](https://zab-docs.zoneandco.com/#eb92f1bb-0c78-48cc-be49-16ab8f4bfdac),

### Support
This connector was built and is supported by Zone & Company Software Consulting LLC. Send bug reports and enhancement requests to [Zone & Co. Support](https://www.zoneandco.com/support-hub).

### Contact Details

#### Support Contact
- Email [support@zoneandco.com](mailto:support@zoneandco.com)

#### Partnerships Contact
- Full Name: Keith Goldschmidt
- Email: [keithgoldschmidt@zoneandco.com](mailto:keithgoldschmidt@zoneandco.com)

#### Developer Contact
- Full Name: Tyler Santos
- Email: [tylersantos@zoneandco.com](mailto:tylersantos@zoneandco.com)

#### Product Contact
- Full Name: Amy Nelson
- Email: [amynelson@zoneandco.com](mailto:amynelson@zoneandco.com)

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

## Writing Unit Tests

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

### Repository Information ###
* [GitHub Repository](https://github.com/Zone-Co/zonebilling-workato-connector) - **Primary** Development Repository
* [Bitbucket Repository](https://bitbucket.org/zone-co/zone-billing-workato-connector/src/master/) - _Copy_
  * Synced with GitHub Repository by executing local code
  * You must have local write access to the Bitbucket repository
    ```bash
    # Set a new remote named `bitbucket`
    git remote add bitbucket git@bitbucket.org:zone-co/zone-billing-workato-connector.git
    ```
    ```bash
    # Verify new remote
    git remote -v
    ```
    ```bash
    # Push the code to the new remote
    git push bitbucket
    ```

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

## Deployments
The Workato connector can be deployed to the Workato platform using the [Workato CLI](https://docs.workato.com/developing-connectors/sdk/cli.html#sdk-cli). 
Once it is installed the following command will execute the upload. Note: You will need to have access to the configured Workato API key to execute this command.
```bash
workato push --title="ZoneBilling for NetSuite" --description=./Connector_details.md --logo=./logo.png --connector=./connector.rb --api-token= ##Insert API Token Here##
```
