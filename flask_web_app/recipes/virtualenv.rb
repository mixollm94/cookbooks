include_recipe "python::pip"

python_pip "virtualenv" do
  action :install
end