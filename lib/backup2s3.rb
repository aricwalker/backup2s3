require 'rubygems'
require 'active_support'
require 'tempfile'
require 'yaml'

require 'system.rb'
require 'adapters/s3_adapter.rb'
require 'adapters/s3cmd_adapter.rb'
require 'backup_management/backup.rb'
require 'backup_management/backup_manager.rb'

class Backup2s3
  include System

  def initialize
    STDOUT.sync = true #used so that print will not buffer output
    #ActiveResource::Base.logger = true
    load_configuration
    load_adapter
    load_backup_manager
    @database_file = ""
    @application_file = ""
    @time = Time.now.utc.strftime("%Y%m%d%H%M%S")
  end


  #CREATE creates a backup
  def create(comment = ENV['comment'])
    create_backup(comment)
    save_backup_manager
  end

  #DELETE deletes a backup
  def delete(backup_id = ENV['id'])
    raise "id is blank! There was no backup specified for deletion." and return if backup_id == nil
    delete_backup(backup_id)
    save_backup_manager
  end

  #RESTORE restores a backup
  def restore(backup_id = ENV['id'])
    raise "id is blank! There was no backup specified for restoration." and return if backup_id == nil
    restore_backup(backup_id)
    save_backup_manager
  end

  #LIST
  def list
    @backup_manager.list_backups
  end


  private

  # Creates both the application file backup and database backup and moves them
  # to S3.  This method will also update the BackupManager and store it's updated
  # information.
  def create_backup(comment)
    if @conf[:backups][:backup_database]
      @database_file = "#{@time}-#{System.db_credentials['database']}-database.sql"
      print "\nDumping database..."
      database_temp = System.db_dump      
      puts "done\n- Database dump file size: " << database_temp.size.to_s << " B"; print "Backing up database dump file..."
      @adapter.store(@database_file, open(database_temp.path))
      puts "done"
    end
    
    if @conf[:backups][:backup_application_folders].is_a?(Array)
      @application_file = "#{@time}-#{System.db_credentials['database']}-application.tar.gz"
      print "\nZipping application folders..."
      application_temp = System.tarzip_folders(@conf[:backups][:backup_application_folders])
      puts "done\n- Application tarball size: " << application_temp.size.to_s << " B"; print "Backing up application tarball..."
      @adapter.store(@application_file, open(application_temp.path))
      puts "done"
    end

    if @conf[:backups][:max_number_of_backups] == @backup_manager.number_of_backups then
      puts "\nReached max_number_of_backups, removing oldest backup..."
      backup_to_delete = @backup_manager.get_oldest_backup
      delete_backup(backup_to_delete.time)
    end
    backup = Backup.new(@time, @application_file, @database_file, comment)
    @backup_manager.add_backup(backup)
    puts ""
  end

  # Deletes the Backup, application backup files and database files associated
  # with the Backup identified by backup_id.  
  def delete_backup(backup_id)
    backup = @backup_manager.get_backup(backup_id)
    if backup.nil? then
      puts "Backup with ID #{backup_id} does not exist."
      return
    end
    if !backup.application_file.empty?
      begin @adapter.delete(backup.application_file) rescue puts "Could not delete #{backup.application_file}!" end
    end
    if !backup.database_file.empty?
      begin @adapter.delete(backup.database_file) rescue puts "Could not delete #{backup.database_file}!" end
    end
    puts (@backup_manager.delete_backup(backup) ?
        "Backup with ID #{backup.time} was successfully deleted." :
        "Warning: Backup with ID #{backup.time} was not found and therefore not deleted.")
  end

  def restore_backup(backup_id)
    backup = @backup_manager.get_backup(backup_id)
    if backup.nil? then
      puts "Backup with ID #{backup_id} does not exist."
      return
    end
    print "\nRetrieving application tarball..."
    application_file = @adapter.fetch(backup.application_file)
    puts "done"

    print "Restoring application from application tarball..."
    System.unzip_file(application_file)
    puts "done\n"

    print "\nRetrieving database dump_file..."
    dump_file = @adapter.fetch(backup.database_file)
    puts "done";

    print "Restoring database from database dump file..."
    System.load_db_dump(dump_file)
    puts "done\n\n"
  end

  # Loads the config/backup2s3.yml configuration file
  def load_configuration
    @conf = YAML.load_file("#{RAILS_ROOT}/config/backup2s3.yml")
  end

  # Creates instance of class used to interface with S3
  def load_adapter
    begin
      adapter = "#{@conf[:adapter][:type]}".constantize
    rescue
      adapter = S3Adapter
    end
    @adapter = adapter.new(@conf[:adapter])
  end

  def load_backup_manager
    BackupManager.new()
    Backup.new(nil, nil, nil)
    begin
      @backup_manager = YAML.load_file(@adapter.fetch(BackupManager.filename).path)
      @backup_manager ||= YAML.load_file(BackupManager.local_filename)
    rescue
      @backup_manager ||= BackupManager.new
    end
  end

  def save_backup_manager
    begin
      File.open(BackupManager.local_filename, "w") { |f| YAML.dump(@backup_manager, f) }
    rescue
      puts "Unable to save local file: " << BackupManager.local_filename
    end
    begin
      @adapter.store(BackupManager.filename, open(BackupManager.local_filename))
    rescue
      puts "Unable to save BackupManager to S3"
    end
  end 

end
