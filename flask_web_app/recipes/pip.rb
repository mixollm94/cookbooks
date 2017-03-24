
if platform_family?("rhel") and node['python']['install_method'] == 'package'
  pip_binary = "/usr/bin/pip"
elsif platform_family?("smartos")
  pip_binary = "/opt/local/bin/pip"
else
  pip_binary = "/usr/local/bin/pip"
end

# Ubuntu's python-setuptools, python-pip and python-virtualenv packages
# are broken...this feels like Rubygems!
# http://stackoverflow.com/questions/4324558/whats-the-proper-way-to-install-pip-virtualenv-and-distribute-for-python
# https://bitbucket.org/ianb/pip/issue/104/pip-uninstall-on-ubuntu-linux
remote_file "#{Chef::Config[:file_cache_path]}/distribute_setup.py" do
  source "http://python-distribute.org/distribute_setup.py"
  mode "0644"
  not_if { ::File.exists?(pip_binary) }
end

execute "install-pip" do
  cwd Chef::Config[:file_cache_path]
  command <<-EOF
  #{node['python']['binary']} distribute_setup.py
  #{::File.dirname(pip_binary)}/easy_install pip
  EOF
  not_if { ::File.exists?(pip_binary) }
end