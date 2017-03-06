#
# Cookbook:: nginx_test
# Recipe:: default
#
# Copyright:: 2017, The Authors, All Rights Reserved.


package 'nginx' do
  action :install
end

service 'nginx' do
	action [ :enable, :start]
end

cookbook_file "/usr/share/nginx/html/index.html" do
  source "index.html"
  owner 'ec2-user'
  group 'ec2-user'
  mode "0644"
end




