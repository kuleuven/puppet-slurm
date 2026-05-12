# @api private
class slurm::sackd::service {
  if $slurm::conf_server {
    $conf_option = "--conf-server ${slurm::conf_server}"
  } elsif $slurm::configless {
    $_slurmctld_host = $slurm::slurmctld_host ? {
      Array   => $slurm::slurmctld_host[0],
      default => $slurm::slurmctld_host,
    }
    $conf_option = "--conf-server ${_slurmctld_host}:${slurm::slurmctld_port}"
  } else {
    $conf_option = "-f ${slurm::slurm_conf_path}"
  }

  $sackd_options = [
    $conf_option,
    $slurm::sackd_options,
  ].filter |$c| { $c =~ NotUndef }.join(' ')

  file { "${slurm::env_dir}/sackd":
    ensure  => 'file',
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
    content => template('slurm/sysconfig/sackd.erb'),
    notify  => Service['sackd'],
  }

  if ! empty($slurm::sackd_service_limits) {
    systemd::manage_dropin { 'sackd.service-90-limits.conf':
      ensure         => present,
      unit           => 'sackd.service',
      filename       => '90-limits.conf',
      service_entry  => $slurm::sackd_service_limits,
      notify_service => true,
    }
  }

  systemd::dropin_file { 'sackd-logging.conf':
    ensure         => $slurm::logging_systemd_override,
    unit           => 'sackd.service',
    content        => join([
        '# File managed by Puppet',
        '[Service]',
        'StandardOutput=null',
        'StandardError=null',
    ], "\n"),
    notify_service => false,
    notify         => Service['sackd'],
  }

  if $slurm::install_method == 'source' {
    systemd::unit_file { 'sackd.service':
      ensure  => 'present',
      content => template('slurm/sackd/sackd.service.erb'),
      notify  => Service['sackd'],
    }
  }

  service { 'sackd':
    ensure     => $slurm::sackd_service_ensure,
    enable     => $slurm::sackd_service_enable,
    hasstatus  => true,
    hasrestart => true,
  }
}
