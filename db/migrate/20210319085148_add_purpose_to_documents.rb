class AddPurposeToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :purpose, :string
  end
end
