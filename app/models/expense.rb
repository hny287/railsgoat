# frozen_string_literal: true
class Expense < ApplicationRecord
  belongs_to :user
  belongs_to :approver, class_name: "User", optional: true

  STATES = %w[submitted approved paid rejected].freeze
  MONTHLY_LIMIT = 2_000
end
