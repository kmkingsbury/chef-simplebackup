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

# read attributes to determine which folders/files to backup
mydatabag = data_bag('simplebackup')
myitem = data_bag_item('simplebackup', node['hostname'])

# Start with 1 Job Only per node/server
backupsource = myitem['job1']['source']
backupdest = myitem['job1']['dest']
nametag = myitem['job1']['tag']
# Loop later
#myitem.each do |job|
#  p "Job : "
#  p job
#  #pp 'Source:' + data_bag_item(data_bag_name, job)['source']
#  #pp 'Dest:' + data_bag_item(data_bag_name, job)['dest']
#end
template "#{node.default['backup_dir']}/simplebackuplist.txt" do
  source "simplebackuplist.txt.erb"
  owner "root"
  group "root"
  mode "0700"
  variables({
    :sourcedir => backupsource,
    :destdir => backupdest,
    :nametag => nametag
  })
end

template "#{node.default['backup_dir']}/simplebackups.pl" do
  source "simplebackups.pl.erb"
  owner "root"
  group "root"
  mode "0700"
end

# My Cron create cron job to run script on daily basis
# 00 9 * * * /backup_dir/backup
# @TODO : not_if looks for job so it doesn't redo with every rand, but how do we handle more than one job? #Jobx maybe
cron 'backupjob' do
 minute rand(60)
 hour node.default['start_hr'] + rand(node.default['end_hr'] - node.default['start_hr'])
 weekday '*'
 command "#{node.default['backup_dir']}/simplebackup.pl; #Job1"
 action :create
 not_if 'crontab -l | grep \'simplebackup.*\#Job1\''
end
