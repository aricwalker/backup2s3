
class PostgresqlAdapter
  include System

  def initialize(db_credentials)
    @db_credentials = db_credentials
  end

  # Creates and runs mysqldump and throws into .tar.gz file.
  # Returns .tar.gz file
  def db_dump
    dump_file = Tempfile.new("dump")
    cmd = "PGPASSWORD=\"#{@db_credentials['password']}\" pg_dump #{db_options} -f #{dump_file.path}"
    puts "RUNNING: #{cmd}"
    System.run(cmd)
    return dump_file
  end

  def load_db_dump(dump_file)
    cmd = "psql #{db_options} -f #{dump_file.path}"
    puts "RUNNING: #{cmd}"
    System.run(cmd)
    true
  end

  private

  def db_options
    cmd = ''
    cmd += " -U #{@db_credentials['username']} " unless @db_credentials['username'].nil?
    cmd += " -h #{@db_credentials['host'] || 'localhost'} "
    cmd += " #{@db_credentials['database']}"
  end
end