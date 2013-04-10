[![Build Status](https://secure.travis-ci.org/intuit/heirloom.png)](http://travis-ci.org/intuit/heirloom)

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
# default environment
aws:
  access_key: UPDATE_ME
  secret_key: UPDATE_ME
  metadata_region: us-west-1
  
# multiple environments can be defined and 
# selected via cli with -e or --environment

# prod:
#   access_key: UPDATE_ME
#   secret_key: UPDATE_ME
#   metadata_region: us-west-1
```

Documentation
-------------

For more information, please view the [Heirloom Wiki](https://github.com/intuit/heirloom/wiki).
