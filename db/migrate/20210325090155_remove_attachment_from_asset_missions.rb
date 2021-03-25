class RemoveAttachmentFromAssetMissions < ActiveRecord::Migration[5.1]
  def change
    remove_column :asset_missions, :attachment, :string
  end
end
