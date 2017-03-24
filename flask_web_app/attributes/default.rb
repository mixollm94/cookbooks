
default['python']['install_method'] = 'package'

if python['install_method'] == 'package'
  case platform
  when "smartos"
    default['python']['prefix_dir']         = '/opt/local'
  else
    default['python']['prefix_dir']         = '/usr'
  end
else
  default['python']['prefix_dir']         = '/usr/local'
end

default['python']['binary'] = "#{python['prefix_dir']}/bin/python"

default['python']['url'] = 'http://www.python.org/ftp/python'
default['python']['version'] = '3.6.1'
default['python']['checksum'] = '80e387bcf57eae8ce26726753584fd63e060ec11682d1145af921e85fd612292'
default['python']['configure_options'] = %W{--prefix=#{python['prefix_dir']}}