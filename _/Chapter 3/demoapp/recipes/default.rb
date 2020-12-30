#
# Cookbook Name:: demoapp
# Recipe:: default
#
# Author:: Naveed ur Rahman
#
%w{
    curl
    vim
}.each do |pkg|
  package pkg do
    action :install
  end
end

apache_site "default" do
  enable true
end

cookbook_file "/var/www/test.php" do
  source "test.php"
  owner "root"
  group "root"
end
