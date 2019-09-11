class Subscription < ApplicationRecord
  has_many :invoices
end
