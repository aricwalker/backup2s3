require 'tempfile'
require 'yaml'

module System

  def self.hostname
    `hostname`.to_str.gsub!("\n", "")
  end

  def self.db_credentials
    db_config = YAML.load_file("#{Rails.root.to_s}/config/database.yml")
    db_config[Rails.env]
  end

  # Run system commands
  def self.run(command)
    result = system(command)
    raise("error, process exited with status #{$?.exitstatus}") unless result
  end

  # Creates app tar file
  def self.tarzip_folders(folders)
    application_tar = Tempfile.new("app")
    ex_folders = ''
    folders.each { |folder|
      unless File.exist?(folder)
        print "\nWARNING: Folder \'" + folder + "\' does not exist! Excluding from backup."
      else
        ex_folders << folder << ' '
      end
    }
    if ex_folders.length > 0
      cmd = "tar --dereference -czpf #{application_tar.path} #{ex_folders}"
      run(cmd)
    end
    return application_tar
  end

  def self.unzip_file(tarball)
    cmd = "tar xpf #{tarball.path}"
    run(cmd)
  end

  def self.clean(str)
    str.gsub!(".", "-dot-")
    str.gsub!("_", "-")
    str.gsub!("\n", "")
    str.gsub!(/[^0-9a-z\-_]/i, '')
    return str
  end

end

