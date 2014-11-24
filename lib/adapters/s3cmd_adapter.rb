
class S3cmdAdapter
  include System

  def initialize(config)
    @config = config
    @connected = false
  end

  def ensure_connected
    return if @connected
    System.run("s3cmd mb s3://#{bucket}")
    @connected = true
  end

  def store(file_name, file)
    ensure_connected
    System.run("s3cmd put #{file.path} s3://#{bucket}/#{file_name}")
  end

  def fetch(file_name)
    ensure_connected
    file = Tempfile.new("temp")
    System.run("s3cmd get --force s3://#{bucket}/#{file_name} #{file.path}")
    file
  end

  def delete(file_name)
    #TODO use s3cmd ls here to create 'find' like functionality similar to s3_adapter
    begin
      System.run("s3cmd del s3://#{bucket}/#{file_name}")
    rescue
      raise "Could not delete #{file_name}."
    end
  end

  private

  # TODO move to abstract class
  def bucket
    @bucket ||= System.clean("#{System.db_credentials['database'].downcase}-ON-#{System.hostname.downcase}")
  end

end


