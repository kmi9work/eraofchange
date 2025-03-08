module Dictionary

  def look_up_res(identificator)
    return Resource.find_by(identificator: identificator).name
  end

end