require 'aws-sdk'

class AwsAdapter
  include System

  DEFAULT_REGION = 'us-east-1'

  def initialize(config)
    @config = config
    @connected = false
    @client = nil
  end

  def ensure_connected
    return if @connected
    @client = AWS::S3.new(:access_key_id => @config[:access_key_id],
      :secret_access_key => @config[:secret_access_key])

    begin
      create_bucket
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
    @client.get_object(bucket: bucket, key: file_name, response_target: file.path)
    return file
  end

  def read(file_name)
    ensure_connected
    return @client.head_object(bucket: bucket, key: file_name)
  end

  def list
    ensure_connected
    return @client.list_objects(bucket: bucket).data.contents.collect { |x| x.key }
  end

  def delete(file_name)
    ensure_connected
    @client.delete_object(bucket: bucket, key: file_name)
  end

  private

  # TODO move to abstract class
  def create_bucket
    if @bucket.nil?
      bucket_name = System.clean("#{System.db_credentials['database'].downcase}-ON-#{System.hostname.downcase}")
      @bucket = @client.buckets[bucket_name]
      @bucket = @client.buckets.create(bucket_name) if !@bucket.exists?
    end
    @bucket
  end

end


