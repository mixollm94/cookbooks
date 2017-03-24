#
# Cookbook Name:: flask_web_app
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

include_recipe "python::#{node['python']['install_method']}"
include_recipe "python::pip"
include_recipe "python::virtualenv"