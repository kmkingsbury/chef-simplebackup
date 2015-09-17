#
# Cookbook Name:: simplebackup
# Recipe:: default
#
# Copyright (c) 2015 Kevin Kingsbury, All Rights Reserved.

directory node.default['backup_dir'] do
  owner 'root'
  group 'root'
  mode '0700'
  action :create
end

# My Cron create cron job to run script on daily basis
# 00 9 * * * /backup_dir/backup
# @TODO : not_if looks for job so it doesn't redo with every rand, but how do we handle more than one job?
cron 'backupjob' do
 minute rand(60)
 hour node.default['start_hr'] + rand(node.default['end_hr'] - node.default['start_hr'])
 weekday '*'
 command "#{node.default['backup_dir']}/simplebackup.pl"
 action :create
 not_if 'crontab -l | grep simplebackup'
end
