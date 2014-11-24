require 'aws-sdk'

class S3Adapter
  include System

  DEFAULT_REGION = 'us-east-1'

  def initialize(config)
    @config = config
    @connected = false
    @client = nil
  end

  def ensure_connected
    return if @connected
    credentials = Aws::Credentials.new(@config[:access_key_id], @config[:secret_access_key])
    @client = Aws::S3::Client.new(credentials: credentials,
      region: (@config[:secret_access_key] || DEFAULT_REGION))

    begin
      response = @client.create_bucket(acl: "private", bucket: bucket)
      @connected = true
    rescue Errors::BucketAlreadyExists => e
      puts "Bucket name is already taken -- #{e}"
      @connected = false
    rescue Exception => e
      puts "Unable to create bucket -- #{e}"
      @connected = false
    end
  end

  def store(file_name, file)
    ensure_connected
    @client.put_object(bucket: bucket, key: file_name, body: file)
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
  def bucket
    @bucket ||= System.clean("#{System.db_credentials['database'].downcase}-ON-#{System.hostname.downcase}")
  end

end


