class Storage
  attr_accessor :dir

  def self.instance
    @@instance ||= new(AppConfig.permissions_repo.checkout_dir)
  end

  def self.data
    instance.data
  end

  def initialize(dir)
    self.dir = dir
  end

  def data
    @data ||= build_tree
  end

  def build_tree
    # http://www.dzone.com/snippets/build-hash-tree-array-file
    # https://gist.github.com/awesome/3842062
    hash = files_list.inject({}) do |hash, path|
      tree = hash
      path_parts = split_path(path)
      path_parts.each_with_index do |part, index|
        tree[part] ||= {}
        if index == (path_parts.size - 1) # last element
          tree[part] = YAML.load_file(path)
        end
        tree = tree[part]
      end
      hash
    end
    Hashie::Mash.new(hash)
  end

  def files_list
    Dir["#{dir}/**/*.yml"]
  end

  def split_path(path)
    path.gsub(dir, "").gsub(".yml", "").split("/").reject(&:empty?)
  end

end
