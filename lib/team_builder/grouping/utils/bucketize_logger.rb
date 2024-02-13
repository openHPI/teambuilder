module TeamBuilder::Grouping::Utils

  class BucketizeLogger

    def initialize(feature)
      @feature = feature
    end

    def bucketize(bucket)
      Rails.logger.info "Bucketize by #{@feature.type} (n = #{bucket.size})"
      result = @feature.bucketize bucket
      Rails.logger.info "Created #{result.length} buckets [#{result.map(&:size) * ','}]"

      result
    end

  end

end
