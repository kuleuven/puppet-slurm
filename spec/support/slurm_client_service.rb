shared_examples 'slurm::client::service' do
  let(:params) { context_params }

  it { should have_service_resource_count(2) }

  it do
    should contain_service('slurm').with({
      :ensure     => 'stopped',
      :enable     => 'false',
      :hasstatus  => 'true',
      :hasrestart => 'true',
    })
  end
end