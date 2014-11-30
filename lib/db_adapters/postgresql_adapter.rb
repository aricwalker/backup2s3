
class PostgresqlAdapter
  include System

  def initialize(db_credentials)
    @db_credentials = db_credentials
  end

  # Creates and runs mysqldump and throws into .tar.gz file.
  # Returns .tar.gz file
  def db_dump
    dump_file = Tempfile.new("dump")
    cmd = "PGPASSWORD=\"#{@db_credentials['password']}\" pg_dump #{db_options} #{@db_credentials['database']} > #{dump_file.path}"
    System.run(cmd)
    dump_file
  end

  def load_db_dump(dump_file)
    cmd = "PGPASSWORD=\"#{@db_credentials['password']}\" pg_restore #{db_options} #{dump_file.path}"
    System.run(cmd)
    true
  end

  private

  def db_options
    cmd = ''
    cmd += " -U #{@db_credentials['username']} " unless @db_credentials['username'].nil?
    cmd += " -h #{@db_credentials['host'] || 'localhost'} "
    cmd += " -Fc "
  end
end