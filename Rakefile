require 'rubygems'
require 'rake'
require 'echoe'

Echoe.new('backup2s3', '0.2.2') do |p|
  p.description = "Backup2s3 is a gem that performs database and application backups and stores this data on Amazon S3."
  p.summary     = "Backup2s3 is a gem that creates, deletes and restores db and application backups."
  p.url         = "http://github.com/aricwalker/backup2s3"
  p.author      = "Aric Walker"
  p.email       = "aric@truespire.com"
  p.ignore_pattern = ["nbproject/*/*", "nbproject/*"]
  p.development_dependencies = ["aws-s3 >=0.6.2"]
end