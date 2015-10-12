class BaseDiff
  attr_reader :collection, :other_collection, :remove_hash, :add_hash

  def initialize(collection, other_collection)
    @collection = CollectionToHash.call(collection)
    @other_collection = CollectionToHash.call(other_collection)
  end

  def diff!
    @remove_hash, @add_hash = collection.easy_diff(other_collection)
  end
end
