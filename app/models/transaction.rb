class Transaction < ActiveRecord::Base
  attr_accessible :description, :transactable_id, :transactable_type, :user_id, :amount

  belongs_to :user
  belongs_to :transactable, :polymorphic => true
end
