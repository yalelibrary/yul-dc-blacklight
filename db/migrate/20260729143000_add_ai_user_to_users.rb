class AddAiUserToUsers < ActiveRecord::Migration[7.2]
  def change
    add_column :users, :ai_user, :boolean, default: false, null: false
  end
end
