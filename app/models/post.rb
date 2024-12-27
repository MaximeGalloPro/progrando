# app/models/post.rb
class Post < ApplicationRecord
    has_one_attached :thumbnail do |attachable|
        attachable.variant :thumb, resize_to_fill: [300, 200]
        attachable.variant :medium, resize_to_fill: [800, 400]
    end
end