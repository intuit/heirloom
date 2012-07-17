Heirloom
========

I help building and deploying .tar.gz files to cloud based storage services and tracking meta data about those 'Heirlooms' for easy deployments.  

How To Use Heirloom
-------------------

To get started copy the sample below into .heirloom.yml and update the specified fields.

```
aws:
  access_key: UPDATE_ME
  secret_key: UPDATE_ME
  regions:
    - us-west-1
    - us-west-2
    - us-east-1
  authorized_aws_accounts:
    - UPDATE@ME
    - UPDATE@ME
```

* **access_key / secret_key**: Account where you would like the Heirlooms storaged.
* **regions**: AWS regions where the Heirlooms should be uploaded
* **authorized_aws_accounts**: Heirloom expects you to deploy to seperate accounts from where the Heirloom is stored.  authorized_aws_accounts specifices the **email** address of other accounts to be authorized to access private Heirlooms.

Platforms
---------

Currently I support s3 and simpledb but would one day like to expand (Big Table, etc).
