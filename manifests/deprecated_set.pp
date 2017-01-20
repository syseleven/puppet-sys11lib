# Define: sys11lib::deprecated_set
#
define sys11lib::deprecated_set (
  $old = undef,
  $new = undef,
  $add = undef,
) {
  notify { $name:
    message => "
    ##########################################################################################
    # 
    # WARNING
    #
    # ${old} is deprecated. Use ${new} instead. ${add}
    #
    ##########################################################################################",
  }
}
