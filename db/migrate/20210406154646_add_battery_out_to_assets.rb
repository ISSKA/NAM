class AddBatteryOutToAssets < ActiveRecord::Migration[5.1]
  def change
    add_column :assets, :battery_out, :boolean, :default => false
  end
end
