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

  desc "Show table sizes for your database"
  task :statistics => :environment do
    rows = Backup2s3.new.statistics
    rows.sort_by {|x| -x[3].to_i }
    header = [["Type", "Data MB", "Index", "Rows", "Name"], []]
    puts (header + rows).collect {|x| x.join("\t") }
  end
end
