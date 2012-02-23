# Define: lv
# Parameters:
# ensure, vg, size=NONE
#
define lvm::lv ( $ensure = present, $vg, $size = undef, fstype = "ext4" ) {
  case $ensure {
    present: {
        exec { "Create and format LVM device /dev/${vg}/${name}":
          command => inline_template("lvcreate -L ${size} --name ${name} ${vg} && <% if fstype != \"swap\" %> mkfs -t ${fstype} /dev/${vg}/${name} <% else %> mkswap /dev/${vg}/${name} <% end %>"),
          unless  => "test -e /dev/${vg}/${name}",
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
