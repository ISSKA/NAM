class AddLocationToMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :missions, :location, :string
  end
end
