class RobberyService

  # Новый подход к грабежу караванов.
  # В начале года мы указываем сколько попыток ограблений совершит вятка - max_attempts (дальше не меняем)
  # Число оставшихся попыток remained_attempts = max_attempts в начале
  # Вероятность ограбления = remained_attempts / total_caravans  * 100
  # Если караван защищен - попытка потрачена впустую
  # Если не защищен - караван ограблен
  #
  # Этод метод вычисляет только лишь попытку ограбления караван

  def self.attempt_robbery(current_year)
      new(current_year).attempt_robbery
  end

  def self.robbery_probability_status(current_year)
      new(current_year).robbery_probability
  end

  def initialize(current_year)
    @current_year = current_year
  end

  def attempt_robbery
    return false if remained_caravans <= 0
    attempt = rand < robbery_probability
    consume_robbery_attempt if attempt
    attempt
  end

  def robbery_probability
    remained_robberies.to_f / remained_caravans
  end

  private

  def consume_robbery_attempt
    GameParameter.decrement_robbery_count_for_year(@current_year)
  end

  def remained_robberies
    GameParameter.get_robbery_count_for_year(@current_year).to_i
  end

  def remained_caravans
    total_caravans - arrived_caravans
  end

  def total_caravans
    Guild.total_count * GameParameter.get_caravans_per_guild
  end

  def arrived_caravans
    GameParameter.get_arrived_count_for_year(@current_year)
  end
end
