class PostgresqlAdapter
  include System

  def initialize(db_credentials)
    @db_credentials = db_credentials
  end

  # Creates and runs pg_dump and throws into .tar.gz file.
  # Returns .tar.gz file
  def db_dump
    dump_file = Tempfile.new("dump")
    username = @db_credentials['username']
    password = @db_credentials['password']
    database = @db_credentials['database']
    cmd = "PGPASSWORD=\"#{password}\" PGUSER=\"#{username}\" pg_dump -Ft #{database} > #{dump_file.path}"
    System.run(cmd)
    dump_file
  end

  def load_db_dump(dump_file)
    database = @db_credentials['database']
    host = @db_credentials['host'] || 'localhost'
    superuser = System.prompt "Postgres superuser: "
    su_password = System.prompt "#{superuser} password: "
    cmd = "PGPASSWORD=\"#{su_password}\" && PGUSER=\"#{superuser}\"; " +
      "dropdb --host #{host} #{database}; " +
      "createdb --host #{host} -T template0 #{database}; " +
      "pg_restore --host #{host} -Ft --dbname=#{database} #{dump_file.path}"
    System.run(cmd)
  end

end

