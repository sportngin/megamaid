require 'aws-sdk'

module Megamaid

  class AwsParams
    def self.basic
      {
          region: GlobalConfig.region,
          profile: GlobalConfig.profile
      }
    end
  end

  module AwsClients
    extend self

    def ec2
      @ec2 ||= Aws::EC2::Client.new(AwsParams.basic)
    end

    def iam
      @iam ||= Aws::IAM::Client.new(AwsParams.basic)
    end

    def opsworks
      @opsworks ||= Aws::OpsWorks::Client.new(AwsParams.basic)
    end
  end

end
