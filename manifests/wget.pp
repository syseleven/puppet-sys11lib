# Class: sys11lib::wget
#
# This class manages simple package installations using wget.
# On Gentoo, it does not support (un)masking, keywording oder useflags.
#
# Parameters:
#   $pkg = {}
#     the hash of the package to be managed
#
# Example usage:
#
# sys11lib::wget:
#   pkg:
#     '/var/www/klobana'
#       source: 'https://github.com/klobana'
#
class sys11lib::wget(
  $pkg= {},
) {

  # define sys11lib::wget::pkg_set
  #
  # Parameters:
  #   $destination        = $name,
  #     Destination 
  #   $source             = undef,
  #     Source URI
  #   $timeout            = '0',
  #     Timeout
  #   $unpack = false,
  #     Unpack compressed file 
  #   $deletearchive = false,
  #     Delete archive after unpacking
  #   $verbose            = false,
  #     Verbose mode
  #   $redownload         = false,
  #     Redownload
  #   $nocheckcertificate = false,
  #     Disable SSL Cert check
  #   $no_cookies         = false,
  #     Do not set cookies
  #   $execuser           = undef,
  #     User to use
  #   $user               = undef,
  #     User for login
  #   $password           = undef,
  #     Password for login
  #   $headers            = undef,
  #     Extra headers to send
  #   $cache_dir          = undef,
  #     Cache dir to use
  #   $cache_file         = undef,
  #     Cache file to use
  #   $flags              = undef,
  #     Extra flags to set
  #
  define pkg_set(
    $destination        = $name,
    $source             = undef,
    $timeout            = '0',
    $verbose            = false,
    $redownload         = false,
    $nocheckcertificate = false,
    $no_cookies         = false,
    $unpack             = false,
    $deletearchive      = false,
    $execuser           = undef,
    $user               = undef,
    $password           = undef,
    $headers            = undef,
    $cache_dir          = undef,
    $cache_file         = undef,
    $flags              = undef,
  ) {


  if $unpack {
    $final_destination = regsubst($destination, '.(tar\.gz|tgz|tar\.bz|tbz|zip)$', '')
    $download_destination = regsubst($source, '^.*\/', '/tmp/')
    $unpacksequence = $download_destination ? {
      /(tar\.gz|tgz)$/ => "tar zxvf ${download_destination} --strip-components=1 -C ${final_destination}",
      /(tar\.bz|tbz)$/ => "tar jxvf ${download_destination} --strip-components=1 -C ${final_destination}",
      /zip$/ => "unzip -d ${final_destination} ${download_destination}",
      default => fail("Don't know how to unpack this extension: ${download_destination}"),
    }
    file { $final_destination:
      ensure => directory,
    }
    exec {"unpack-${final_destination}":
      command => $unpacksequence,
      require => Wget::Fetch["${download_destination}_fetch"],
      path    => '/usr/bin:/usr/sbin:/bin:/usr/local/bin:/opt/local/bin',
      unless  => "[ $(ls -A ${final_destination}) ]",
    }
  
  }
  else {
      $download_destination = $destination
  }
    wget::fetch { "${download_destination}_fetch":
      destination        => $download_destination,
      source             => $source,
      timeout            => $timeout,
      verbose            => $verbose,
      redownload         => $redownload,
      nocheckcertificate => $nocheckcertificate,
      no_cookies         => $no_cookies,
      execuser           => $execuser,
      user               => $user,
      password           => $password,
      headers            => $headers,
      cache_dir          => $cache_dir,
      cache_file         => $cache_file,
      flags              => $flags,
    }
  }

  create_resources(sys11lib::wget::pkg_set, $sys11lib::wget::pkg)
}
