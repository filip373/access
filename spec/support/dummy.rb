class Dummy
  def foo_bar_baz(one, two)
    one + two
  end

  def fizz_bazz(object_with_name)
    object_with_name.name
  end

  def namespace
    @namespace ||= :dummy
  end
end
