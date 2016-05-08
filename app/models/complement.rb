class Complement < ActiveRecord::Base
  include GuideContainer
  include FriendlyName

  validates_presence_of :book

  belongs_to :guide
  belongs_to :book

  include WithTerminalName
end
