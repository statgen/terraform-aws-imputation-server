# terraform-aws-imputation-server

[![Maintained by Jacob Pleiness](https://img.shields.io/badge/maintained%20by-%40jdpleiness-ff69b4)](https://github.com/jdpleiness)
[![Github Actions](https://github.com/jdpleiness/terraform-aws-imputation-server/workflows/Terraform/badge.svg)](https://github.com/jdpleiness/terraform-aws-imputation-server/actions?workflow=Terraform)
![Terraform Version](https://img.shields.io/badge/tf-%3E%3D1.0.0-blue.svg)

This repo contains a set of modules in the [modules folder](/modules) for deploying an [Imputation Server](https://github.com/genepi/imputationserver) on AWS using [Terraform](https://www.terraform.io/).

Imputation Server is web-based service for imputation that facilitates access to new reference panels and greatly improves user experience and productivity. 

This Module includes:
* [imputation-server](/modules/imputation-server): This module can be used to set up an imputation server.
* [imputation-lb](/modules/imputation-lb): This module can be used to set up an AWS Application Load Balancer front-end for the imputation server.
* [imputation-iam](/modules/imputation-iam): This module can be used to set up the proper AWS IAM permissions needed for the imputation server.
* [imputation-security-group-rules](/modules/imputation-security-group-rules): This module can be used to set up the proper security groups needed.

## How do you use this Module?

This repo has the following structure:
* [modules](/modules): This folder contains several standalone and reusable modules that you can use to deploy an imputation server.
* [test](/test): Automated tests for the modules. These are currently a work-in-progress.
* [root folder](): The root folder is *an example* of how to use the [imputation-server](/modules/imputation-server) module to deploy an imputation server in AWS.
  The Terraform Registry requires the root of every repo to contain Terraform codes, so we've put an example there. This is great for learning
  and experimenting, but for production use, please use the underlying modules in the [modules folder](/modules) directly and with your own environment 
  and needs in mind.

## What's a Module?

A Module is a canonical, reusable, best-practices definition for how to run a single piece of infrastructure, such as a database or server cluster. Each Module is created primarily using [Terraform](https://www.terraform.io/), includes automated tests, examples, and documentation, and is maintained both by the open source community and companies that provide commercial support.

Instead of having to figure out the details of how to run a piece of infrastructure from scratch, you can reuse existing code that has been proven in production. Instead of maintaining all that infrastructure code yourself, you can leverage the work of the Module community and maintainers, and pick up infrastructure improvements through a version number bump.

## How is this Module versioned?

This Module follows the principles of [Semantic Versioning](http://semver.org/). You can find each new release, along with the changelog, in the [Releases Page](https://github.com/jdpleiness/terraform-aws-imputation-server/releases).

## Authors

This project is maintained by [Jacob Pleiness](https://github.com/jdpleiness).

[![@jacobpleiness](https://img.shields.io/twitter/follow/jacobpleiness?label=Follow%20%40jacobpleiness%20on%20Twitter&style=social)](https://twitter.com/jacobpleiness)

## License
This code is released under the Apache 2.0 License. Please see [LICENSE]() for more details.