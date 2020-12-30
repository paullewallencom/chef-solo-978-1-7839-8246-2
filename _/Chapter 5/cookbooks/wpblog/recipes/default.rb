#
# Cookbook Name:: wpblog
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#
include_recipe "apt"
include_recipe "mysql::client"
include_recipe "mysql::server"
include_recipe "database::mysql"
include_recipe "apache2"
include_recipe "php"
include_recipe "php::module_mysql"
include_recipe "apache2::mod_php5"

%w{ 
    curl
    vim
    screen
	libmysqlclient-dev
}.each do |pkg|
  package pkg do
    action :install
  end
end

apache_site "default" do
  enable false
end

mysql_database node['wpblog']['database'] do
  connection({
    :host     => 'localhost',
    :username => 'root',
    :password => node['mysql']['server_root_password']
  })
  action :create
end

mysql_database_user node['wpblog']['db_username'] do
  connection ({
  	:host => 'localhost',
  	:username => 'root',
  	:password => node['mysql']['server_root_password']
  })
  password node['wpblog']['db_password']
  database_name node['wpblog']['database']
  privileges [:select, :update, :insert, :create, :delete]
  action :grant
end

wordpress_file = Chef::Config[:file_cache_path] + "/wordpress-latest.tar.gz"

remote_file wordpress_file do
  source "http://wordpress.org/latest.tar.gz"
  mode "0644"
end

directory node["wpblog"]["path"] do
  owner "root"
  group "root"
  mode "0755"
  action :create
  recursive true
end

execute "expand-wordpress" do
  cwd node['wpblog']['path']
  command "tar --strip-components 1 -xzf " + wordpress_file
  creates node['wpblog']['path'] + "/wp-settings.php"
end

wp_salt = Chef::Config[:file_cache_path] + '/wp-salt.php'

if File.exist?(wp_salt)
  salt_file = File.read(wp_salt)
else
  require 'open-uri'
  salt_file = open('http://api.wordpress.org/secret-key/1.1/salt/').read
  open(wp_salt, 'wb') do |file|
    file << salt_file
  end
end

template node['wpblog']['path'] + '/wp-config.php' do
  source 'wp-config.php.erb'
  mode 0755
  owner 'root'
  group 'root' 
  variables(
    :database        => node['wpblog']['database'],
    :db_username     => node['wpblog']['db_username'],
    :db_password     => node['wpblog']['db_password'],
    :wp_salt      => salt_file)
end

web_app 'wpblog' do
  template 'site.conf.erb'
  docroot node['wpblog']['path']
  server_name node['wpblog']['server_name']
end
