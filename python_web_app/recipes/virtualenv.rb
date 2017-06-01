include_recipe "python_web_app::pip"

python_pip "virtualenv" do
  action :install
end

python_virtualenv "/home/ec2-user/myproject/myprojectenv" do
  owner "ec2-user"
  group "ec2-user"
  options "--system-site-packages"
  action :create
end