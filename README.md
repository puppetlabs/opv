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
Check out the "Operational Verification" talk at the [Become a better Puppet developer](https://puppet.com/events/become-a-better-puppet-developer/) Puppet Camp;
[Slides](https://docs.google.com/presentation/d/1xV7PzfbNaCgM_I-ClR9a4DEA2CIKZP6FE8bUkP9fPUs/edit?usp=sharing).

Further reading:

* Early musing on this functionality: [Hitchhiker’s guide to testing infrastructure as/and code — don’t panic!](https://puppet.com/blog/hitchhikers-guide-to-testing-infrastructure-as-and-code/)

* Some background on the meaning of V&V: [The difference between Verification and Validation](https://www.easterbrook.ca/steve/2010/11/the-difference-between-verification-and-validation/)

## Setup

### Beginning with opv

The resources in this module work stand-alone and straight out of the box.
If anything has special needs, it will be described in the resource's [reference section](./REFERENCE.md).

## Usage

```puppet
# Check whether SSH on localhost is reachable
check_tcp_port { '127.0.0.1:22': }
```

```puppet
# Check whether HTTP requests to 'https://www.example.com' work within three tries and a timeout of 10 seconds
check_http {
  'https://www.example.com':
    retries => 3,
    timeout => 10,
}
```

```puppet
# Check the exit code of a command
check_command {
  "custom health check":
    command => ['/usr/local/bin/healthy', $app_root],
    acceptable_exit_codes => [17, 42],
    retries => 3,
    timeout => 10,
}
```

```puppet
# Check the status of a windows service
check_windows_service {
  "WinRM":
    timeout => 10,
}
```

```puppet
# Check the status of a systemd service
check_systemd {
  "docker.service":
    timeout => 10,
}
```

```puppet
# Check the status of a systemd service
check_systemd {
  "openvpn.service":
    expected_status => 'stopped',
}
```

```puppet
# Check the result of a bolt task (e.g. as part of a plan run)
opv::check_task('service', $targets, 'name' => 'docker') |result| {
  return result['status'] == 'running'
}
```

```puppet
# Check a local certificate file
check_certificate {
  "/opt/puppetlabs/puppet/ssl/cert.pem":
    allowed_remaining_validity_days => 10;
}
```

## Development

See the [current enhancements](https://github.com/puppetlabs/opv/issues?q=is%3Aissue+is%3Aopen+label%3Aenhancement) for immediate next plans.

PRs for new checks, new check params, and other improvements are always appreciated.

Post and discuss feedback in [Discussions](https://github.com/puppetlabs/opv/discussions).
