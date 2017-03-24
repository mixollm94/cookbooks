
require 'chef/mixin/shell_out'
require 'chef/mixin/language'
include Chef::Mixin::ShellOut

def whyrun_supported?
  true
end

# the logic in all action methods mirror that of
# the Chef::Provider::Package which will make
# refactoring into core chef easy

action :install do
  # If we specified a version, and it's not the current version, move to the specified version
  if @new_resource.version != nil && @new_resource.version != @current_resource.version
    install_version = @new_resource.version
  # If it's not installed at all, install it
  elsif @current_resource.version == nil
    install_version = candidate_version
  end

  if install_version
    description = "install package #{@new_resource} version #{install_version}"
    converge_by(description) do
      Chef::Log.info("Installing #{@new_resource} version #{install_version}")
      status = install_package(install_version)
      if status
        @new_resource.updated_by_last_action(true)
      end
    end
  end
end

action :upgrade do
  if @current_resource.version != candidate_version
    orig_version = @current_resource.version || "uninstalled"
    description = "upgrade #{@current_resource} version from #{@current_resource.version} to #{candidate_version}"
    converge_by(description) do
      Chef::Log.info("Upgrading #{@new_resource} version from #{orig_version} to #{candidate_version}")
      status = upgrade_package(candidate_version)
      if status
        @new_resource.updated_by_last_action(true)
      end
    end
  end
end

action :remove do
  if removing_package?
    description = "remove package #{@new_resource}"
    converge_by(description) do
      Chef::Log.info("Removing #{@new_resource}")
      remove_package(@new_resource.version)
      @new_resource.updated_by_last_action(true)
    end
  end
end

def removing_package?
  if @current_resource.version.nil?
    false # nothing to remove
  elsif @new_resource.version.nil?
    true # remove any version of a package
  elsif @new_resource.version == @current_resource.version
    true # remove the version we have
  else
    false # we don't have the version we want to remove
  end
end

# these methods are the required overrides of
# a provider that extends from Chef::Provider::Package
# so refactoring into core Chef should be easy

def load_current_resource
  @current_resource = Chef::Resource::PythonPip.new(@new_resource.name)
  @current_resource.package_name(@new_resource.package_name)
  @current_resource.version(nil)

  unless current_installed_version.nil?
    @current_resource.version(current_installed_version)
  end

  @current_resource
end

def current_installed_version
  @current_installed_version ||= begin
    delimeter = /==/

    version_check_cmd = "#{which_pip(@new_resource)} freeze | grep -i '^#{@new_resource.package_name}=='"
    # incase you upgrade pip with pip!
    if @new_resource.package_name.eql?('pip')
      delimeter = /\s/
      version_check_cmd = "pip --version"
    end
    p = shell_out!(version_check_cmd)
    p.stdout.split(delimeter)[1].strip
  rescue Chef::Exceptions::ShellCommandFailed
  rescue Mixlib::ShellOut::ShellCommandFailed
  end
end

def candidate_version
  @candidate_version ||= begin
    # `pip search` doesn't return versions yet
    # `pip list` may be coming soon:
    # https://bitbucket.org/ianb/pip/issue/197/option-to-show-what-version-would-be
    @new_resource.version||'latest'
  end
end

def install_package(version)
  pip_cmd('install', version == 'latest' ? '' : "==#{version}")
end

def upgrade_package(version)
  @new_resource.options "#{@new_resource.options} --upgrade"
  install_package(version)
end

def remove_package(version)
  @new_resource.options "#{@new_resource.options} --yes"
  pip_cmd('uninstall')
end

def pip_cmd(subcommand, version='')
  options = { :timeout => @new_resource.timeout, :user => @new_resource.user, :group => @new_resource.group }
  options[:environment] = { 'HOME' => ::File.expand_path("~#{@new_resource.user}") } if @new_resource.user
  shell_out!("#{which_pip(@new_resource)} #{subcommand} #{@new_resource.options} #{@new_resource.name}#{version}", options)
end

# TODO remove when provider is moved into Chef core
# this allows PythonPip to work with Chef::Resource::Package
def which_pip(nr)
  if (nr.respond_to?("virtualenv") && nr.virtualenv)
    ::File.join(nr.virtualenv,'/bin/pip')
  elsif "#{node['python']['install_method']}".eql?("source")
    ::File.join("#{node['python']['prefix_dir']}","/bin/pip")
  else
    'pip'
  end