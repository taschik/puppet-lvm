## Sample Usage

  node node01 {
    include lvm
    lvm::vg {"vg0":
      ensure  => present,
      pv    => "/dev/sda4"
    }

    lvm::lv {"host-disk":
      ensure => present,
      size   => "100G",
      vg     => "vg0",
      fstype => "ext4",
      require => Lvm::VG["vg0"],
    }
    lvm::lv { "host-swap":
      ensure => present,
      size   => "1G",
      vg     => "vg0",
      fstype => "swap",
      require => Lvm::VG["vg0"],
    }
  }
## TODO
