# frozen_string_literal: true

require "factory_bot"

FactoryBot.define do
  factory :alchemy_picture, class: "Alchemy::Picture" do
    image_file do
      ActiveStorage::Blob.create_after_upload!(
        io: File.open(Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png")),
        filename: 'image.png',
        content_type: 'image/png'
      )
    end
    name { "image" }
    upload_hash { Time.current.hash }
  end
end
