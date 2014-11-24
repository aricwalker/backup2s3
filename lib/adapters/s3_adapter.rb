require 'aws-sdk'

class S3Adapter
  include System

  def initialize(config)
    @config = config
    @connected = false
    @client = nil
  end

  def ensure_connected
    return if @connected
    credentials = Aws::Credentials.new(@config[:access_key_id], @config[:secret_access_key])
    @client = Aws::S3::Client.new(credentials: credentials)
    begin
      @client.create_bucket(acl: "private", bucket: bucket)
      @connected = true
    rescue Errors::BucketAlreadyExists
      @connected = true
    rescue
      @connected = false
    end
  end

  def store(file_name, file)
    ensure_connected
    # AWS::S3::S3Object.store(file_name, file, bucket)
  end

  def fetch(file_name)
    ensure_connected
    # AWS::S3::S3Object.find(file_name, bucket)

    # file = Tempfile.new("temp")
    # open(file.path, 'w') do |f|
    #   AWS::S3::S3Object.stream(file_name, bucket) do |chunk|
    #     f.write chunk
    #   end
    # end
    # file
  end

  def read(file_name)
    ensure_connected
    # return AWS::S3::S3Object.find(file_name, bucket)
  end

  def list
    ensure_connected
    # AWS::S3::Bucket.find(bucket).objects.collect {|x| x.path }
  end

  def delete(file_name)
    ensure_connected
    # if object = AWS::S3::S3Object.find(file_name, bucket)
    #   object.delete
    # end
  end

  private

  # TODO move to abstract class
  def bucket
    @bucket ||= System.clean("#{System.db_credentials['database'].downcase}-ON-#{System.hostname.downcase}")
  end

end


