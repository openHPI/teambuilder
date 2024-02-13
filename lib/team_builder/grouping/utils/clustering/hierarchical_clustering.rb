module TeamBuilder::Grouping::Utils::Clustering
  class HierarchicalClustering

    def initialize(context)
      @max_size = context[:max_size]
      @min_size = context[:min_size]
      @context = context
    end

    def cluster_participants(applicants_cluster)
      # applicant_cluster is the starting cluster with all applicants that should be put into teams.
      # context is a variable that is available through out the whole method chain.
      # It only contains all used features so that the distance function can be called correctly later on.
      # The algorithm stops when all clusters have reached the minimum teamsize or only one cluster is left (this should probably be orphans?)
      items = applicants_cluster.items
      clusters = Array.new

      # Creating a cluster for each item
      items.each_with_index do |applicant|
        clusters << Cluster.new([applicant], @context)
      end

      # Container for all finished clusters
      finished_clusters = Array.new

      # aslong as there are still clusters to process:
      while clusters.length > 0 do
        clusters.each do |c|
          # If a cluster has reached the maximum team size it is a complete team.
          if c.items.length == @max_size
            finished_clusters << c
            clusters.delete c
          end
        end
        # Do a cluster step if more than one cluster are left.
        if clusters.length >1
          clusters = cluster_step clusters, @context[:features]
        end
        # If only one cluster is left or the algorithm determines that it can't cluster any further (see below in function cluster_step).
        # The remaining clusters are also added to the list of finished teams.
        if clusters.length == 1
          finished_clusters << clusters[0]
          clusters.delete clusters[0]
        end
      end

      finished_clusters.flatten
    end

    def cluster_step(clusters, features)
      # Calculating the distance between every cluster and saving them in a hash that's basically a twodimensional array
      clusterdistances = Hash.new
      clusters.each_with_index do |x_cluster, x|
        clusters.drop(x+1).each_with_index do |y_cluster, y|
          distance = features.calculate_distance x_cluster.value, y_cluster.value
          clusterdistances[[x,y+x+1]] = distance
        end
      end
      # sorting the hash by distance so that the shortest distance is first
      mindistances = clusterdistances.sort_by{|cluster,distance| distance}
      mindistances.each_with_index do |(k,v), index|
        # mergin cluster x and y on trial
        x_cluster = clusters[k[0]]
        y_cluster = clusters[k[1]]
        merge_cluster = Cluster.merge_cluster x_cluster, y_cluster
        # Checking if the resulting cluster is too big
        if (merge_cluster.items.length > @max_size)
          # If there are others to process then do that and try with the next closest distance
          if(index<mindistances.length-1)
            next
          else
            # If there are no other possibilities left to merge clusters. Return the remaining clusters as an array element.
            # The upper method will handle it as if only one cluster is left and therefore the algorithm is done.
            return [clusters]
          end
        end
        # If the merged cluster is still in range of teamsizes add it to the cluster array and remove the two merged clusters.
        clusters.append merge_cluster
        if (k[0]>k[1])
          clusters.delete_at k[0]
          clusters.delete_at k[1]
        else
          clusters.delete_at k[1]
          clusters.delete_at k[0]
        end
        # Since two clusters were merged this step is over!
        break

      end
      clusters
    end
  end
end

