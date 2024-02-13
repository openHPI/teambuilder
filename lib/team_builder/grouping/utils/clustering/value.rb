module TeamBuilder::Grouping::Utils::Clustering
  class Value
    def initialize(context)
      @context = context
      @values = {}
    end

    def context
      @context
    end

    def raw_values=(values)
      @values=values
    end

    def raw_values
      @values||={}
    end

    def add_value_of(applicants)
      applicants.each do |applicant|
        context[:features].each do |feature|
          (raw_values[feature.name_as_sym]||=[]) << feature.value_of(applicant)
        end
      end
    end

    def remove_value_of(applicant)
      context[:features].each do |feature|
        @values[feature.name_as_sym].delete_at(raw_values[feature.name_as_sym].index(feature.value_of(applicant)))
      end
    end

    def reset
      @values = {}
    end

  end
end
