# @api private
class slurm::sackd {
  contain slurm::common::munge
  contain slurm::common::user
  contain slurm::common::install
  contain slurm::common::setup
  contain slurm::common::config
  contain slurm::sackd::service

  Class['munge::service']
  -> Class['slurm::sackd::service']

  Class['slurm::common::user']
  -> Class['slurm::common::install']
  -> Class['slurm::common::setup']
  -> Class['slurm::common::config']
  -> Class['slurm::sackd::service']
}
