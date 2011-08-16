require 'backup2s3'

namespace :backup2s3 do
  namespace :backup do
    desc "Save a full backup to S3"
    task :create do
      Backup2s3.new.create
    end

    desc "Delete a backup from S3"
    task :delete do
      Backup2s3.new.delete
    end

    desc "List all the backups saved on S3"
    task :list do
      Backup2s3.new.list
    end

    desc "Restore your DB from S3"
    task :restore do
      Backup2s3.new.restore
    end
  end  
end
