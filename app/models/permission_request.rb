class PermissionRequest
  include ActiveModel::Model
  include ActiveModel::Attributes
  attribute :user_id
  attribute :email
  attribute :full_name
  attribute :user_note

  def persisted?
    true
  end
end
