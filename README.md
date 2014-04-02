[![Build Status](https://secure.travis-ci.org/intuit/heirloom.png)](http://travis-ci.org/intuit/heirloom)
[![Code Climate](https://codeclimate.com/github/intuit/heirloom.png)](https://codeclimate.com/github/intuit/heirloom)
Heirloom
========

The goal of Heirloom is to securely and easily transport data to cloud hosted applciations.

Heirloom creates archives from directories. Their archives are versioned and hosted in geographic distributed locations. Heirloom tracks metadata about those archives, both about the archive locations, as well as arbitrary tags which can be set by an engineer or process. It supports encryption and authorization to allow for securely transporting sensitive data over cloud storage services.

Prerequisites
-------------

* Ruby version 1.9.2 or higher installed.
* AWS account access key and secret key.

Installation
------------

Install the gem

```
gem install heirloom --no-ri --no-rdoc
```

To get started, copy the sample below to ~/.heirloom.yml and update the specified fields.

```
default:
  access_key: UPDATE_ME
  secret_key: UPDATE_ME
  metadata_region: us-west-1
```

Multiple environments can be defined in heirloom.yml and selected via the cli 
with the -e or --environment option

```
prod:
  access_key: UPDATE_ME
  secret_key: UPDATE_ME
  metadata_region: us-west-1

preprod:
  access_key: UPDATE_ME
  secret_key: UPDATE_ME
  metadata_region: us-west-1
```

You can now use Heirloom. For a list of commands

    heirloom -h

For help on a specific command, append -h to the command:

    heirloom setup -h

For help an overview of heirloom, see the [Overview Wiki](https://github.com/intuit/heirloom/wiki/Overview).

For detailed setup instructions, see the [Getting Started Guide](https://github.com/intuit/heirloom/wiki/GettingStarted).

Documentation
-------------

For more information, please view the [Heirloom Wiki](https://github.com/intuit/heirloom/wiki).

Contributing
-------------

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
