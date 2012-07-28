Heirloom
========

I help building and deploying build archive to cloud based storage services and track meta data about those 'Heirlooms' for deployments.

Installation
------------

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
