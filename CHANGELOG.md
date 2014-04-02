## HEAD:

* Bug fix in setup to properly read metadata region from config
* Update to CLI environment message
* Added SimpleDB debug query logging
* Bug fix in catalog to return proper errors when catalog not found
* Removed unused JSON output from CLI

## 0.12.3 (03/26/2014):

* Added dependent gems for fog

## 0.12.2 (03/26/2014):

* Upgrade to fog 1.21.0
* Remove VCR
* Update specs to use double

## 0.12.1 (09/04/2013):

* Upgraded to fog 1.15.0

## 0.12.0 (08/14/2013):

* Fixed bug 130 which did not exclude subdirectories
* Fixes bug 145 when no config file, it no longer errors out
* Added HEIRLOOM_CONFIG_FILE as alternate config file

## 0.11.2 (06/19/2013):

* Adding hashie to runtime.

## 0.11.1 (06/18/2013):

* Fixes bug #139 by using get_object_acl instead of removed get_bucket_acl.
* Move to .ruby-version and .ruby-gemset instead of .rvmrc

## 0.11.0 (04/26/2013):

* Add support for multiple environments
* Environment named 'default' is now the default
* Added functionality to the show command to include permissions of objects
* Updating to fog 1.10.0
* Add support for authorizing accounts using the canonical ID
* Updated catalog output to include s3 urls
* Catalog output renamed Bucket Prefix to bucket_prefix
* Catalog output renamed Region to region
* Add `rotate` command to allow for encryption key rotation
* Add support for IAM instance roles

## 0.10.1 (02/28/2013):

* Minor refactoring of lib/heirloom/cipher/shared.rb
* Additional validation of download location

## 0.10.0:

* Confirm tar and gpg executables are present when necessary
* Switch to gpg for encryption
* S3 key names will have gpg appended when encrypted
* Switch rvm to 1.9.3-p327

## 0.9.0:

* Updated tempfile logic to fix GC issues.
* Removed git support.
* Only setup existing buckets if forced.
* Ensure valid bucket name and heirloom name on setup.
* Return friendly error when bucket or heirloom does not exist.
* Updating to fog 1.6.0
* Removing grit gem

## 0.8.3:

* Teardown does not try to delete buckets if they are not empty.

## 0.8.2:

* Updated docs based on feedback from mint.
* Added check for other account owning a given bucket.
* Fixed config to read CLI variables and override file config.
* When delete bucket raise not found, return true (eventually consistent)

## v0.8.1:

* Moving verification on entry exists into catalog class

## v0.8.0:

* Change base to bucket prefix through out code base
* Prevent setup from overwriting existing heirlooms
* Add human readable format as default for show
* Included JSON option to show
* Hide heirloom internal attribts in show
* Added all option to display all attributes via show
* Add human readable format as default for list
* Included JSON option in list
* Add human readable format as default for catalog
* Included JSON option in catalog
* Add name filter option to catalog

## v0.7.5:

* Create random base if not specified by setup.

## v0.7.4:

* Add support to read password from file

## v0.7.3:

* Fix bug in latest_id method

## v0.7.2:

* Enclose files/dirs to tar in 's.
* Download the latest id if id not specified in download.

## v0.7.1:

* Truncate long commit messages.

## v0.7.0:

* Adding catalog which will contain all heirloom regions & bases.
* CLI will lookup base & region from catalog.
* Removing base requirement for all subcmds outside download & setup.
* Added teardown command to delete domains & buckets.
* Enclosing simpledb domains in `s
* Added catalog subcommand to list available Heirlooms from catalog.
* Reducing log levels

### v0.6.1:

* Allowing engineer to specify region for metadata
* Ensuring metadata is in an upload region
* Split setup into seperate subcommand
* Perform additional validation on CLI options

## v0.5.0:

* Verify domain exists for all cmds except build & download
* Removing requirement to check simpledb on download.
* Adding requirement for base on download.
* Fix error when .heirloom.yml does not exist.
* Refactor cli option validation
* Refactor cli specs
* Add -x to download to extract heirloom to given output path
* Verify -o specified in download is a directory
* Requiring -d for builds (will no longer default to .)
* Remove new lines from values of git comments
* Verify directory given at build is a directory
* Support archiving directories outside the cwd.
* Fixed bug in git repo verification on build.
* Added support for encryption.
* Removed short name and changed long name for AWS CLI creds.
* Adding encrypted attribute by default for all builds.
* Change base_prefix CLI option to base
* Changed subcommands build -> upload, update -> tag
* Changed tag option updated_value -> value
* On upload, Heirloom will attempt to create buckets which do not exist.
* Will not destroy the sdb domain when cleanin up old versions on upload.
* Hard coding gem versions
* Validating email addresses in authorize

## v0.4.0:

* Prefixing domain name with heirloom_
* Adding CLI support for specific AWS creds
* Added specs
* Added support to delete domain when no records exist

## v0.3.1:

* Switched from Minitar to shell
* Removed Minitar gem
* Fixed git commit flag
* Updated specs
* Updated gems

## v0.3.0:

* Move account authorization out of config to cli
* Move region select out of config to cli
* Updated obtions for update to use -u (not -v) for update
* Cleaned up archive specs
* Added authorize cli class
* Changed output of show / list to JSON
* Updated readme & cli help

## v0.2.0:

* Command line options updates for each sub command.
* Command line option moved into seperate class.
* Artifact renamed to archive across the gem.
* Added bucket verification

## v0.1.4:

* Limit list of artifact ids returned in list
* Sort ids by date added
* Show latest id as default
* Setting deafult download path to local dir
