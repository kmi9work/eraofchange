class RobberyService
  ROBBERY_SUCCESS = :robbery_success
  ROBBERY_FAILURE = :robbery_failure
  NO_ROBBERY      = :no_robbery

  # Новый подход к грабежу караванов.
  # В начале года мы указываем сколько попыток ограблений совершит вятка - max_attempts (дальше не меняем)
  # Число оставшихся попыток remained_attempts = max_attempts в начале
  # Вероятность ограбления = remained_attempts / total_caravans  * 100
  # Если караван защищен - попытка потрачена впустую
  # Если не защищен - караван ограблен
  #
  # Этод метод вычисляет только лишь попытку ограбления караван

  def self.attempt_robbery(current_year, guild_id:, force_protected: false)
      new(current_year, guild_id).attempt_robbery(force_protected: force_protected)
  end

  def self.robbery_probability_status(current_year, guild_id:)
      new(current_year, guild_id).robbery_probability_status
  end

  def initialize(current_year, guild_id)
    @current_year = current_year
    @guild_id = guild_id
  end

  def attempt_robbery(force_protected: false)
    return NO_ROBBERY if remained_caravans <= 0
    return NO_ROBBERY unless rand < robbery_probability
    consume_robbery_attempt
    return ROBBERY_FAILURE if guild_protected? || force_protected
    ROBBERY_SUCCESS
  end

  def robbery_probability
    [remained_robberies.to_f / remained_caravans, 1.0].min
  end

  def robbery_probability_status
    guild_protected? ? 0 : robbery_probability
  end

  private

  def guild_protected?
    GameParameter.get_protected_guilds_for_year(@current_year).include?(@guild_id.to_i)
  end

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
