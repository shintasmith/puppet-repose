# == Resource: repose::filter::client_auth_n
#
# This is a resource for generating client-auth-n configuration files
#
# === Parameters
#
# [*ensure*]
# Bool. Ensure config file is present/absent
# Defaults to <tt>present</tt>
#
# [*filename*]
# String. Filename to output config
# Defaults to <tt>client-auth-n.cfg.xml</tt>
#
# [*auth*]
# Required. Hash containing user, pass, and uri
#
# [*client_maps*]
# Array contianing client mapping regexes for tenanted mode.
#
# [*white_lists*]
# Array contianing uri regexes to white list
#
# [*ignore_tenant_roles*]
# Array containing roles to exclude from restrictions
#
# [*delegable*]
# DEPRECATED: Replaced with delegating in repose 7, defining
# <tt>delegating</tt> will remove this from the configration.
# Bool. Delegate the decision to authenticate a request down the chain to
# either another filter or to the origin service.
# Defaults to <tt>false</tt>
#
# [*delegating*]
# Bool. This replaces delagable in repose 7+.
# Defaults to <tt>undef</tt>
#
# [*tendanted*]
# Bool.
# Defaults to <tt>false</tt>
#
# [*request_groups*]
# String containing values 'true' or 'false'
# If undef, defaults to 'true'
#
# [*group_cache_timeout*]
# Integer as String.
# Defaults to <tt>60000</tt>
#
# [*connection_pool_id*]
# String. The name of a pool from http-connection-pool.cfg.xml. Setting this
# tells the connection pool service to map to the pool with specified id. If
# default is chosen, the default connection pool configurations in connection
# pool service is used.
# Defaults to <tt>undef</tt>
#
# [*send_all_tenant_ids*]
# Bool. Set to true to receive a list of all tenant ids associated with a token
# from identity. NOTE: this is not valid for repose version < 6.1.x
# Defaults to <tt>undef</tt>
#
# [*token_expire_feed*]
# Optional. If set, this will configure Repose to listen to Feeds Identity
# token revocation events. Needs a hash containing feed_url, interval,
# user, pass.
#
# === Links
#
# * http://wiki.openrepose.org/display/REPOSE/Client+Authentication+Filter
#
# === Examples
#
# repose::filter::client_auth_n {
#   'default':
#     auth => {
#       user => 'test',
#       pass => 'testpass',
#       uri => 'testuri',
#     },
#     client_maps => [ '.*/events/(\d+)', ],
# }
#
# === Authors
#
# * Alex Schultz <mailto:alex.schultz@rackspace.com>
# * Greg Swift <mailto:greg.swift@rackspace.com>
# * c/o Cloud Integration Ops <mailto:cit-ops@rackspace.com>
#
define repose::filter::client_auth_n (
  $ensure              = present,
  $filename            = 'client-auth-n.cfg.xml',
  $auth                = undef,
  $client_maps         = undef,
  $white_lists         = undef,
  $ignore_tenant_roles = undef,
  $delegable           = false,
  $delegating          = undef,
  $tenanted            = false,
  $request_groups      = undef,
  $token_cache_timeout = undef,
  $group_cache_timeout = '60000',
  $connection_pool_id  = undef,
  $send_all_tenant_ids = undef,
  $token_expire_feed   = undef,
) {

### Validate parameters

## ensure
  if ! ($ensure in [ present, absent ]) {
    fail("\"${ensure}\" is not a valid ensure parameter value")
  } else {
    $file_ensure = $ensure ? {
      present => file,
      absent  => absent,
    }
  }
  if $::debug {
    debug("\$ensure = '${ensure}'")
  }

  if $ensure == present {
## auth
    if $auth == undef {
      fail('auth is a required parameter')
    }
    $content_template = template("${module_name}/client-auth-n.cfg.xml.erb")
  } else {
    $content_template = undef
  }

## Manage actions

  file { "${repose::params::configdir}/${filename}":
    ensure  => $file_ensure,
    owner   => $repose::params::owner,
    group   => $repose::params::group,
    mode    => $repose::params::mode,
    require => Class['::repose::package'],
    content => $content_template
  }

}
