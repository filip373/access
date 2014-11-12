class YAMLReader
  attr_accessor :file_path, :validation

  def initialize(file_path:, validation:)
    self.file_path = file_path
    self.validation = validation
  end

  def call
    YAML.load_file(file_path)
  rescue Psych::SyntaxError => ex
    validation.add_error(
      clear_local_path(file_path),
      clear_local_path(ex.message)
    )
  end

  private

  def clear_local_path(path)
    path.sub(AppConfig.permissions_repo.checkout_dir + '/', '')
  end
end
