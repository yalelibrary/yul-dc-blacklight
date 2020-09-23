class RemoveUserEmailIndex < ActiveRecord::Migration[6.0]
  # Although devise adds an email field to the User model, that field is not
  # populated by CAS. Since this field will (almost?) always be blank, we can't
  # define an index on it.
  def change
    remove_index :users, :email
  end
end
