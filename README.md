Meerkat Tasks
================

A set of custom tasks for Visual Studio Team Services .

Welcome to contributions from anyone.

You can see the version history [here](RELEASE_NOTES.md).

## Library License

The library is available under the [MIT License](http://en.wikipedia.org/wiki/MIT_License), for more information see the [License file][1] in the GitHub repository.

 [1]: https://github.com/phatcher/Meerkat.Tasks/blob/master/License.md

## Getting Started

Currently we have two custom tasks...

1. WebDeploy - Uses MsDeploy's webdeploy.axd interface to deploy a package to IIS, does not need admin rights on the target box but the target must have been configured appropriately.
2. AzureWebAppDeploy - The OOB task for Azure deployment does not support virtual applications whereas this version does