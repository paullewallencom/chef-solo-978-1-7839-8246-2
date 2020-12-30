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
# include_recipe "mysql::ruby"

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
  enable true
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