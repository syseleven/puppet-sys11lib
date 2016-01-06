# Class: ensure_key_value
#
# This define allows to manipulate text files that contain key value pairs separated by $delimiter
#
# Parameters:
#   $file
#     file the file to edit
#   $key
#   $value
#   $ensure = 'present'
#     state if key and value shall be in file (present and absent supported)
#   $delimiter = ' '
#     a regular expression as delimiter between key and value
#
# Actions:
#
#   ensures that $file contains the line
#
#   $key$delimiter$value
#
#   if a line exists that starts with $key$delimiter it is replaced by the above line
#
# Sample Usage:
#   double quotes are not allowed, use single quotes for inside values
#
#
#   ensure_key_value { "/etc/make.conf":
#     file      => '/etc/make.conf',
#     delimiter => '=',
#     key       => 'CFLAGS',
#     value     => "'-O2 -g --pipe'"
#   }
#
define sys11lib::ensure_key_value (
  $file,
  $key,
  $value,
  $ensure = 'present',
  $delimiter = ' ',
) {

  if $::operatingsystem == 'Solaris' {
    $sed_command = 'gsed'
    $grep_command = 'ggrep'
  } else {
    $sed_command = 'sed'
    $grep_command = 'grep'
  }

  #quoting hell ahead
  $sedquotedline = regsubst(regsubst("${key}${delimiter}${value}",'\\','\\\\'), '&', '\\&')
  $regqkey = regsubst($key,'[\[\].*]','\\\0', 'G')
  $qsedexpr = shellquote("s|^[ \t]*${regqkey}[ \t]*${delimiter}.*$|${sedquotedline}|g")
  $qgrepexpr = shellquote("^[ \t]*${regqkey}[ \t]*${delimiter}" )
  $qline = shellquote("${key}${delimiter}${value}")
  $qgrepline = shellquote("${key}${delimiter}${value}")
  $qkey = shellquote($regqkey)
  # append line if "$key" not in "$file"

  if $ensure == 'present' {
    exec { "append ${key}${delimiter}${value} ${file}":
      command => "echo ${qline} >> ${file}",
      unless  => "${grep_command} -qe ${qgrepexpr} -- \"${file}\"",
      path    => '/bin:/usr/bin:/usr/local/bin:/opt/csw/bin',
      before  => Exec["update ${key}${delimiter}${value} ${file}"],
    }

    # update it if it already exists...
    exec { "update ${key}${delimiter}${value} ${file}":
      command => "${sed_command} --in-place='' --expression=${qsedexpr} \"${file}\"",
      unless  => "${grep_command} -xqF ${qgrepline} -- ${file}",
      path    => '/bin:/usr/bin:/usr/local/bin:/opt/csw/bin',
    }
  }
  #currently broken, see https://youtrack.syseleven.de/issue/pp-1116
  #elsif $ensure == 'absent' {
  #  # delete entry if exists
  #  #$escaped_sedquotedline = regsubst($sedquotedline, '/', '\/')
  #  $tmp = regsubst($sedquotedline,'[\[\].*]','\\\0', 'G')
  #  $q_sed_delete_expr = shellquote("\|^$tmp$|d")
  #  exec { "delete $key$delimiter$value $file":
  #    command => "${sed_command} --in-place='' --expression=$q_sed_delete_expr \"$file\"",
  #    onlyif  => "${grep_command} -xqF $qgrepline -- $file",
  #    path    => '/bin:/usr/bin:/usr/local/bin:/opt/csw/bin',
  #  }
  #}
}
