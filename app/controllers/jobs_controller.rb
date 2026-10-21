class JobsController < ApplicationController
  before_action :set_job, only: %i[ show edit update destroy ]
  before_action :set_jobs_country, only: %i[ index show edit update ]

  # GET /jobs or /jobs.json
  # Справочник должностей общий (Д3): в каждой должности отдаются держатели
  # и политические действия указанного государства (?country_id=, по умолчанию — текущего)
  def index
    @jobs = Job.all
    @jobs = @jobs.where(id: 1..8) if params[:nobles].to_i == 1 #TODO: CONSTANTS
  end

  # GET /jobs/1 or /jobs/1.json
  def show
  end

  # GET /jobs/new
  def new
    @job = Job.new
  end

  # GET /jobs/1/edit
  def edit
  end

  # POST /jobs or /jobs.json
  def create
    @job = Job.new(job_params)

    respond_to do |format|
      if @job.save
        format.html { redirect_to job_url(@job), notice: "Job was successfully created." }
        format.json { render :show, status: :created, location: @job }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /jobs/1 or /jobs/1.json
  # Замена держателей идёт только в пределах государства (@jobs_country): держатели
  # других государств сохраняются, иначе назначение в одной стране стирает совет другой
  def update
    country = @jobs_country
    old_player_ids = @job.player_ids.dup
    
    respond_to do |format|
      if @job.update(job_params_for_country(country))
        # Создаем аудит для смены должности
        if old_player_ids != @job.player_ids
          old_players = Player.where(id: old_player_ids).pluck(:name)
          new_players = Player.where(id: @job.player_ids).pluck(:name)
          
          comment = if old_players.empty? && !new_players.empty?
            "#{@job.name} назначен #{new_players.join(', ')}"
          elsif !old_players.empty? && new_players.empty?
            "#{@job.name} освобожден от #{old_players.join(', ')}"
          elsif !old_players.empty? && !new_players.empty?
            "#{@job.name} передан от #{old_players.join(', ')} к #{new_players.join(', ')}"
          else
            "#{@job.name} изменен"
          end
          
          @job.audits.create!(
            action: 'update',
            auditable: @job,
            audited_changes: { 'player_ids' => [old_player_ids, @job.player_ids] },
            comment: comment
          )
        end
        
        format.html { redirect_to job_url(@job), notice: "Job was successfully updated." }
        format.json { render :show, status: :ok, location: @job }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @job.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /jobs/1 or /jobs/1.json
  def destroy
    @job.destroy

    respond_to do |format|
      format.html { redirect_to jobs_url, notice: "Job was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Государство должности: ?country_id=<id> или текущее государство
    def set_jobs_country
      @jobs_country = if params[:country_id].present?
                        Country.find_by(id: params[:country_id]) || Country.current
                      else
                        Country.current
                      end
    end

    # Параметры обновления должности в пределах государства
    def job_params_for_country(country)
      permitted = job_params
      return permitted if country.nil? || permitted[:player_ids].nil?

      # Держатели других государств остаются в должности
      foreign_ids = Player.where(id: @job.player_ids).where.not(country_id: country.id).pluck(:id)
      incoming_ids = Array(permitted[:player_ids]).map(&:to_i)

      permitted.merge(player_ids: (foreign_ids + incoming_ids).uniq)
    end

    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def job_params
      params.require(:job).permit(:name, :params, player_ids: [])
    end
end
