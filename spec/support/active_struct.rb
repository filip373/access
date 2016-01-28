# implements attributes method for open struct
class ActiveStruct < OpenStruct
  def attributes
    to_h
  end
end
