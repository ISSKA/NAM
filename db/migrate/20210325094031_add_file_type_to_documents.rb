class AddFileTypeToDocuments < ActiveRecord::Migration[5.1]
  def change
    add_column :documents, :file_type, :string
  end
end
