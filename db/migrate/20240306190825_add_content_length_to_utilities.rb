class AddContentLengthToUtilities < ActiveRecord::Migration[6.1]
  def change
    add_column :utilities, :short_content_length, :integer, null: false, default: 50
    add_column :utilities, :medium_content_length, :integer, null: false, default: 100
  end
end
