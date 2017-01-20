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
  create_resources(sys11lib::wget_fetch, $pkg)
}
