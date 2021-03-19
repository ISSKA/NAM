class AddAttachmentToAssetMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :asset_missions, :attachment, :string
  end
end
