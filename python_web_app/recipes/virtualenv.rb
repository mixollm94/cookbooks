include_recipe "python_web_app::pip"

python_pip "virtualenv" do
  action :install
end