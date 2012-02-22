
define lvm::vg ( $ensure = present, $pv ) {
  case $ensure {
    present: {
      exec { "Create LVM VG /dev/${name}/":
        command => "vgcreate ${name} ${pv}",
        unless  => "test -e /dev/${name}",
      }
    }

    extend: {
      exec { "Adding ${pv} to LVM VG /dev/${name}":
        command => "vgextend /dev/${name} ${pv}",
        onlyif  => "test -e /dev/${name}",
      }
    }

    reduce: {
      exec { "Remove physical volume ${pv} from /dev/${name}":
        command => "vgreduce --force /dev/${name} ${pv}",
        onlyif  => "test -e /dev/${name}",
      }
    }

    absent: {
      exec { "Remove VG /dev/${name}":
        command => "vgremove --force /dev/${name}",
        onlyif  => "test -e /dev/${name}",
      }
    }
  }
}