# Class sys11lib::ve_name
#
# Parameters:
#   None
#
class sys11lib::ve_name () {
  file { '/.ve-name':
    mode    => '0400',
    owner   => root,
    group   => root,
    content => template('sys11lib/ve_name.erb'),
  }
}
