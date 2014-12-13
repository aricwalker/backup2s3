class PostgresqlAdapter
  include System

  def initialize(db_credentials)
    @db_credentials = db_credentials
  end

  # Creates and runs pg_dump and throws into .tar.gz file.
  # Returns .tar.gz file
  def db_dump
    dump_file = Tempfile.new("dump")
    password = @db_credentials['password']
    database = @db_credentials['database']
    cmd = "PGPASSWORD=\"#{password}\" pg_dump #{db_options} --verbose -Ft #{database} > #{dump_file.path}"
    print "Running '#{cmd}'"
    System.run(cmd)
    dump_file
  end

  def load_db_dump(dump_file)
    database = @db_credentials['database']
    superuser = System.prompt "Postgres superuser: "
    su_password = System.prompt "#{superuser} password: "
    cmd = "PGPASSWORD=\"#{su_password}\" && PGUSER=\"#{superuser}\"; " +
      "dropdb --host localhost #{database}; " +
      "createdb --host localhost -T template0 #{database} "
    puts "RUNNING #{cmd}"
    System.run(cmd)

    cmd = "pg_restore --host localhost --verbose -Ft --dbname=#{database} #{dump_file.path}"
    puts "RUNNING #{cmd}"
    System.run(cmd)
    true
  end

  private

  def db_options
    cmd = ''
    cmd += " --username #{@db_credentials['username']} " unless @db_credentials['username'].nil?
    cmd += " --host #{@db_credentials['host'] || 'localhost'} "
  end

end

