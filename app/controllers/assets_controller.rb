class AssetsController < ApplicationController
  before_action :must_be_logged, only: %i[new create edit update destroy archive replace_battery]
  before_action :must_be_proprietary, only: %i[update destroy replace_battery]
  before_action :get_asset_type, only: [:create]
  before_action :get_asset, only: %i[show edit update archive replace_battery]

  add_breadcrumb 'assets', :assets_path

  def index
    @assets = Asset.where(deleted: false)
  end

  def new
    add_breadcrumb 'new asset'
    @asset = Asset.new
    @asset_types = AssetType.all
  end

  def create
    add_breadcrumb 'new asset'
    @asset_types = AssetType.all

    @asset = Asset.new(asset_params)
    @asset.user = current_logged_user
    @asset.asset_type = @asset_type
    if @asset.save
      flash[:success] = 'Asset successfully created.'
      redirect_to asset_path(@asset)
    else
      render 'new'
    end
  end

  def show
    add_breadcrumb @asset.product_serial
    @asset_types = AssetType.all
    @battery_replacements = @asset.battery_replacements.order('created_at desc').limit(10)
    @missions = @asset.missions.order('starting_date desc', 'ending_date desc')
  end

  def edit
    add_breadcrumb @asset.product_serial, asset_path(@asset)
    add_breadcrumb 'edit'

    @asset_types = AssetType.all
  end

  def update
    add_breadcrumb @asset.product_serial, asset_path(@asset)
    add_breadcrumb 'edit'

    @asset_types = AssetType.all

    if @asset.update(asset_params)
      flash[:success] = 'Asset successfully updated.'
      redirect_to asset_path(@asset)
    else
      render 'edit'
    end
  end

  # this method is no more used for now !
  def destroy
    @asset = Asset.find(params[:id])
    if @asset.destroy
      flash[:success] = 'Asset removed'
      redirect_to assets_path
    else
      flash[:danger] = 'Failed to remove asset ' + @asset.product_serial
      redirect_to asset_path(@asset) # TODO: is this really neaded ?
    end
  end

  def archive
    if @asset.update(deleted: true)
      flash[:success] = 'Asset archived'
      redirect_to assets_path
    else
      flash[:danger] = 'Failed to archive asset ' + @asset.product_serial
      redirect_to asset_path(@asset) # TODO: is this really neaded ?
    end
  end

  def replace_battery
    if @asset.battery_life
      @battery_replacement = BatteryReplacement.new(asset: @asset, user: current_logged_user)
      if @battery_replacement.save
        flash[:success] = 'Battery changed successfully.'
      else
        flash[:danger] = 'Failed to change the battery'
      end
    else
      flash[:warning] = "This asset has no battery, you can't replace it ;)"
    end
    redirect_to asset_path(@asset)
  end

  def get_asset
    @asset = Asset.find_by(id: params['id'], deleted: false) || Asset.find_by(id: params['asset_id'], deleted: false)
    render_404 unless @asset
  end

  def get_asset_type
    @asset_type = AssetType.find_by(id: asset_params['asset_type_id'])
    render_404 unless @asset_type
  end

  def must_be_proprietary
    get_asset
    render_403 if not (@asset.user == current_logged_user or current_logged_user.admin)
  end

  def asset_params
    params.require(:asset).permit(:product_serial, :description, :battery_life, :date_purchase, :asset_type_id, :user_id)
  end
end
