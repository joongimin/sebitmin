class Project < ActiveRecord::Base
  has_many :photos, :as => :imageable
  belongs_to :cover_photo, :class_name => "Photo"
end
