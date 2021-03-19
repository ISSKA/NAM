class AddImgToAssetMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_missions, :img, :string
  end
end
