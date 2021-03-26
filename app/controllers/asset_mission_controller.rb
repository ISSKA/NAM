class AssetMissionController < ApplicationController
  before_action :get_asset_mission, only: %i[edit update]
	before_action :must_be_proprietary, only: %i[edit update]

  before_action do
    add_breadcrumb 'missions', :missions_path
    add_breadcrumb @asset_mission.mission.project_name, mission_path(@asset_mission.mission)
  end

  def edit
    add_breadcrumb 'asset ' + @asset_mission.asset.product_serial
    add_breadcrumb 'edit'
  end

  def update
    add_breadcrumb 'asset ' + @asset_mission.asset.product_serial
    add_breadcrumb 'edit'
	if @asset_mission.img != "NULL"
	  puts "test param = #{@asset_mission.img}"
	end
    if @asset_mission.update(asset_mission_params)
      flash[:success] = 'Asset mission successfully updated.'
      redirect_to mission_path(@asset_mission.mission_id)
    else
      render 'edit'
    end
  end

  def get_asset_mission
    @asset_mission = AssetMission.find_by(id: params['id'])
    render_404 unless @asset_mission
  end
	
	def must_be_proprietary
    render_403 if (current_logged_user && !(@asset_mission.user == current_logged_user or current_logged_user.admin))
  end

  def asset_mission_params
    params.require(:asset_mission).permit(:comments, :placed_at, :img, :extracted_at, :position_x, :position_y, :position_z)
  end

end
