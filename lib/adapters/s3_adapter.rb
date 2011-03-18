require 'aws/s3'


class S3Adapter
  include System

  def initialize(config)
    @config = config
    @connected = false
  end

  def ensure_connected
    return if @connected    
    AWS::S3::Base.establish_connection!(
      :access_key_id     => @config[:access_key_id],
      :secret_access_key => @config[:secret_access_key],      
      :use_ssl           => @config[:use_ssl]      
    )
    AWS::S3::Bucket.create(bucket)
    @connected = true
  end

  def store(file_name, file)
    ensure_connected
    AWS::S3::S3Object.store(file_name, file, bucket)
  end

  def fetch(file_name)
    ensure_connected
    AWS::S3::S3Object.find(file_name, bucket)

    file = Tempfile.new("temp")
    open(file.path, 'w') do |f|
      AWS::S3::S3Object.stream(file_name, bucket) do |chunk|
        f.write chunk
      end
    end
    file
  end

  def read(file_name)    
    ensure_connected
    return AWS::S3::S3Object.find(file_name, bucket)
  end

  def list
    ensure_connected
    AWS::S3::Bucket.find(bucket).objects.collect {|x| x.path }
  end

  def delete(file_name)
    if object = AWS::S3::S3Object.find(file_name, bucket)
      object.delete
    end
  end

  private

  def bucket    
    @bucket ||= clean("#{System.db_credentials['database'].downcase}-ON-#{System.hostname.downcase}")
  end

  def clean(str)
    str.gsub!(".", "-dot-")
    str.gsub!("_", "-")
    str.gsub!("\n", "")
    return str
  end
  
end


