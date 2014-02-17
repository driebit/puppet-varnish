class varnish(
  $listenAddress  = '127.0.0.1',
  $listenPort     = '80',
  $storageSize    = '256M',
  $ttl            = '60',
  $configTemplate = 'varnish/varnish.erb',
  $configFile     = '/etc/varnish/default.vcl',
  $backends       = {
                      'default' => { host => '127.0.0.1', port => '80' },
                    }
) {
  yumrepo { 'varnish':
    baseurl  => 'http://repo.varnish-cache.org/redhat/varnish-3.0/el6/$basearch',
    descr    => 'Varnish',
    enabled  => 1,
    gpgcheck => 0,
    priority => 15, # Before epel (that installs Varnish 2)
  }

  package { 'varnish':
    ensure  => latest,
    require => Yumrepo['varnish'],
  }

  file { '/etc/sysconfig/varnish':
    ensure  => file,
    content => template("${configTemplate}"),
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  file { "${configFile}":
    ensure  => file,
    content => template('varnish/default.vcl.erb'),
    notify  => Service['varnish'],
    require => Package['varnish'],
  }

  service { 'varnish':
    ensure  => running,
    require => [ Package['varnish'], File['/etc/sysconfig/varnish'], File["${configFile}"] ],
  }
}