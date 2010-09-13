class Backup2s3Generator < Rails::Generator::Base

  def manifest
    record do |m|
      
      m.directory("lib/tasks")
      m.file("backup2s3.rake", "lib/tasks/backup2s3.rake")

      m.directory("config")
      m.file("backup2s3.yml", "config/backup2s3.yml")

      puts message
    end
  end

  def message
    <<-MESSAGE

    -------------------------------------------------------------------

    You have successfully installed backup2s3!

    1. Modify your configuration file:

      config/backup2s3.yml

    2. Get started.

      Backup tasks

        Create -- Creates a backup and moves it to S3
               -- comment - Add notes here to mark specific backups (optional)

          rake backup2s3:backup:create
          rake backup2s3:backup:create  comment='put notes about backup here if needed'


        Delete  -- Deletes the specific backup
                -- id - Backup to delete, backup ids will be found using List

          rake backup2s3:backup:delete  id='20100913180541'


        List    -- Lists all backups that are currently on S3
                -- details - Setting details to true will display backup file names
                             and backup comments (optional)

          rake backup2s3:backup:list
          rake backup2s3:backup:list  details=true


        Restore -- Restores a specific backup
                -- id - Backup to restore, backup ids will be found using List

          rake backup2s3:backup:restore id='20100913180541'

      Some handy tasks

        rake backup2s3:statistics     - Shows you the size of your DB

    -------------------------------------------------------------------

    MESSAGE
  end

end