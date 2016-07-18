# Class: sys11lib::ssl_certificate_check
#
class sys11lib::ssl_certificate_check (
  $place_script = true,
  $enable_check = true,
  $enable_autodetection = true,
  $blacklist_domains = '',
  $blacklist_domains_file = '',
  $whitelist_domains = '',
  $whitelist_domains_file = '',
  $blacklist_certificates = '',
  $blacklist_certificates_file = '',
  $service = '',
  $return_ok_when = 'A',
  $return_warning_when = 'BC',
  $return_critical_when = 'DEFT',
  $skip_ip_check = false,
  $curl_recheck_runs = 5,
  $curl_recheck_interval = 10,
  $curl_recheck_timeout = 300,
  $cache_result_days = 7,
  $cronjob_hour = -1,
  $cronjob_minute = -1,
) {
  # ensure correct types
  validate_bool ( $place_script )
  validate_bool ( $enable_check )
  validate_bool ( $enable_autodetection )
  if is_array ( $blacklist_domains ) {
    validate_string ( join ( $blacklist_domains, '' ) )
  } else {
    validate_string ( $blacklist_domains )
  }
  if $blacklist_domains_file != '' {
    validate_absolute_path ( $blacklist_domains_file )
  }
  unless is_array ( $whitelist_domains ) or is_string ( $whitelist_domains ) {
    fail('$blacklist_certificates needs to be a string or an array of strings')
  }
  if $whitelist_domains_file != '' {
    validate_absolute_path ( $whitelist_domains_file )
  }
  unless is_array ( $blacklist_certificates ) or is_string ( $blacklist_certificates ) {
    fail('$blacklist_certificates needs to be a string or an array of strings')
  }
  if $blacklist_certificates_file != '' {
    validate_absolute_path ( $blacklist_certificates_file )
  }
  validate_string ( $service )
  validate_string ( $return_ok_when )
  validate_string ( $return_warning_when )
  validate_string ( $return_critical_when )
  validate_bool ( $skip_ip_check )
  if ! is_integer ( $curl_recheck_runs ) {
    fail ( '$curl_recheck_runs must be an integer' )
  }
  if ! is_integer ( $curl_recheck_interval ) {
    fail ( '$curl_recheck_interval must be an integer' )
  }
  if ! is_integer ( $curl_recheck_timeout ) {
    fail ( '$curl_recheck_timeout must be an integer' )
  }
  if ! is_integer ( $cache_result_days ) {
    fail ( '$cache_result_days must be an integer' )
  }
  if ! is_integer ( $cronjob_hour ) {
    fail ( '$cronjob_hour must be an integer' )
  }
  if ! is_integer ( $cronjob_minute ) {
    fail ( '$cronjob_minute must be an integer' )
  }

  # check paremeters
  if $place_script == false and $enable_check == true {
    fail ( 'You had to place the script to enable the cronjob. Please set "place_script: true"' )
  }
  if ( join(sort(split("${return_ok_when}${return_warning_when}${return_critical_when}",''))) != 'ABCDEFT' ) {
    fail ( 'You had to specify each of "ABCDEFT" once in return_ok_when, return_warning_when and return_critical_when' )
  }

  # create random cronjob time if necessary
  if $cronjob_minute == -1 {
    $real_cronjob_minute = fqdn_rand(60)
  } else {
    $real_cronjob_minute = $cronjob_minute
  }
  if $cronjob_hour == -1 {
    $real_cronjob_hour = fqdn_rand(24)
  } else {
    $real_cronjob_hour = $cronjob_hour
  }

  # ensure whois
  case $::operatingsystem {
    'gentoo': {
      ensure_packages ( ['net-misc/whois','sys-devel/bc'] )
    }
    'ubuntu', 'debian': {
      ensure_packages ( ['whois','bc'] )
    }
    default: {
      notice("Unknown OS: ${::operatingsystem}, you had to ensure that whois is available by yourself")
    }
  }

  file { '/var/cache/ssl':
    ensure => directory,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
  }

  # place or remove the script
  if $place_script {
    file { 'script check_ssl_certificates':
      ensure  => file,
      path    => '/usr/local/sbin/check_ssl_certificates',
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template('sys11lib/check_ssl_certificates.script.erb'),
    }
  } else {
    file { 'script check_ssl_certificates':
      ensure => absent,
      path   => '/usr/local/sbin/check_ssl_certificates',
    }
  }

  # place and activate or remove the cronjob and the nagioscheck
  if $enable_check {
    file { 'caller check_ssl_certificates':
      ensure  => file,
      path    => '/usr/local/sbin/call_ssl_certificates_check',
      owner   => 'root',
      group   => 'root',
      mode    => '0700',
      content => template('sys11lib/check_ssl_certificates.caller.erb'),
    } ->
    cron { 'certificate_check':
      ensure  => present,
      name    => 'SysEleven SSL certificate check',
      hour    => $real_cronjob_hour,
      minute  => $real_cronjob_minute,
      user    => 'root',
      command => '/usr/local/sbin/call_ssl_certificates_check >/dev/null 2>/dev/null',
    }

    # needed to have nagios::nrpe::plugindir loaded before using
    include nagios::nrpe

    file { 'nagioscheck check_ssl_certificates':
      ensure  => file,
      path    => "${nagios::nrpe::plugindir}/check_ssl_certificates",
      owner   => $nagios::nrpe::nagios_user,
      group   => 'root',
      mode    => '0750',
      content => template('sys11lib/check_ssl_certificates.nagioscheck.erb'),
    }

    # set nrpe command
    nagios::nrpecmd { 'check_ssl_certificates':
      cmd => "${nagios::nrpe::plugindir}/check_ssl_certificates",
    }

    # register hostgroup
    nagios::hostgroup::register_hostgroup { 'ssl_certificate_grade':  }
  } else {
    # remove cronjob
    file { 'caller check_ssl_certificates':
      ensure => absent,
      path   => '/usr/local/sbin/call_ssl_certificates_check',
    } ->
    cron { 'certificate_check':
      ensure => absent,
      name   => 'SysEleven SSL certificate check',
    }

    # unregister hostgroup
    nagios::hostgroup::unregister_hostgroup { 'ssl_certificate_grade':  }
  }
}
