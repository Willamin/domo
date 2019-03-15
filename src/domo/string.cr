class String
  def type?
    self[0].uppercase?
  end

  def member?
    self[0].lowercase?
  end

  def symbol?
    access? || or? || declaration?
  end

  def access?
    self == "."
  end

  def or?
    self == "|"
  end

  def declaration?
    self == ":"
  end
end
