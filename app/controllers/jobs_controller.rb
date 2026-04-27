class JobsController < ApplicationController
  before_action :set_job, only: %i[ show edit update destroy ]

  # GET /jobs or /jobs.json
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
  def update
    old_player_ids = @job.player_ids.dup
    
    respond_to do |format|
      if @job.update(job_params)
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
            user: current_user,
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
    # Use callbacks to share common setup or constraints between actions.
    def set_job
      @job = Job.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def job_params
      params.require(:job).permit(:name, :params, player_ids: [])
    end
end
