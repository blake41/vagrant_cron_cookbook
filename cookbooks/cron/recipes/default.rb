#
# Cookbook Name:: cron
# Recipe:: default
#
# Copyright 2012, YOUR_COMPANY_NAME
#
# All rights reserved - Do Not Redistribute

CRONS = {:set_path => {
                       "name" => "set path", 
                       "data" => Proc.new {
                          user "vagrant"
                          path "$PATH:/usr/local/bin:/usr/bin:/bin"
                        }
         },
         :minute => {
                      "name" => "minute cron",
                      "data" => Proc.new {
                        user "vagrant"
                        command "/bin/bash -l -c 'cd /var/www/releases && /var/www/releases/script/runner -e production_master 'Cron.run_minute'' >> /var/www/releases/log/cron.log 2>&1"
                        }
         },
         :half_hour => {
                        "name" => "run half hour cron",
                        "data" => Proc.new {
                          hour "0"
                          minute "30"
                          user "vagrant"
                          command "/bin/bash -l -c 'cd /var/www/releases && /var/www/releases/script/runner -e production_master 'Cron.run_half_hour'' >> /var/www/releases/log/cron.log 2>&1"
                        }
         },
         :hour => {
                   "name" => "run hour cron",
                   "data" => Proc.new {
                      minute "0"
                      user "vagrant"
                      command "/bin/bash -l -c 'cd /var/www/releases && /var/www/releases/script/runner -e production_master 'Cron.run_hour'' >> /var/www/releases/log/cron.log 2>&1"
                    }
         },
         :daily => {
                    "name" => "run daily",
                    "data" => Proc.new {
                      hour "0"
                      minute "30"
                      user "vagrant"
                      command "/bin/bash -l -c 'cd /var/www/releases && /var/www/releases/script/runner -e production_master 'Cron.run_daily'' >> /var/www/releases/log/cron.log 2>&1"
                    }
         },
         # why is this running in the staing env?  also we had '\''RollingDiscount.move_all'\'' - what are the \ for?
         :rolling_discount => {
                                "name" => "move rolling discounts",
                                "data" => Proc.new {
                                  user "vagrant"
                                  minute "0,5,10,15,20,25,30,35,40,45,50,55"
                                  command "/bin/bash -l -c 'cd /var/www/releases/calendar && script/rails runner -e staging 'RollingDiscount.move_all'' >> /data/log/cron.log 2>&1"
                                }

         },
         # what is this for?
         :ultrasphinx => {
                           "name" => "ultrasphinx",
                           "data" => Proc.new {
                            user "vagrant"
                            minute "0,10,20,30,40,50"
                            command "/bin/bash -l -c '/usr/local/bin/indexer -c /var/www/current/config/ultrasphinx/production.conf --all --rotate' >> /var/www/current/log/cron.log 2>&1"
                           }
         },
         :sailthru => {
                        "name" => "run sailthru jobs",
                        "data" => Proc.new {
                          user "vagrant"
                          minute "0"
                          hour "3"
                          command "/bin/bash -l -c 'cd /var/www/releases/lifebooker && ./script/runner -e production 'Cron.run_sailthru_jobs'' >> /var/www/releases/log/cron.log 2>&1"
                        }
         },
         # # should we move this to the bin directory?
         :loot_certs => {
                          "name" => "clean out old Loot Certificates",
                          "data" => Proc.new {
                            user "vagrant"
                            minute "0"
                            hour "4"
                            command "/bin/bash -l -c '/data/clean_loot'"
                          }
         },
         :snapshot => {
                        "name" => "snapshot",
                        "data" => Proc.new {
                          hour "0"
                          command "ec2-consistent-snapshot --aws-access-key-id 0TK5DZP6RRVREAJ8A02 --aws-secret-access-key NGkeLu+kXvC0TiB2SPvPgIQeH/dVnzCf1hqx3leo --xfs-filesystem /data --description 'Data Backup' vol-49a72020"
                        }
         },
         :rotate_slave => {
                            "name" => "rotator for DB Slave backup",
                            "data" => Proc.new {
                              user "vagrant"
                              minute "25"
                              hour "3"
                              command "/bin/bash -l -c '/var/www/releases/bin/snapshot_manager.rb vol-7dce3c16' >> /var/www/releases/log/cron.log 2>&1"
                            }
         },
         :rotate_drive => {
                            "name" => "rotator for DB Drive backup",
                            "data" => Proc.new {
                              user "vagrant"
                              minute "25"
                              hour "3"
                              command "/bin/bash -l -c '/var/www/releases/bin/snapshot_manager.rb vol-49a72020' >> /var/www/releases/log/cron.log 2>&1"
                            }
         }
}

node[:crons].each do |cron_task|
  cron_hash = CRONS[cron_task.to_sym] 
  cron cron_hash["name"] do
    instance_exec(&cron_hash["data"])
  end
end

# cron "rotator for DB Slave backup" do
#   minute "25"
#   hour "3"
#   command "/var/www/current/bin/snapshot_manager.rb vol-7dce3c16 >> /var/www/current/log/cron.log 2>&1"
# end

# cron "rotator for DB Drive backup" do
#   minute "25"
#   hour "3"
#   command "/var/www/current/bin/snapshot_manager.rb vol-49a72020 >> /var/www/current/log/cron.log 2>&1"
# end

# cron "set path" do
#   user "vagrant"
#   path "$PATH:/usr/local/bin:/usr/bin:/bin"
# end

# cron "minute cron" do
#   user "vagrant"
#   command "/bin/bash -l -c 'cd /var/www/current && /var/www/current/script/runner -e production_master 'Cron.run_minute'' >> /var/www/current/log/cron.log 2>&1"
# end

# cron "run half hour cron" do
#   hour "0"
#   minute "30"
#   user "vagrant"
#   command "/bin/bash -l -c 'cd /var/www/current && /var/www/current/script/runner -e production_master 'Cron.run_half_hour'' >> /var/www/current/log/cron.log 2>&1"
# end

# cron "run hour cron" do
#   minute "0"
#   user "vagrant"
#   command "/bin/bash -l -c 'cd /var/www/current && /var/www/current/script/runner -e production_master 'Cron.run_hour'' >> /var/www/current/log/cron.log 2>&1"
# end

# cron "run daily" do
#   hour "0"
#   minute "30"
#   user "vagrant"
#   command "/bin/bash -l -c 'cd /var/www/current && /var/www/current/script/runner -e production_master 'Cron.run_daily'' >> /var/www/current/log/cron.log 2>&1"
# end

# cron "move rolling discounts" do
#   user "vagrant"
#   minute "0,5,10,15,20,25,30,35,40,45,50,55"
#   command "/bin/bash -l -c 'cd /var/www/releases/calendar && script/rails runner -e staging 'RollingDiscount.move_all'' >> /data/log/cron.log 2>&1"
# end


# cron "ultrasphinx" do
#   user "vagrant"
#   minute "0,10,20,30,40,50" 
#   command "/bin/bash -l -c '/usr/local/bin/indexer -c /var/www/current/config/ultrasphinx/production.conf --all --rotate' >> /var/www/current/log/cron.log 2>&1"
# end

# cron "run sailthru jobs" do
#   user "vagrant"
#   minute "0"
#   hour "3"
#   command "/bin/bash -l -c 'cd /var/www/current/lifebooker && ./script/runner -e production 'Cron.run_sailthru_jobs'' >> /var/www/current/log/cron.log 2>&1"
# end


# cron "clean out old Loot Certificates" do
#   user "vagrant"
#   minute "0"
#   hour "4"
#   command "/bin/bash -l -c '/data/clean_loot'"
# end

# cron "snapshot" do
#   user "root"
#   hour "0"
#   command "ec2-consistent-snapshot --aws-access-key-id 0TK5DZP6RRVREAJ8A02 --aws-secret-access-key NGkeLu+kXvC0TiB2SPvPgIQeH/dVnzCf1hqx3leo --xfs-filesystem /data --description 'Data Backup' vol-49a72020"
# end

# # cron "blakes test" do
# #   user "vagrant"
# #   command "/bin/bash -l -c 'cd /var/www/current && rails runner -e development 'Blake.say_hello'' >> /var/www/current/log/cron.log 2>&1"
# # end


# # # m h  dom mon dow   command
# # 0   *   *   *   *     /home/bb/check_disk_space
# # staging env? what are these '\' ?
# # 0,5,10,15,20,25,30,35,40,45,50,55 * * * * /bin/bash -l -c 'cd /var/www/releases/calendar && script/rails runner -e staging '\''RollingDiscount.move_all'\'' >> /data/log/cron.log 2>&1'
