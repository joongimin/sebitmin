module Controllers
  module AwsHelper
    require "aws"

    def create_s3
      # get an instance of the S3 interface using the default configuration
      AWS::S3.new(:access_key_id => Settings.aws_access_key_id, :secret_access_key => Settings.aws_secret_access_key)
    end

    def aws_s3_upload(file_name)
      s3 = create_s3 

      # upload a file
      basename = File.basename(file_name)
      o = s3.buckets[Settings.aws_s3_bucket_name].objects[basename]
      o.write(:file => file_name, :acl => :public_read)

      o
    end

    def aws_s3_delete(key)
      s3 = create_s3
      s3.buckets[Settings.aws_s3_bucket_name].objects[key].delete
    end
  end
end
