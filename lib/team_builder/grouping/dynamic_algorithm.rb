module TeamBuilder::Grouping

  class DynamicAlgorithm

    def initialize(features, opts = {})
      @features = features
      @opts = opts
    end

    def group!(applicants)
      container = Utils::BucketContainer.new applicants.to_a, min: min_size, max: max_size

      @features.each do |feature|
        # FIXME: This is only needed until bucketization is implemented for all course feature classes
        if feature.respond_to? :bucketize
          container.bucket_by_feature Utils::BucketizeLogger.new(feature)
        end
      end

      buckets = container.all
      team_id_digits = buckets.count.to_s.length
      i = 0
      buckets.each do |bucket|
        next if bucket.size == 0

        i += 1
        new_team! "Team ##{i.to_s.rjust(team_id_digits, '0')}", bucket.items
      end

      orphan_team!(container.orphans) if container.orphans.size > 0

      teams
    end

    private

    def min_size
      @opts.fetch(:min_size, 3)
    end

    def max_size
      @opts.fetch(:max_size, 8)
    end

    def new_team!(name, members)
      teams << Team.create(name: name, members: members)
    end

    def orphan_team!(orphans)
      Enrollment.where(id: orphans.map(&:id)).update_all team_id: 0
    end

    def teams
      @teams ||= []
    end

  end

end
