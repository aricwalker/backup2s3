
***NOTE: This gem is no longer maintained. Please contact me if you are interested in helping maintain it.***

SETUP

    1. Add the dependencies to your Gemfile
        gem 'backup2s3'

    2. Run the generator in your application root directory
        rails g backup2s3

    3. Change your settings in config/backup2s3.yml



USAGE (rake tasks)


    Create -- Creates a backup and moves it to S3
           -- comment - Add notes here to mark specific backups (optional)

      rake backup2s3:backup:create
      rake backup2s3:backup:create  comment='put notes about backup here if needed'


    Delete  -- Deletes the specified backup
            -- id - Backup to delete, backup ids will be found using List

      rake backup2s3:backup:delete  id='20100913180541'


    List    -- Lists all backups that are currently on S3
            -- details - Setting details to true will display backup file names
                         and backup comments (optional)

      rake backup2s3:backup:list
      rake backup2s3:backup:list  details=true


    Restore -- Restores a specific backup
            -- id - Backup to restore, backup ids will be found using List task

      rake backup2s3:backup:restore id='20100913180541'
