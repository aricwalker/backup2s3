
class MysqlAdapter
  include System

  def initialize(db_credentials)
    @db_credentials = db_credentials
  end

  # Creates and runs mysqldump and throws into .tar.gz file.
  # Returns .tar.gz file
  def db_dump
    dump_file = Tempfile.new("dump")
    cmd = "mysqldump --quick --single-transaction --create-options #{db_options}"
    cmd += " > #{dump_file.path}"
    System.run(cmd)
    return dump_file
  end

  def load_db_dump(dump_file)
    cmd = "mysql #{db_options}"
    cmd += " < #{dump_file.path}"
    System.run(cmd)
    true
  end

  private

  def db_options
    cmd = ''
    cmd += " -u #{@db_credentials['username']} " unless @db_credentials['username'].nil?
    cmd += " -p'#{@db_credentials['password']}'" unless @db_credentials['password'].nil?
    cmd += " -h '#{@db_credentials['host']}'"    unless @db_credentials['host'].nil?
    cmd += " #{@db_credentials['database']}"
  end

end