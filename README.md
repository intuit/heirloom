Heirloom
========

I help building and deploying artifcts to cloud based storage services and tracking meta data about those artifacts for easy deployments.  

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

* **access_key / secret_key**: Account where you would like the artifacts storaged.
* **regions**: AWS regions where the artifcat should be uploaded
* **authorized_aws_accounts**: Heirloom expects you to deploy to seperate accounts from where the artifact is stored.  authorized_aws_accounts specifices the **email** address of other accounts to be authorized to access private artifacts.

Platforms
---------

Currently I support s3 and simpledb but would one day like to expand (Big Table, etc).
