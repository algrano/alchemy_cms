# frozen_string_literal: true

module Alchemy
  class EssenceActionTextSerializer < ActiveModel::Serializer
    attributes(
      :id,
      :body,
      :stripped_body,
    )
  end
end
