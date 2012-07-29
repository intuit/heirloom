Heirloom
========

Heirloom is packages and distributes files to cloud storage services.  Heirloom tracks metadata about those deployments, both about the file locations, as well as arbitrary metadata which can be set by an engineer or build process.

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

Platforms
---------

Currently I support AWS S3 for object storage and AWS SimpleDB for metadata management.  One day I'd like to expand to other providers.

Documentation
-------------

For more information, please view the [Heirloom Wiki](https://github.com/live-community/heirloom/wiki).
