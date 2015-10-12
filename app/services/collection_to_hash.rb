class CollectionToHash
  def self.call(items)
    items_hash(items)
  end

  def self.items_hash(items)
    items.each_with_object({}) { |item, hash| hash[item.name] = item.to_h.except(:name) }
  end
  private_class_method :items_hash
end
