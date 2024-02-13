module TeamBuilder::Grouping::Utils::Clustering
  class KmeansClustering

    def initialize(k, steps, context, even_cluster_size)
      # K is the amount of clusters that are supposed to be created by this algorithm.
      # Steps is the amount of averaging steps this algortihm uses. Wikipedia recommends 100,
      # but in testing even 10 was enough most of the time
      # context is a variable that is available through out the whole method chain.
      # It only contains all used features so that the distance function can be called correctly later on aswell
      # as configuration details such as min and max size of the resulting teams

      @context = context
      @k = k
      @clusters = Array.new k
      @steps = steps
      @features = context[:features]
      @max_size = context[:max_size]
      @min_size = context[:min_size]
      @even_cluster_size = even_cluster_size
      @members_per_cluster = Hash.new(0)

      Rails.logger.debug { "KMeans Clustering with k:#{k}, steps:#{steps} and features:#{@features} initialized" }
      Rails.logger.debug { "Minsize: #{@min_size}, Maxsize: #{@max_size}" }
    end

    def cluster_participants(start_cluster)
      setup_clustering start_cluster
      (@steps).times do |step|
        cluster step
      end
      Rails.logger.debug { "Created #{@clusters.length} clusters with sizes: #{@clusters.map(&:size)}" }
      @clusters
    end

    def setup_clustering(cluster)
      @clusters = Array.new (@k) { Cluster.new (@context) }
      @items = cluster.items.dup
      @items.each_with_index do |item, index|
        add_item_to_cluster item, @clusters[index % @k]
      end
      @maximum = (cluster.size / @k.to_f).ceil
    end

    def cluster(step)
      Rails.logger.debug { "Running cluster step #{step}" }
      cluster_step @items
      Rails.logger.debug { "Clustersizes are: #{@clusters.map(&:size)}" }
      # If the algorithm produces any empty clusters we fill them with a heuristic (this is not default kmeans procedure)
      fill_empty_clusters
    end

    def cluster_step(items)
      @members_per_cluster = Hash.new(0)
      items.each do |item|
        calculate_distances_for item
        selected_cluster = select_cluster_for item
        add_item_to_cluster item, selected_cluster
      end
    end

    def fill_empty_clusters
      Rails.logger.debug { "There were empty clusters filling them with new pivots" } if empty_clusters.any?
      # Any empty clusters after this step get filled with a pivot element and then another clusterstep is run
      empty_clusters.each_with_index do |cluster, number|
        Rails.logger.debug { "Filling empty cluster #{number} with new pivot" }
        # Pivot elements are the ones currently the furthest away from their cluster.
        # This has the effect of hopefully splitting the original cluster roughly evenly and creating more balanced clusters.
        pivot_item = @items.max_by { |a| a.distance_to_current_cluster }
        # Moving the pivot item to the empty cluster
        add_item_to_cluster pivot_item, cluster
        # Clustering every other item  again.
        # Note the - [pivot_item] as a cluster with only one element the element itself will always have distance Infinity.
        cluster_step @items - [pivot_item]
      end
    end

    def calculate_distances_for(item)
      item.distances_to_cluster = Hash.new
      @clusters.each do |cluster|
        if cluster.items_length_without(item) == 0
          item.distances_to_cluster[cluster] = 1.0 / 0.0
        else
          item.distances_to_cluster[cluster] = @features.calculate_distance item.value, cluster.value_without(item)
        end
      end
    end

    def select_cluster_for(item)
      closest_clusters = item.distances_to_cluster.sort_by { |key, value| value }.to_h.keys
      selected_cluster = closest_clusters.first
      if @even_cluster_size
        i = 1
        while @members_per_cluster[selected_cluster] >= @maximum do
          selected_cluster = closest_clusters[i]
          i += 1
        end
      end
      selected_cluster
    end

    def add_item_to_cluster(item, cluster)
      item.current_cluster.remove_item item unless item.current_cluster.nil? # at the start the current_cluster will be nil
      item.current_cluster = cluster
      cluster.add_item item
      item.distance_to_current_cluster = item.distances_to_cluster[cluster]
      @members_per_cluster[cluster] += 1
    end

    def empty_clusters
      @clusters.select { |cluster| cluster.size == 0 }
    end

  end
end
