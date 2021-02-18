# Operational Verification and Validation

* Ensure you know if systems don't work like they should

* Integrate system readiness feedback into your puppet run

* Increase confidence in you deployment health

* Integrate system monitoring into your puppet reporting pipeline

_[This README is partially aspirational. Not everything described in here is or will be implemented. Please direct any feedback to the [IAC Team](https://puppetlabs.github.io/iac/team/2021/01/20/reaching-out.html)]_

## Table of Contents

1. [Description](#description)
1. [Setup - The basics of getting started with opv](#setup)
    * [Beginning with opv](#beginning-with-opv)
1. [Usage - Configuration options and additional functionality](#usage)
1. [Development - Guide for contributing to the module](#development)

## Description

This module provides resources to verify the operational status of the things you're managing.
This can be basic things like "is this port reachable" to in-depth checks like "does this service return a healthy status".

Further reading:

* Early musing on this functionality: [Hitchhiker’s guide to testing infrastructure as/and code — don’t panic!](https://puppet.com/blog/hitchhikers-guide-to-testing-infrastructure-as-and-code/)

* Some background on the meaning of V&V: [The difference between Verification and Validation](https://www.easterbrook.ca/steve/2010/11/the-difference-between-verification-and-validation/)

## Setup

### Beginning with opv

The resources in this module work stand-alone and straight out of the box.
If anything has special needs, it will be described in the resource's reference section.

## Usage

```puppet
# Check whether SSH on localhost is reachable
tcp_port_reachable { '127.0.0.1:22': }
```

```puppet
# Check whether HTTP requests to 'https://www.example.com' work within three tries and a timeout of 10 seconds
check_http {
  'https://www.example.com':
    tries => 3,
    timeout => 10,
}
```

## Development

PRs for new checks, new check params, and other improvements are always appreciated.

[1]: https://puppet.com/docs/pdk/latest/pdk_generating_modules.html
[2]: https://puppet.com/docs/puppet/latest/puppet_strings.html
[3]: https://puppet.com/docs/puppet/latest/puppet_strings_style.html
