Heirloom
========

The goal of Heirloom is to securely and easily transport data to cloud hosted applciations.

Heirloom creates archives from directories. Their archives are versioned and hosted in geographic distributed locations. Heirloom tracks metadata about those archives, both about the archive locations, as well as arbitrary tags which can be set by an engineer or process. It supports encryption and authorization to allow for securely transporting sensitive data over cloud storage services.

Installation
------------

First things first, install heirloom:

```
gem install heirloom
```

To get started copy the sample below into ~/.heirloom.yml and update the specified fields.

```
aws:
  access_key: UPDATE_ME
  secret_key: UPDATE_ME
```

* **access_key / secret_key**: AWS account credentials where you would like the archives stored.

Proxy Support
-------------

Heirloom uses the http_proxy & https_proxy variables.

```
export http_proxy=http://1.2.3.4:80
export http_proxys=http://1.2.3.4:80
```

Platforms
---------

Currently I support AWS S3 for object storage and AWS SimpleDB for metadata management.  One day I'd like to expand to other providers.


Documentation
-------------

For more information, please view the [Heirloom Wiki](https://github.com/live-community/heirloom/wiki).
