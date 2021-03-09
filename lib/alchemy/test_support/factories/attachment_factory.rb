# frozen_string_literal: true

require "factory_bot"

FactoryBot.define do
  factory :alchemy_attachment, class: "Alchemy::Attachment" do
    file do
      ActiveStorage::Blob.create_after_upload!(
        io: File.open(Alchemy::Engine.root.join("lib", "alchemy", "test_support", "fixtures", "image.png")),
        filename: 'image.png',
        content_type: 'image/png'
      )
    end
    name { "image" }
    file_name { "image.png" }
  end
end
