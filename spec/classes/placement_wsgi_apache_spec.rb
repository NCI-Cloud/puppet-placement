require 'spec_helper'

describe 'placement::wsgi::apache' do
  shared_examples 'placement::wsgi::apache' do
    context 'with default parameters' do
      it { should contain_class('placement::params') }

      it { should contain_openstacklib__wsgi__apache('placement_wsgi').with(
        :bind_host                 => nil,
        :bind_port                 => 8778,
        :group                     => 'placement',
        :path                      => '/',
        :priority                  => '10',
        :servername                => facts[:fqdn],
        :ssl                       => true,
        :ssl_ca                    => nil,
        :ssl_cert                  => nil,
        :ssl_certs_dir             => nil,
        :ssl_chain                 => nil,
        :ssl_crl                   => nil,
        :ssl_crl_path              => nil,
        :ssl_key                   => nil,
        :threads                   => 1,
        :user                      => 'placement',
        :workers                   => facts[:os_workers],
        :wsgi_daemon_process       => 'placement-api',
        :wsgi_process_group        => 'placement-api',
        :wsgi_script_dir           => platform_params[:wsgi_script_path],
        :wsgi_script_file          => 'placement-api',
        :wsgi_script_source        => platform_params[:wsgi_script_source],
        :access_log_file           => false,
        :access_log_format         => false,
        :error_log_file            => nil,
      )}
    end

    context 'when overriding parameters' do
      let :params do
        {
          :servername                => 'dummy.host',
          :bind_host                 => '10.42.51.1',
          :api_port                  => 12345,
          :path                      => '/custom',
          :ssl                       => false,
          :workers                   => 10,
          :ssl_cert                  => '/etc/ssl/certs/placement.crt',
          :ssl_key                   => '/etc/ssl/private/placement.key',
          :ssl_chain                 => '/etc/ssl/certs/chain.pem',
          :ssl_ca                    => '/etc/ssl/certs/ca.pem',
          :ssl_crl_path              => '/etc/ssl/crl',
          :ssl_crl                   => '/etc/ssl/certs/crl.crt',
          :ssl_certs_dir             => '/etc/ssl/certs',
          :vhost_custom_fragment     => 'Timeout 99',
          :wsgi_process_display_name => 'custom',
          :threads                   => 5,
          :priority                  => '25',
          :access_log_file           => '/var/log/httpd/access_log',
          :access_log_format         => 'some format',
          :error_log_file            => '/var/log/httpd/error_log',
        }
      end

      it { should contain_class('placement::params') }

      it { should contain_openstacklib__wsgi__apache('placement_wsgi').with(
        :bind_host                 => params[:bind_host],
        :bind_port                 => params[:api_port],
        :group                     => 'placement',
        :path                      => params[:path],
        :priority                  => params[:priority],
        :servername                => params[:servername],
        :ssl                       => params[:ssl],
        :ssl_ca                    => params[:ssl_ca],
        :ssl_cert                  => params[:ssl_cert],
        :ssl_certs_dir             => params[:ssl_certs_dir],
        :ssl_chain                 => params[:ssl_chain],
        :ssl_crl                   => params[:ssl_crl],
        :ssl_crl_path              => params[:ssl_crl_path],
        :ssl_key                   => params[:ssl_key],
        :threads                   => params[:threads],
        :user                      => 'placement',
        :vhost_custom_fragment     => 'Timeout 99',
        :workers                   => params[:workers],
        :wsgi_daemon_process       => 'placement-api',
        :wsgi_process_display_name => params[:wsgi_process_display_name],
        :wsgi_process_group        => 'placement-api',
        :wsgi_script_dir           => platform_params[:wsgi_script_path],
        :wsgi_script_file          => 'placement-api',
        :wsgi_script_source        => platform_params[:wsgi_script_source],
        :access_log_file           => params[:access_log_file],
        :access_log_format         => params[:access_log_format],
        :error_log_file            => params[:error_log_file],
      )}
    end
  end

  on_supported_os({
    :supported_os => OSDefaults.get_supported_os
  }).each do |os,facts|
    context "on #{os}" do
      let (:facts) do
        facts.merge!(OSDefaults.get_facts({
          :os_workers     => 42,
          :concat_basedir => '/var/lib/puppet/concat',
          :fqdn           => 'some.host.tld',
        }))
      end

      let(:platform_params) do
        case facts[:osfamily]
        when 'Debian'
          {
            :wsgi_script_path   => '/usr/lib/cgi-bin/placement',
            :wsgi_script_source => '/usr/bin/placement-api',
          }
        when 'RedHat'
          {
            :wsgi_script_path   => '/var/www/cgi-bin/placement',
            :wsgi_script_source => '/usr/bin/placement-api',
          }
        end
      end

      it_behaves_like 'placement::wsgi::apache'
    end
  end
end