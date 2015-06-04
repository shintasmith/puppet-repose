# == Resource: repose::filter::translation
#
# This is a resource for generating translation configuration files
#
# === Parameters
#
# [*ensure*]
# Bool. Ensure config file present/absent
# Defaults to <tt>present</tt>
#
# [*filename*]
# String. Config filename
# Defaults to <tt>translation.cfg.xml</tt>
#
# [*app_name*]
# String. Application name
# Defaults to <tt>repose</tt>
#
# [*request_translations*]
# List containing http_methods, content_type, accept,
# translated_content_type, and a list of styles
# Defaults to <tt>undef</tt>
#
# [*response_translations*]
# List containing content_type, accept, translated_content_type,
# and a list of styles
# Defaults to <tt>undef</tt>
#
# [*xsl-engine*]
# String.  XSL-Engine.
# Defaults to <tt>SaxonHE<tt>
#
# === Links
#
# * http://wiki.openrepose.org/display/REPOSE/Translation
#
# === Examples
#
# === Authors
#
# * Greg Swift <mailto:greg.swift@rackspace.com>
# * c/o Cloud Integration Ops <mailto:cit-ops@rackspace.com>
#
define repose::filter::translation (
  $ensure                = present,
  $filename              = 'translation.cfg.xml',
  $app_name              = 'repose',
  $request_translations  = undef,
  $response_translations = undef,
  $xsl_engine            = 'SaxonHE'
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
    $content_template = template("${module_name}/translation.cfg.xml.erb")
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
