class Backup2s3Generator < Rails::Generators::Base

  def self.source_root
    @source_root ||= File.expand_path(File.join(File.dirname(__FILE__), 'templates'))
  end
  
  def generate    
    copy_file("backup2s3.rake", "lib/tasks/backup2s3.rake")
    copy_file("backup2s3.yml", "config/backup2s3.yml")
    puts message        
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


        Delete  -- Deletes a backup specified by id parameter
                -- id - Backup to delete, backup ids will be found using List

          rake backup2s3:backup:delete  id='20100913180541'


        List    -- Lists all backups that are currently on S3
                -- details - Setting details to true will display backup file names
                             and backup comments (optional)

          rake backup2s3:backup:list
          rake backup2s3:backup:list  details=true


        Restore -- Restores a backup specified by id parameter
                -- id - Backup to restore, backup ids will be found using List

          rake backup2s3:backup:restore id='20100913180541'      

    -------------------------------------------------------------------

    MESSAGE
  end

end