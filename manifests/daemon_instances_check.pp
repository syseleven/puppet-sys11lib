# Class: sys11lib::daemon_instances_check
#
class sys11lib::daemon_instances_check (
  Optional[Boolean] $enable_check = true,
  Optional[String]  $daemons = 'apache2 mysqld nginx',
) {
  if $enable_check {
    # needed to have nagios::nrpe::plugindir loaded before using
    include nagios::nrpe

    file { 'nagioscheck check_multiple_daemon_instances':
      ensure  => file,
      path    => "${nagios::nrpe::plugindir}/check_multiple_daemon_instances",
      owner   => $nagios::nrpe::nagios_user,
      group   => 'root',
      mode    => '0750',
      content => template('sys11lib/check_multiple_daemon_instances.erb'),
    }

    # set nrpe command
    nagios::nrpecmd { 'check_multiple_daemon_instances':
      cmd => "${nagios::nrpe::plugindir}/check_multiple_daemon_instances",
    }

    # register hostgroup
    nagios::register_hostgroup { 'multiple_daemon_instances':  }
  } else {
    # unregister hostgroup
    nagios::unregister_hostgroup { 'multiple_daemon_instances':  }
  }
}

