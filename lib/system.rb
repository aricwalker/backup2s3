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
    if folders.is_a?(Array)      
      cmd = "tar --dereference -czpf #{application_tar.path} #{folders.join(" ")}"
    elsif folders.is_a?(String)
      cmd = "tar --dereference -czpf #{application_tar.path} #{folders}"
    end
    run(cmd)
    return application_tar
  end

  def self.unzip_file(tarball)
    cmd = "tar xpf #{tarball.path}"
    run(cmd)
  end

  # Creates and runs mysqldump and throws into .tar.gz file.
  # Returns .tar.gz file
  def self.db_dump
    dump_file = Tempfile.new("dump")
    cmd = "mysqldump --quick --single-transaction --create-options #{mysql_options}"
    cmd += " > #{dump_file.path}"
    run(cmd)
    return dump_file
  end

  def self.load_db_dump(dump_file)
    cmd = "mysql #{mysql_options}"
    cmd += " < #{dump_file.path}"
    run(cmd)
    true
  end

  def self.mysql_options
    cmd = ''
    cmd += " -u #{db_credentials['username']} " unless db_credentials['username'].nil?
    cmd += " -p'#{db_credentials['password']}'" unless db_credentials['password'].nil?
    cmd += " -h '#{db_credentials['host']}'"    unless db_credentials['host'].nil?
    cmd += " #{db_credentials['database']}"
  end  
  
  def self.clean(str)
    str.gsub!(".", "-dot-")
    str.gsub!("_", "-")
    str.gsub!("\n", "")
    str.gsub!(/[^0-9a-z\-_]/i, '')
    return str
  end
    
end

