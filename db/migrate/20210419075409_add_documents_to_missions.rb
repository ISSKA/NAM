class AddDocumentsToMissions < ActiveRecord::Migration[5.1]
  def change
    add_column :missions, :documents, :text
  end
end
