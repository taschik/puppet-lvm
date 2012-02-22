# Define: lv
# Parameters:
# ensure, vg, size=NONE
#
define lvm::lv ( $ensure = present, $vg, $size = undef, fstype = "ext4" ) {
  case $ensure {
    present: {
      exec { "Create LVM device /dev/${vg}/${name}":
        command => "lvcreate -L ${size} --name ${name} ${vg}",
        unless  => "test -e /dev/${vg}/${name}",
      }
      if $fstype == 'swap' {
        exec { "Format LVM device /dev/${vg}/${name} as Swap":
        command => "mkswap /dev/${vg}/${name}",
        unless  => "test -e /dev/${vg}/${name}",
        require => Exec["Create LVM device /dev/${vg}/${name}"],
        }
      }
      else {
        exec { "Formating LVM device /dev/${vg}/${name}":
        command => "mkfs -t ${fstype} /dev/${vg}/${name}",
        unless  => "test -e /dev/${vg}/${name}",
        require => Exec["Create LVM device /dev/${vg}/${name}"],
        }
      }

    }

    extend: {
      exec { "Extend LVM device /dev/${vg}/${name}":
        command => "lvextend -L +${size} /dev/${vg}/${name}",
        onlyif  => "test -e /dev/${vg}/${name}",
      }
    notify{"Filesystem needs to be manually extened!":}
    }

    # reduce: {
    #   exec { "Reduce LVM device /dev/${vg}/${name}":
    #     command => "lvreduce --force -L -${size} /dev/${vg}/${name}",
    #     onlyif  => "test -e /dev/${vg}/${name}",
    #   }
    # }

    absent: {
      exec { "Remove LVM device /dev/${vg}/${name}":
        command => "lvremove --force /dev/${vg}/${name}",
        onlyif  => "test -e /dev/${vg}/${name}",
      }
    }
  }
}
