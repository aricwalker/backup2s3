
class Adapters::S3cmdAdapter
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

#  def read(file_name)
#    ensure_connected
#    return AWS::S3::S3Object.find(file_name, bucket)
#  end

#  def list
#    ensure_connected
#    AWS::S3::Bucket.find(bucket).objects.collect {|x| x.path }
#  end

  def delete(file_name)
    System.run("s3cmd del s3://#{bucket}/#{file_name}")
  end

  private

  def bucket
    @bucket ||= clean("#{ActiveRecord::Base.connection.current_database.to_str.downcase}-ON-#{System.hostname.downcase}")
  end

  def clean(str)
    str.gsub!(".", "-dot-")
    str.gsub!("_", "-")
    str.gsub!("\n", "")
    return str
  end

end


