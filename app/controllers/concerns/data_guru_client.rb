module DataGuruClient
  extend ActiveSupport::Concern

  def data_guru
    DataGuru::Client.new
  end
end
