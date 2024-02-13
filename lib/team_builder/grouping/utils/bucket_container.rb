module TeamBuilder::Grouping::Utils

  class BucketContainer

    def initialize(items = [], size_options = {})
      @buckets = [Bucket.new(items)]
      @size_options = size_options
      @orphans = []
      @all = []
    end

    attr_reader :orphans

    def bucket_by_feature(feature)
      handle_buckets do |bucket|
        feature.bucketize bucket
      end
    end

    def all
      # We're done, split up the remaining buckets
      if @buckets.size > 0
        @buckets.each do |bucket|
          splits, rest = bucket.split(@size_options)
          @all.concat splits
          @orphans.concat rest
        end
      end

      # TODO: Go through the orphans and try to match them to existing buckets
      @all
    end

    private

    def handle_buckets(&block)
      return if @buckets.empty?

      split_buckets = @buckets.map{ |bucket|
        block.call bucket.items
      }.flatten(1).map{ |group|
        Bucket.new group
      }

      @buckets = []
      split_buckets.each do |bucket|
        if bucket.size == 1
          orphanize! bucket
        elsif bucket.size >= 2 * min_size
          keep_bucketing! bucket
        else
          finished! bucket
        end
      end
    end

    def orphanize!(bucket)
      @orphans.concat bucket.items
    end

    def finished!(bucket)
      @all << bucket
    end

    def keep_bucketing!(bucket)
      @buckets << bucket
    end

    def min_size
      @size_options.fetch :min
    end

    def max_size
      @size_options.fetch :max
    end

  end

end
