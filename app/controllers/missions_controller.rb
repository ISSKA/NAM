class MissionsController < ApplicationController
  before_action :must_be_logged, only: %i[new create edit update destroy prepare_assets add_assets extract_asset remove_asset]
  before_action :must_be_proprietary, only: %i[update prepare_assets extract_asset]
  before_action :get_mission, only: %i[show edit update prepare_assets add_assets extract_asset remove_asset]
  before_action :get_asset_mission, only: %i[extract_asset remove_asset]

  add_breadcrumb 'missions', :missions_path

  def index
    @missions = Mission.all.order('starting_date desc', 'ending_date desc')
  end

  def new
    add_breadcrumb 'new mission'
    @mission = Mission.new
  end

  def create
    add_breadcrumb 'new mission'

    @mission = Mission.new(mission_params)
    @mission.user = current_logged_user
    if @mission.save
      flash[:success] = 'Mission successfully created.'
      redirect_to mission_path(@mission)
    else
      render 'new'
    end
  end

  def show
    add_breadcrumb @mission.project_name
    @asset_missions = @mission.asset_missions.order('placed_at desc')
  end

  def edit
    add_breadcrumb @mission.project_name, mission_path(@mission)
    add_breadcrumb 'edit'

    @asset_missions = @mission.asset_missions.order('placed_at desc')
  end

  def update
    add_breadcrumb @mission.project_name, mission_path(@mission)
    add_breadcrumb 'edit'

    if @mission.update(mission_params)
      flash[:success] = 'Mission successfully updated.'
      redirect_to mission_path(@mission)
    else
      render 'edit'
    end
  end

  def destroy
    @mission = Mission.find(params[:id])
    if @mission.destroy
      flash[:success] = 'Mission removed'
      redirect_to missions_path
    else
      flash[:danger] = 'Failed to remove mission ' + @mission.project_name
      redirect_to mimssion_path(@mission) # TODO: is this really neaded ?
    end
  end

  def prepare_assets
    add_breadcrumb @mission.project_name, mission_path(@mission)
    add_breadcrumb 'bring assets'
    @assets = []
    Asset.where(deleted: false).each do |asset|
      unless asset.has_current_mission
        @assets.push(asset)
      end
    end
  end

  def add_assets
    if params&.key?('assets_id')
      params['assets_id'].each do |asset_id|
        asset_mission = AssetMission.new
        asset_mission.mission = @mission
        asset_mission.asset = Asset.find_by(id: asset_id)
        asset_mission.user = current_logged_user
        asset_mission.placed_at = DateTime.now
        unless asset_mission.save
          flash[:danger] = 'Error when trying to assign the "' + asset_mission.asset.product_serial + ' ' + asset_mission.asset.description + '" to this mission. ' + asset_mission.errors.full_messages.to_sentence
          break
        end
      end
    else
      flash[:warning] = 'Select an asset related to this mission.'
    end
    redirect_to mission_path(@mission)
  end

  def extract_asset
    @asset_mission.extracted_at = DateTime.now
    unless @asset_mission.save
      flash[:danger] = 'Error when trying to assign the "' + @asset_mission.errors.full_messages.to_sentence
    end
    redirect_to mission_path(@mission)
  end

  def remove_asset
    if @asset_mission.destroy
      flash[:success] = 'Asset removed from the mission'
    else
      flash[:danger] = 'Failed to remove asset ' + @asset.product_serial + 'from mission ' + @mission.project_name
    end
    redirect_to mission_path(@mission)
  end

  def get_mission
    @mission = Mission.find_by(id: params['id']) || Mission.find_by(id: params['mission_id'])
    render_404 unless @mission
  end

  def get_asset_mission
    @asset_mission = AssetMission.find_by(id: params['mission_asset_id'])
    render_404 if !@asset_mission || @asset_mission.mission != @mission
  end

  def must_be_proprietary
    get_mission
    render_403 if current_logged_user && @mission.user != current_logged_user
  end

  def mission_params
    params.require(:mission).permit(:project_name, :description, :starting_date, :ending_date)
  end
end
