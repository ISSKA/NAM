class AddImagesToAssetMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_missions, :images, :text
  end
end
