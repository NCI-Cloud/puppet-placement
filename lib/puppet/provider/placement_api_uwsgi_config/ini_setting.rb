Puppet::Type.type(:placement_api_uwsgi_config).provide(
  :ini_setting,
  :parent => Puppet::Type.type(:openstack_config).provider(:ini_setting)
) do

  def self.file_path
    '/etc/placement/placement-api-uwsgi.ini'
  end

end
