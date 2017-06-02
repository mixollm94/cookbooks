#
# Cookbook Name:: aws_test_project
# Recipe:: default
#
# Copyright 2017, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
execute "yum update" do
    command "yum update -y"
end

package 'httpd' do 
	action :install
end

package 'php' do 
	action :install
end

package 'php-mysql' do 
	action :install
end

package 'stress' do 
	action :install
end

cookbook_file "/etc/httpd/conf/httpd.conf" do
	source "httpd.conf"
end

cookbook_file "/var/www/html/healthy.html" do
	source "healthy.html"
	owner 'ec2-user'
    group 'ec2-user'
	mode "0644"
end

bash 'latest.tar.gz' do
	user 'root'
	code <<-EOH
	cd /var/www/html
    wget https://wordpress.org/latest.tar.gz
    tar -xzf latest.tar.gz
    rm -rf wordpress
    rm -rf latest.tar.gz
    chmod -R 755 wp-content
    chown -R apache.apache wp-content
    EOH
end

service 'httpd' do
	action [ :enable, :start ]
end