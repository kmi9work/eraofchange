class CaravansController < ApplicationController
  before_action :set_caravan, only: %i[ show edit update destroy ]

  def check_robbery
    # Проверяем вероятность
    # result = Caravan.check_robbery(params[:guild_id])
    probability = RobberyService.robbery_probability_status(
      GameParameter.current_year, 
      guild_id: params[:guild_id].to_i
    )
    render json: { probability: probability}
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end
  
  def check_robbery_with_decide
    # Проверяем вероятность и принимаем решение
    # НЕ инкрементируем счетчики здесь - это будет сделано при регистрации каравана
    result = Caravan.check_robbery_with_decide(params[:guild_id])
    
    render json: result
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  def register_caravan
    result = Caravan.register_caravan(params)
    if result[:success]
      render json: { message: 'Caravan registered successfully', caravan: result[:caravan] }, status: :ok
    elsif result[:robbed]
      render json: { robbed: true, error: result[:error] }, status: :unprocessable_entity
    else
      render json: { error: result[:error] }, status: :unprocessable_entity
    end
  rescue => e
    render json: { error: e.message }, status: :internal_server_error
  end

  # GET /caravans or /caravans.json
  def index
    @caravans = Caravan.all
  end

  # GET /caravans/all.json - получить все караваны для статистики
  def all
    @caravans = Caravan.includes(:guild, :country).order(year: :asc, created_at: :asc)
    respond_to do |format|
      format.json { render :index }
    end
  end

  # GET /caravans/merchant_guilds_stats.json - статистика по гильдиям торговцев (доходы, расходы, cashflow)
  def merchant_guilds_stats
    # Группируем данные по гильдиям и годам
    @stats = calculate_merchant_guilds_stats
    respond_to do |format|
      format.json { render json: @stats }
    end
  end

  # GET /caravans/robbed_caravans_stats.json - статистика по ограбленным караванам
  def robbed_caravans_stats
    @robbed_stats = calculate_robbed_caravans_stats
    respond_to do |format|
      format.json { render json: @robbed_stats }
    end
  end

  # GET /caravans/income_stats.json - статистика по доходам игроков (по годам и по знати)
  def income_stats
    @income_stats = calculate_income_stats
    @summary_stats = calculate_summary_stats
    @troop_payments_stats = calculate_troop_payments_stats
    @troop_purchases_stats = calculate_troop_purchases_stats
    respond_to do |format|
      format.json { render json: { 
        income_stats: @income_stats, 
        summary_stats: @summary_stats,
        troop_payments_stats: @troop_payments_stats,
        troop_purchases_stats: @troop_purchases_stats
      } }
    end
  end

  # GET /caravans/by_country/:country_id.json - получить караваны по стране
  def by_country
    country_id = params[:country_id]
    @caravans = Caravan.includes(:guild, :country)
                       .where(country_id: country_id)
                       .order(year: :desc, created_at: :desc)
    respond_to do |format|
      format.json { render :index }
    end
  end

  # GET /caravans/1 or /caravans/1.json
  def show
  end

  # GET /caravans/new
  def new
    @caravan = Caravan.new
  end

  # GET /caravans/1/edit
  def edit
  end

  # POST /caravans or /caravans.json
  def create
    @caravan = Caravan.new(caravan_params)

    respond_to do |format|
      if @caravan.save
        format.html { redirect_to caravan_url(@caravan), notice: "Caravan was successfully created." }
        format.json { render :show, status: :created, location: @caravan }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @caravan.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /caravans/1 or /caravans/1.json
  def update
    respond_to do |format|
      if @caravan.update(caravan_params)
        format.html { redirect_to caravan_url(@caravan), notice: "Caravan was successfully updated." }
        format.json { render :show, status: :ok, location: @caravan }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @caravan.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /caravans/1 or /caravans/1.json
  def destroy
    @caravan.destroy

    respond_to do |format|
      format.html { redirect_to caravans_url, notice: "Caravan was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_caravan
      @caravan = Caravan.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def caravan_params
      params.require(:caravan).permit(
        :country_id,
        :guild_id,
        :year,
        :gold_export,
        :gold_import,
        :via_vyatka,
        resources_export: {},
        resources_import: {}
      )
    end
    
    # def register_caravan_params
    #   params.permit(:country_id, :purchase_cost, :sale_income, :gold_paid, incoming: [:identificator, :name, :count, :price], outcoming: [:identificator, :name, :count, :price])
    # end

    private

    # Calculate merchant guilds trade statistics
    def calculate_merchant_guilds_stats
      # Исключаем ограбленные караваны из статистики
      caravans = Caravan.includes(:guild).where(is_robbed: false)
      
      # Group by guild and year
      stats_hash = {}
      
      caravans.each do |caravan|
        guild_name = caravan.guild&.name || 'Неизвестная гильдия'
        year = caravan.year
        
        key = "#{guild_name}_#{year}"
        
        unless stats_hash.key?(key)
          stats_hash[key] = {
            guild_name: guild_name,
            year: year,
            total_income: 0,
            total_expense: 0,
            net_cashflow: 0
          }
        end
        
        # Add income (gold_import - деньги полученные от продажи)
        income = caravan.gold_import.to_i || 0
        stats_hash[key][:total_income] += income
        
        # Add expense (gold_export - деньги потраченные на покупку)
        expense = caravan.gold_export.to_i || 0
        stats_hash[key][:total_expense] += expense
        
        # Update net cashflow
        stats_hash[key][:net_cashflow] = stats_hash[key][:total_income] - stats_hash[key][:total_expense]
      end
      
      # Convert to array and sort by year and guild name
      stats_array = stats_hash.values.sort_by { |s| [s[:year], s[:guild_name]] }
      
      # Add totals
      totals_by_year = {}
      stats_array.each do |stat|
        year = stat[:year]
        unless totals_by_year.key?(year)
          totals_by_year[year] = {
            year: year,
            total_income: 0,
            total_expense: 0,
            net_cashflow: 0
          }
        end
        totals_by_year[year][:total_income] += stat[:total_income]
        totals_by_year[year][:total_expense] += stat[:total_expense]
        totals_by_year[year][:net_cashflow] += stat[:net_cashflow]
      end
      
      {
        by_guild_and_year: stats_array,
        totals_by_year: totals_by_year.values.sort_by { |t| t[:year] },
        overall_totals: {
          total_income: stats_array.sum { |s| s[:total_income] },
          total_expense: stats_array.sum { |s| s[:total_expense] },
          net_cashflow: stats_array.sum { |s| s[:net_cashflow] }
        }
      }
    end

    # Calculate robbed caravans statistics
    def calculate_robbed_caravans_stats
      # Получаем только ограбленные караваны
      robbed_caravans = Caravan.includes(:guild, :country).where(is_robbed: true)
      
      # Группируем по годам и гильдиям
      stats_hash = {}
      
      robbed_caravans.each do |caravan|
        guild_name = caravan.guild&.name || 'Неизвестная гильдия'
        country_name = caravan.country&.name || 'Неизвестная страна'
        year = caravan.year
        
        key = "#{year}_#{guild_name}"
        
        unless stats_hash.key?(key)
          stats_hash[key] = {
            year: year,
            guild_name: guild_name,
            country_name: country_name,
            total_lost_gold: 0,
            caravans_count: 0,
            caravans: []
          }
        end
        
        # Считаем потерянное золото (gold_export + gold_import)
        lost_gold = (caravan.gold_export.to_i || 0) + (caravan.gold_import.to_i || 0)
        stats_hash[key][:total_lost_gold] += lost_gold
        stats_hash[key][:caravans_count] += 1
        
        # Добавляем информацию о караване
        stats_hash[key][:caravans] << {
          id: caravan.id,
          year: caravan.year,
          guild_name: guild_name,
          country_name: country_name,
          gold_export: caravan.gold_export.to_i,
          gold_import: caravan.gold_import.to_i,
          total_lost: lost_gold,
          created_at: caravan.created_at
        }
      end
      
      # Конвертируем в массив и сортируем по году и гильдии
      stats_array = stats_hash.values.sort_by { |s| [s[:year], s[:guild_name]] }
      
      # Общие итоги
      overall_total_lost = robbed_caravans.sum { |c| (c.gold_export.to_i || 0) + (c.gold_import.to_i || 0) }
      
      {
        by_year_and_guild: stats_array,
        total_robbed_caravans: robbed_caravans.count,
        total_lost_gold: overall_total_lost,
        caravans: robbed_caravans.order(created_at: :desc).map do |c|
          {
            id: c.id,
            year: c.year,
            guild_name: c.guild&.name || 'Неизвестная гильдия',
            country_name: c.country&.name || 'Неизвестная страна',
            gold_export: c.gold_export.to_i,
            gold_import: c.gold_import.to_i,
            total_lost: (c.gold_export.to_i || 0) + (c.gold_import.to_i || 0),
            created_at: c.created_at
          }
        end
      }
    end

    # Calculate income statistics by year and noble
    def calculate_income_stats
      # Получаем все аудиты с income_value для знати
      income_audits = CustomAudit.where(
        auditable_type: 'Player',
        action: 'update'
      ).where.not(income_value: nil)
      .includes(auditable: :player_type)
      .order(created_at: :asc)
      
      # Группируем по годам - только знать (player_type_id == 2)
      by_year = {}
      income_audits.each do |audit|
        year = audit.year
        player = audit.auditable
        
        # Проверяем, что игрок является знатью
        is_noble = player&.player_type&.name == 'Знать'
        next unless is_noble
        
        unless by_year.key?(year)
          by_year[year] = {
            year: year,
            total_income: 0,
            nobles_count: 0,
            nobles: []
          }
        end
        
        by_year[year][:total_income] += audit.income_value.to_i
        by_year[year][:nobles_count] += 1
        
        by_year[year][:nobles] << {
          player_id: player&.id,
          player_name: player&.name || 'Unknown',
          income: audit.income_value.to_i,
          taken_at: audit.created_at
        }
      end
      
      # Конвертируем в массив и сортируем по году
      years_array = by_year.values.sort_by { |y| y[:year] }
      
      # Общий итог
      total_all_time_income = years_array.sum { |y| y[:total_income] }
      
      # Топ знати по полученному доходу
      noble_totals = Hash.new(0)
      income_audits.each do |audit|
        player = audit.auditable
        is_noble = player&.player_type&.name == 'Знать'
        
        if is_noble && player
          noble_totals[player.name] += audit.income_value.to_i
        end
      end
      
      top_nobles = noble_totals.sort_by { |_, v| -v }.take(10).map do |name, total|
        { name: name, total_income: total }
      end
      
      {
        by_year: years_array,
        total_all_time_income: total_all_time_income,
        total_income_events: income_audits.count,
        top_nobles: top_nobles
      }
    end

    # Calculate summary statistics (trade income, trade outcome, noble income, political costs, cashflow)
    def calculate_summary_stats
      # Get all caravans (excluding robbed and via_vyatka)
      trade_caravans = Caravan.where(is_robbed: false).where.not(via_vyatka: true)
      
      # 1. Total income by trade (gold_import - это продажа товаров, т.е. доход)
      total_trade_income = trade_caravans.sum { |c| c.gold_import.to_i }
      
      # 2. Total outcome by trade (gold_export - это покупка товаров, т.е. расход)
      total_trade_outcome = trade_caravans.sum { |c| c.gold_export.to_i }
      
      # 3. Total noble income (из всех аудитов с income_value для знати)
      total_noble_income = CustomAudit.where(
        auditable_type: 'Player',
        action: 'update'
      ).where.not(income_value: nil)
      .includes(auditable: :player_type)
      .select do |audit|
        player = audit.auditable
        player&.player_type&.name == 'Знать'
      end
      .sum(&:income_value)
      
      # 4. Total cost of noble political actions only (исключаем действия купцов)
      political_actions_cost = PoliticalAction.includes(:political_action_type)
        .select { |pa| pa.political_action_type&.job&.name != 'Глава гульдии' }
        .sum { |pa| pa.political_action_type&.cost.to_i }
      
      # 5. Total cost of merchant political actions (только для главы гильдии)
      merchant_political_actions_cost = PoliticalAction.includes(:political_action_type)
        .select { |pa| pa.political_action_type&.job&.name == 'Глава гульдии' }
        .sum { |pa| pa.political_action_type&.cost.to_i }
      
      # 6. Total payment for troops (каждая оплата войска стоит 5000)
      troop_payments_count = count_troop_payments
      total_troop_payments = troop_payments_count * 5000
      
      # 7. Total cost of troop purchases (покупаются ли войска знатью)
      total_troop_purchases_cost = calculate_total_troop_purchases_cost
      
      # 8. Cashflow (total_trade_income - total_trade_outcome + total_noble_income - political_actions_cost - merchant_political_actions_cost - troop_payments - troop_purchases)
      total_cashflow = total_trade_income - total_trade_outcome + total_noble_income - political_actions_cost - merchant_political_actions_cost - total_troop_payments - total_troop_purchases_cost
      
      {
        total_trade_income: total_trade_income,
        total_trade_outcome: total_trade_outcome,
        total_noble_income: total_noble_income,
        political_actions_cost: political_actions_cost,
        merchant_political_actions_cost: merchant_political_actions_cost,
        troop_payments_cost: total_troop_payments,
        troop_payments_count: troop_payments_count,
        troop_purchases_cost: total_troop_purchases_cost,
        total_cashflow: total_cashflow
      }
    end

    # Count troop payments by finding audits where params["paid"] array was extended
    def count_troop_payments
      # Находим все аудиты войск где был добавлен год оплаты
      troop_audits = CustomAudit.where(auditable_type: 'Troop', action: 'update')
      
      payment_count = 0
      troop_audits.each do |audit|
        changes = audit.audited_changes
        next unless changes['params']
        
        old_paid = changes['params'][0]&.dig('paid') || []
        new_paid = changes['params'][1]&.dig('paid') || []
        
        # Если количество оплаченных лет увеличилось - это оплата
        payment_count += (new_paid.length - old_paid.length) if new_paid.length > old_paid.length
      end
      
      payment_count
    end

    # Calculate troop payment statistics by year
    def calculate_troop_payments_stats
      # Находим все аудиты оплат войск
      troop_audits = CustomAudit.where(auditable_type: 'Troop', action: 'update')
      
      # Группируем по годам
      by_year = {}
      troop_audits.each do |audit|
        changes = audit.audited_changes
        next unless changes['params']
        
        old_paid = changes['params'][0]&.dig('paid') || []
        new_paid = changes['params'][1]&.dig('paid') || []
        
        # Определяем, сколько оплат было сделано в этом году
        payments_count = new_paid.length - old_paid.length
        next if payments_count <= 0
        
        year = audit.year
        
        unless by_year.key?(year)
          by_year[year] = {
            year: year,
            payments_count: 0,
            total_cost: 0,
            troops: []
          }
        end
        
        by_year[year][:payments_count] += payments_count
        by_year[year][:total_cost] += payments_count * 5000
        
        troop = audit.auditable
        by_year[year][:troops] << {
          troop_id: troop&.id,
          troop_name: troop&.troop_type&.name || "Troop ##{troop&.id}",
          army_name: troop&.army&.name || "Army ##{troop&.army_id}",
          payments_count: payments_count,
          cost: payments_count * 5000,
          paid_at: audit.created_at
        } if troop
      end
      
      # Конвертируем в массив и сортируем по году
      years_array = by_year.values.sort_by { |y| y[:year] }
      
      # Общий итог
      total_payments = years_array.sum { |y| y[:payments_count] }
      total_cost = years_array.sum { |y| y[:total_cost] }
      
      {
        by_year: years_array,
        total_payments: total_payments,
        total_cost: total_cost
      }
    end

    # Calculate total cost of troop purchases by nobles
    def calculate_total_troop_purchases_cost
      # Находим все аудиты создания войск
      troop_create_audits = CustomAudit.where(auditable_type: 'Troop', action: 'create')
      
      total_cost = 0
      troop_create_audits.each do |audit|
        troop = audit.auditable
        next unless troop
        
        # Проверяем, принадлежит ли армия знати (player_type == 'Знать')
        army = troop.army
        next unless army
        
        owner = army.owner
        # Проверяем, что владелец - это Player (а не Country) и у него player_type == 'Знать'
        next unless owner.is_a?(Player)
        next unless owner.player_type&.name == 'Знать'
        
        # Получаем стоимость покупки из troop_type
        troop_type = troop.troop_type
        next unless troop_type
        
        buy_cost = troop_type.params&.dig('buy_cost')
        next unless buy_cost && buy_cost.is_a?(Array)
        
        # Ищем стоимость в money
        money_cost = buy_cost.find { |item| item['identificator'] == 'money' || item[:identificator] == 'money' }
        total_cost += money_cost['count'].to_i if money_cost
      end
      
      total_cost
    end

    # Calculate troop purchase statistics by year
    def calculate_troop_purchases_stats
      # Находим все аудиты создания войск
      troop_create_audits = CustomAudit.where(auditable_type: 'Troop', action: 'create')
      
      # Группируем по годам
      by_year = {}
      troop_create_audits.each do |audit|
        troop = audit.auditable
        next unless troop
        
        # Проверяем, принадлежит ли армия знатью
        army = troop.army
        next unless army
        
        owner = army.owner
        # Проверяем, что владелец - это Player (а не Country) и у него player_type == 'Знать'
        next unless owner.is_a?(Player)
        next unless owner.player_type&.name == 'Знать'
        
        # Получаем стоимость покупки
        troop_type = troop.troop_type
        next unless troop_type
        
        buy_cost = troop_type.params&.dig('buy_cost')
        next unless buy_cost && buy_cost.is_a?(Array)
        
        money_cost = buy_cost.find { |item| item['identificator'] == 'money' || item[:identificator] == 'money' }
        next unless money_cost
        
        cost = money_cost['count'].to_i
        year = audit.year
        
        unless by_year.key?(year)
          by_year[year] = {
            year: year,
            purchases_count: 0,
            total_cost: 0,
            troops: []
          }
        end
        
        by_year[year][:purchases_count] += 1
        by_year[year][:total_cost] += cost
        
        by_year[year][:troops] << {
          troop_id: troop&.id,
          troop_name: troop&.troop_type&.name || "Troop ##{troop&.id}",
          army_name: troop&.army&.name || "Army ##{troop&.army_id}",
          noble_name: owner&.name || "Unknown",
          cost: cost,
          purchased_at: audit.created_at
        }
      end
      
      # Конвертируем в массив и сортируем по году
      years_array = by_year.values.sort_by { |y| y[:year] }
      
      # Общий итог
      total_purchases = years_array.sum { |y| y[:purchases_count] }
      total_cost = years_array.sum { |y| y[:total_cost] }
      
      {
        by_year: years_array,
        total_purchases: total_purchases,
        total_cost: total_cost
      }
    end
end
