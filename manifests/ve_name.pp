# Class sys11lib::ve_name
#
# Parameters:
#   None
#
class sys11lib::ve_name () {

  # touch only if sys11name/role is set (and not when running puppet locally), pp-1155
  if $::role != undef or $::roles != undef {
    file { '/.ve-name':
      mode    => '0400',
      owner   => root,
      group   => root,
      content => template('sys11lib/ve_name.erb'),
    }
  }

}
