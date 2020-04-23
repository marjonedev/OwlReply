class Transaction < ApplicationRecord
  belongs_to :invoice
  belongs_to :user
end
