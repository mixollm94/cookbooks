package 'python-pip' 

service 'python-pip' do
	action [ :enable, :start]
end

package 'python-dev' 

service 'python-dev' do
	action [ :enable, :start]
end