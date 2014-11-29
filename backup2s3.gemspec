Gem::Specification.new do |spec|
  spec.name          = "backup2s3"
  spec.version       = "0.4.0"
  spec.authors       = ["Aric Walker"]
  spec.email         = ["aric.walker@gmail.com"]
  spec.description   = "Backup2s3 is a gem that performs database and application backups and stores the data on Amazon S3."
  spec.summary       = "Backup2s3"
  spec.files         = [
    "lib/backup2s3.rb",
    "lib/system.rb",
    "lib/adapters/s3_adapter.rb",
    "lib/adapters/s3cmd_adapter.rb",
    "lib/backup_management/backup.rb",
    "lib/backup_management/backup_manager.rb",
    "lib/generators/backup2s3/backup2s3_generator.rb",
    "lib/generators/backup2s3/templates/backup2s3.rake",
    "lib/generators/backup2s3/templates/backup2s3.yml"
  ]
  spec.homepage      = 'http://rubygems.org/gems/backup2s3'
  spec.license       = "MIT"

  spec.add_runtime_dependency 'aws-sdk', '~> 2.0.10.pre'
end
