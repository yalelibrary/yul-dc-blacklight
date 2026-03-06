class AddIndexToUsersUid < ActiveRecord::Migration[7.0]
  def change
    add_index :users, :uid, unique: true, if_not_exists: true
  end
end
