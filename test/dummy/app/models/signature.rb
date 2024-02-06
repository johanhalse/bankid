# frozen_string_literal: true

class Signature < ApplicationRecord
  validates :name, presence: true
  validates :uid, presence: true
  validates :device, presence: true
end
