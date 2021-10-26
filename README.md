## Introduction

Welcome to this sample application to help get you started using CI/CD for building your Splunk Apps.

If you havent already, check out the accomanying Splunk .conf2021 talk at https://conf.splunk.com/files/2021/recordings/DEV1560B.mp4 (PDF at https://conf.splunk.com/files/2021/slides/DEV1560B.pdf)

For more great Splunk Developer breakouts check out https://www.splunk.com/en_us/blog/conf-splunklive/great-breakouts-for-splunk-developers-at-conf21.html

This app has a very very simple modular input. See https://dev.splunk.com/enterprise/docs/devtools/python/sdk-python/howtousesplunkpython/howtocreatemodpy/#The-stream_events-method for more information on creating modular input apps.

## Pre-Requisites:

* Python3
* Poetry (https://python-poetry.org/docs/#installation)
* Docker (https://docs.docker.com/get-docker/)

## Getting Started:

### To run locally:

* Check out this repository to your local file system
* Ensure you have the Pre-Requisites installed (as above)
* Modify/Create your application in the `package` folder.
* Run `make install` to install any additional libraries required using Poetry
* Run `make build up test release` to package/test and create a release for your application.  
* After running `up` you should see the local connection details for connecting to local Splunk instance. e.g.
```
Splunk Web is running at http://localhost:51160
Splunk REST is running at https://localhost:51162
Splunk HEC is running at https://localhost:51161
````
You can login with username/password: `admin/Chang3d!`
### Extending/Configuring PyTest:

* Modify PyTest runtime arguments in `pyproject.toml`
* Add/Modify tests in tests/test_*.py

### Creating a new app based on this repo

* Clone the repository
* Remove the existing Git Origin (`git remote rm origin`)
* Modify the App ID/Description/Author in pyproject.toml
* Remove globalConfig.json if building a simple app, or update if building a UCC app.
* update package/* files (including package/default/app.conf)
* Build/Test/Release/Repeat

## Commands:

Note - The Makefile may contain more than the commands listed below, however some are used internally by other commands and not intended to be used directly.

| make help                | List of all available commands                               |
| ------------------------ | ------------------------------------------------------------ |
| make clean-tests         | Remove any previous test files/logs                          |
| make clean-build         | Remove any previous app build/packaging/dist output          |
| make clean               | Remove local build (clean-build), test (clean-tests), docker (clean-docker) + result data |
| make clean-venv          | Remove the Python virtualenv                                 |
| make clean-docker        | Remove unused docker volumes (use with care)                 |
| make clean-all           | Deep clean! (venv/docker/build/test/output)                  |
| make reinstall           | Perform a Deep clean (clean-all) followed by an install      |
| make git-init-submodules | Initialise the submodules configured in .gitmodules          |
| make splunk-btool        | Generate a btool output from the current running splunk docker container |
| make splunk-restart      | Restart the splunk process in the current running splunk docker container |
| make install             | Run repo installation (Poetry install)                       |
| make update              | Update poetry as per local config                            |
| make docker-build        | Build Splunk docker container ready for side-loading of application and testing |
| make down                | Shutdown and remove docker containers assosicated with this app/repo |
| make up                  | Start docker containers associated with this app/folder as defined in docker-compose.yml |
| make up-ci               | Start docker containers (CI Only)                            |
| make test                | Run PyTest against the Splunk application                    |
| make build               | Determine if UCC/Basic application and create app output     |
| make release             | Create application release                                   |
| make splunk-ports-output | Print dynamic docker Splunk ports (Web/REST/HEC) to stdout   |
| make splunk-cloud-upload | Upload application to SplunkCloud - Requires stack=<stackName> |


## File Descriptions:

| FileName / Folder              | Description                                                  |
| ------------------------------ | ------------------------------------------------------------ |
|                                |                                                              |
| .venv                          | Python Virtualenv - the virtualenv contains all the required libraries to perform the build, test and packaging tasks. |
| _submodules                    | Check out any git submodules here (such as other app directories that you may wish to include in your test build) For more information see https://git-scm.com/book/en/v2/Git-Tools-Submodules |
| deps                           | Deprecated - Use _submodules to bring in dependencies.       |
| dist                           | This temporary directory is created once you have create a packaged version of your app that will be used to store the tarball of your app. Contents are not committed to git unless explicitly added. |
| docker                         | Contains a number of docker images used in order to build/test/package your application. See the README file inside the folder for more info. |
| output                         | Contains the sanitized app which is then used for tests      |
| package                        | See sub-readme<br />pytest-splunk-addon-data.conf (https://pytest-splunk-addon.readthedocs.io/en/latest/sample_generator.html)<br/><br/>eventgen.conf (http://splunk.github.io/eventgen/REFERENCE.html) |
| scripts                        | Helper scripts that are used by the Makefile (See Commands section) to build/package/test/deploy your application. |
| tests                          | This folder contains your PyTest files that are executed against your application |
| .gitignore                     | File containing a list of file/folder patterns to ignore from Git (such as temporary files and packaged apps) |
| .gitlab-ci.yml                 | GitLab CI configuration file. For more information see https://docs.gitlab.com/ee/ci/yaml/ |
| .gitmodules                    | File containing any Git sub-module configuration (e.g. additional apps you want to sideload during your app testing, this could be index configuration or other props/transforms for example) |
| .ignore_splunk_internal_errors | A line-delmited list of _internal errors to ignore. These lines are prefixed by `NOT` when looking for any errors in the _internal index by PyTest, therefore it does not need to be a full match to the entire event, however consider if any entries could exclude useful/legitimate app errors.  These might be errors that you are expecting to see based on your environment (e.g. low disk space). For more information see https://github.com/splunk/pytest-splunk-addon/blob/main/pytest_splunk_addon/.ignore_splunk_internal_errors for a sample. |
| .pytest.expect                 | An x-file file / list of tests that are known to fail. For more information see https://docs.pytest.org/en/6.2.x/skipping.html and https://github.com/gsnedders/pytest-expect |
| .slimignore                    | This is for ignoring files within your app if built using the ucc-gen command. This works in a similar way to .gitignore/.dockerignore. See https://dev.splunk.com/enterprise/reference/packagingtoolkit/packagingtoolkitcli/ for more information. |
| .uccignore                     | Similar to .slimignore, this is for ignoring files within your app if built using the ucc-gen command. This works in a similar way to .gitignore/.dockerignore/.slimignore - This functionality may soon be dropped (see https://github.com/splunk/addonfactory-ucc-generator/issues/362) so `additional_packaging.py` has been updated to include to code to implement this. |
| additional_packaging.py        | This Python script is run by the ucc-gen app after the app output has been created. Note: This only applies to apps created with `ucc-gen` and does not apply to non-ucc apps. By default this script removes files listed in .uccignore |
| docker-compose.local.yml       | This can be used to extend the docker-compose.yml configuration (see below) with custom configuration for this specific app. For example, volume in additional apps, expose specific ports or pass additional commands/environment variables. For more information see https://splunk.github.io/docker-splunk/ADVANCED.html |
| docker-compose.yml             | This is the core docker configuration file that is use by local and CI/CD processes to build/test/package the app. The intention is to keep this "vanilla" so that it can be copied to any app, with any app-specific config going in to the docker-compose.local.yml file. This helps maintain consistency between multiple apps. |
| globalConfig.json              | Advanced config - UCC apps only. For more information see https://pypi.org/project/splunk-add-on-ucc-framework/ |
| Makefile                       | This file contains the `commands` (see above) that can be run in this repo. |
| poetry.lock                    | Used by Poetry to record the exact versions of the dependant Python libraries that are configured. Storing in Git ensures consistency between various users/machines. |
| poetry.toml                    | Poetry configuration file - Typically used to store the details of your package, version and description. In this instance it is simply used to enforce a Python virtualenv. |
| pyproject.toml                 | Contains the list of Python libraries, plus any additional parameters/configurations. This is a replacement for requirements.txt and files such as pytest.ini - For more information see https://python-poetry.org/docs/pyproject/ |
| README.md                      | For more information - Please see README.md                  |

## Additional temporary files:

| FileName / Folder        | Description                                                  |
| ------------------------ | ------------------------------------------------------------ |
| .tokenized_events/*.json | JSON representation of the events, including metadata, generated by PyTest. |
| output/app               | Final output of the app in expanded format (Not compressed into a tar.gz file) |
| tmp/reports              | Any AppInspect/PyTest XML/HTML reports collected during the packaging and testing of the application. Upload these to  as artifacts as evidence/audit of your test activity. |
| tmp/events.pickle        | Tokenized events file for use by PyTest                      |
| uf_files                 | Temporary directory used by PyTest Splunk Add-On to write tokenized events if the uf_file_monitor input is used. |
| *_events.lock            | Temporary file lock used by PyTest                           |
| generator.lock           | Temporary file lock used by PyTest                           |
| helmut.log               | 1st of 2 log files describing the activities carried out by PyTest |
| pytest_splunk_addon.log  | 2nd of 2 log files describing the activities carried out by PyTest |

## Suggested CI/CD Steps:

#### GitLab

`.gitlab-ci.yml` is already pre-configured with some suggested CI/CD steps, however note that these may require additional configuration of GitLab runners which is not covered here. (See https://docs.gitlab.com/runner/install/)
Due to the sharing of state/cache between stages you may need to run all stages on the same GitLab runner.

#### GitHub

There are currently no example GitHub pipelines, however this would largely follow the same pattern as the GitLab pipeline defined in `.gitlab-ci.yml`

## Further Reading

AppInspect tags: https://dev.splunk.com/enterprise/reference/appinspect/appinspecttagreference/


Splunk Eventgen : Installation & discussion on sample replay eventgen technique: https://www.youtube.com/watch?v=WNk6u04TrtU


How to use PyTest Splunk Add-On: (https://pytest-splunk-addon.readthedocs.io/en/latest/how_to_use.html)

Example PyTest test: https://github.com/splunk/seckit_sa_geolocation/tree/main/tests/knowledge

Functions in SearchUtil that can be used by PyTest tests
https://github.com/splunk/pytest-splunk-addon/blob/5fc0e9759c4153ad7d3ee2aa42a8e4ba140a0a74/pytest_splunk_addon/helmut_lib/SearchUtil.py#L37

pytest-splunk-addon-data.conf (PyTest data generator) sample file:
https://github.com/splunk/pytest-splunk-addon/blob/44e974419511f0a43f118938485789c0895cb434/tests/addons/TA_fiction_indextime_broken/default/pytest-splunk-addon-data.conf

## HELP!? What am I doing!?

This repo is not going to be perfect, there may be bugs, there may be improvement opportunities... Please raise an [issue in GitHub](https://github.com/livehybrid/sample_splunk_app/issues) if you're having any problems!

## Known Errors
* versioningit: NotSdistError: . does not contain a PKG-INFO file
  make: *** [build] Error 1
* Are you running the code in a git repo? Make a git commit in order for the versioning tools to detect the current version.
