# frozen_string_literal: true
class PermissionRequest
  include ActiveModel::Model
  include ActiveModel::Attributes
  attribute :oid
  attribute :user_email
  attribute :user_full_name
  attribute :user_netid
  attribute :user_note
  attribute :user_sub

  def persisted?
    true
  end
end
