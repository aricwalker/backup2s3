require 'aws-sdk'

class AwsAdapter
  include System

  DEFAULT_REGION = 'us-east-1'

  def initialize(config)
    @config = config
    @connected = false
    @bucket = nil
  end

  def ensure_connected
    return if @connected
    client = AWS::S3.new(:access_key_id => @config[:access_key_id],
      :secret_access_key => @config[:secret_access_key])

    begin
      create_bucket(client)
      @connected = true
    rescue Exception => e
      puts "Unable to create bucket -- #{e}"
      @connected = false
    end
  end

  def store(file_name, file)
    ensure_connected
    bucket_object = @bucket.objects[file_name]
    bucket_object.write(Pathname.new(file.path))
  end

  def fetch(file_name)
    ensure_connected
    file = Tempfile.new("temp")
    bucket_object = @bucket.objects[file_name]

    File.open(file.path, 'wb') do |f|
      bucket_object.read do |chunk|
        f.write chunk
      end
    end
    return file
  end

  def delete(file_name)
    ensure_connected
    @bucket.objects[file_name].delete
  end

  private

  # TODO move to abstract class
  def create_bucket(client)
    if @bucket.nil?
      bucket_name = System.clean("#{System.db_credentials['database'].downcase}-ON-#{System.hostname.downcase}")
      @bucket = client.buckets[bucket_name]
      @bucket = client.buckets.create(bucket_name) if !@bucket.exists?
    end
    @bucket
  end

end


