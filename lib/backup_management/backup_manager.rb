require 'yaml'

class BackupManager
  include System

  attr_accessor :backup_list_filename, :backups


  def initialize
    self.backups = Array.new
  end

  def self.filename
    System.clean("#{System.db_credentials['database']}_ON_#{System.hostname}_backups") << ".yaml"
  end

  def self.local_filename
    "#{Rails.root.to_s}/lib/#{filename}"
  end

  def add_backup(backup)
    self.backups << backup
  end

  def delete_backup(backup)
    self.backups.delete(backup)
  end

  def delete_backup_by_id(backup_id)
    self.backups.each { |backup|
      if backup.time == backup_id then
        self.backups.delete(backup)
      end
    }
    nil
  end

  def get_oldest_backup
    self.backups.sort{|a,b| b.time <=> a.time}.last
  end

  def get_backup(backup_id)
    self.backups.each { |backup|
      if backup.time == backup_id then
        return backup
      end
    }
    nil
  end

  def list_backups(details = ENV['details'])
    puts "\n--- Backups by Date ---"
    count = 1
    self.backups.sort{|a,b| b.time <=> a.time}.each do |backup|
      puts "#{count}. #{backup.human_readable_time}, ID - #{backup.time}"
      if details then
        puts "   --- App -> #{backup.application_file}"
        puts "   --- DB -> #{backup.database_file}"
        puts "   --- Comment -> #{backup.comment}"
      end
      count = count.next
    end
    puts "-----------------------\n\n"
  end

  def number_of_backups
    backups.size
  end

end
