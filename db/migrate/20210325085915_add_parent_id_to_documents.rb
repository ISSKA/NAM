class AddParentIdToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :parent_id, :string
  end
end
