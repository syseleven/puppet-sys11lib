# Class: deprecated
#
class sys11lib::deprecated (
  $set = {},
) {

  # Define: sys11lib::deprecated::deprecated_set
  #
  define deprecated_set (
    $old = '',
    $new = '',
    $add = '',
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

  create_resources(sys11lib::deprecated::deprecated_set, $sys11lib::deprecated::set)

}
