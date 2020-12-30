#
# Cookbook Name:: django_app
# Recipe:: default
#
# Copyright 2014, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute
#

%w{
    curl
    vim
    screen
    git
    python2.7-dev
    python-setuptools
    sqlite3
}.each do |pkg|
  package pkg do
    action :install
  end
end

include_recipe "python::pip"

python_pip "virtualenv" do
  version "1.10.1"
  action :install
end

user_account node[:django_app][:user] do
    ssh_keygen true
end

python_virtualenv node[:django_app][:virtual_env] do
  owner node[:django_app][:user]
  group node[:django_app][:group]
  action :create
end

git node[:django_app][:path] do
  repository node[:django_app][:repository]
  reference node[:django_app][:branch]
  action :sync
  enable_submodules true
  user node[:django_app][:user]
  group node[:django_app][:group]
end

python_pip "uwsgi" do
  user node[:django_app][:user]
  group node[:django_app][:group]
  virtualenv node[:django_app][:virtual_env]
end

python_pip "django" do
  user node[:django_app][:user]
  group node[:django_app][:group]
  virtualenv node[:django_app][:virtual_env]
end

template "/etc/nginx/sites-enabled/#{node[:django_app][:nginx_conf]}" do
  not_if { ::File.exists?("/etc/nginx/sites-enabled/#{node[:django_app][:nginx_conf]}") }
  source "site.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end

cookbook_file "/etc/nginx/uwsgi_params" do
  source "uwsgi_params"
  owner "root"
  group "root"
end

template node[:django_app][:uwsgi_path] do
  source "uwsgi.ini.erb"
  owner "root"
  group "root"
  mode "0755"
end

template "/etc/init/django_app.conf" do
  source "django_app.conf.erb"
  owner "root"
  group "root"
  mode "0755"
end

service node[:django_app][:app_name] do
  provider Chef::Provider::Service::Upstart
  supports :status => true, :restart => true, :reload => true
  action [:enable, :start]
end
