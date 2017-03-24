#
# Cookbook Name:: python_web_app
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "python_web_app::nginx"
include_recipe "python_web_app::pip"
include_recipe "python_web_app::virtualenv"

directory '/home/ec2-user/myproject' do
  owner 'ec2-user'
  group 'ec2-user'
  mode "0666"
  action :create
end

template "/home/ec2-user/myproject/myproject.py" do
  source "myproject.py"
  owner 'ec2-user'
  group 'ec2-user'
  mode "0666"
end

