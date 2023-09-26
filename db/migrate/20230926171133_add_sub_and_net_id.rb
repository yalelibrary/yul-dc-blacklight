class AddSubAndNetId < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :netid, :string
    add_column :users, :sub, :string
  end
end
