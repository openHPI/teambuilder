module TeamBuilder::Grouping::Utils
  class Item
    # this class is only a data container for managing enrollments, distances between enrollments and their value class during clustering.
    def initialize(content, id, context)
      @content = content
      @id = id
      @context = context
      @distances_to_cluster = Hash.new(0)
      value.add_value_of [content]
    end

    def to_s
      "Item: #{@id.to_s} \n Value: #{value.raw_values}"
    end

    def inspect
      to_s
    end

    def ==(other_item)
      @id == other_item.id
    end

    def distances_to_cluster
      @distances_to_cluster
    end

    def distances_to_cluster=(dtc)
      @distances_to_cluster = dtc
    end

    def distance_to_current_cluster=(dtcc)
      @distances_to_current_cluster = dtcc
    end

    def distance_to_current_cluster
      @distances_to_current_cluster ||= 0
    end

    def current_cluster
      @current_cluster
    end

    def current_cluster=(cluster)
      @current_cluster = cluster
    end

    def content=(content)
      @content = content
    end

    def content
      @content
    end

    def id=(id)
      @id = id
    end

    def value=(values)
      @value = values
    end

    def value
      @value||= Clustering::Value.new(@context)
    end

    def id
      @id
    end

    def distances=(distances)
      @distances=distances
    end

    def distances
      @distances||=[]
    end
  end
end
