module TeamBuilder::Grouping::Utils::Clustering

  class Cluster
    def initialize(items = [], context)
      @context = context
      @items = items
      value.add_value_of items.map(&:content) unless items.empty?
    end

    def add_item(item)
      @items.append item
      value.add_value_of [item.content]
    end

    def remove_item(item)
      @items.delete item
      @value.remove_value_of item.content
    end

    def items
      @items
    end

    def context
      @context
    end

    def value_without (item)
      # deep cloning the value so that the remove operation doesn't alter the value itself
      new_value =  Marshal.load(Marshal.dump(value))
      new_value.remove_value_of(item.content) if @items.include? item
      new_value
    end

    def items_length_without (item)
      return @items.length - 1 if(@items.include? item)
      @items.length
    end

    def self.merge_cluster(cluster1,cluster2)
      Cluster.new(cluster1.items + cluster2.items, cluster1.context)
    end

    def value
      @value ||= Value.new(@context)
    end

    def size
      @items.length
    end

    def to_s
      string = "Clustersize: #{items.size} \n"
      string += "Items: \n"
      items.each do |item|
        string += item.to_s + "\n"
      end
      string += "Value:\n"

      value.raw_values.each do |k,v|
        string+= v.to_s
      end
      string
    end
  end
end
