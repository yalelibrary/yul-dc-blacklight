class AddIndexToNetIdSub < ActiveRecord::Migration[6.1]
  def change
    add_index :users, :sub, unique: true
    add_index :users, :netid, unique: true
  end
end
