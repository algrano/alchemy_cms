# frozen_string_literal: true

# == Schema Information
#
# Table name: alchemy_attachments
#
#  id              :integer          not null, primary key
#  name            :string
#  file_name       :string
#  file_mime_type  :string
#  file_size       :integer
#  creator_id      :integer
#  updater_id      :integer
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  cached_tag_list :text
#  file_uid        :string
#

module Alchemy
  class Attachment < BaseRecord
    include Alchemy::Filetypes
    include Alchemy::NameConversions
    include Alchemy::Taggable
    include Alchemy::TouchElements

    has_one_attached :file

    before_save :set_fields

    stampable stamper_class_name: Alchemy.user_class_name

    has_many :essence_files, class_name: "Alchemy::EssenceFile", foreign_key: "attachment_id"
    has_many :contents, through: :essence_files
    has_many :elements, through: :contents
    has_many :pages, through: :elements

    # We need to define this method here to have it available in the validations below.
    class << self
      # The class used to generate URLs for attachments
      #
      # @see Alchemy::Attachment::Url
      def url_class
        @_url_class ||= Alchemy::Attachment::Url
      end

      # Set a different attachment url class
      #
      # @see Alchemy::Attachment::Url
      def url_class=(klass)
        @_url_class = klass
      end

      def searchable_alchemy_resource_attributes
        %w(name file_name)
      end

      def allowed_filetypes
        Config.get(:uploader).fetch("allowed_filetypes", {}).fetch("alchemy/attachments", [])
      end

      def file_types_for_select
        # file_types = Alchemy::Attachment.pluck(:file_mime_type).uniq.map do |type|
        #   [Alchemy.t(type, scope: "mime_types"), type]
        # end
        # file_types.sort_by(&:first)
        []
      end
    end

    # validates_presence_of :file
    # validates_size_of :file, maximum: Config.get(:uploader)["file_size_limit"].megabytes
    # validates_property :ext,
    #   of: :file,
    #   in: allowed_filetypes,
    #   case_sensitive: false,
    #   message: Alchemy.t("not a valid file"),
    #   unless: -> { self.class.allowed_filetypes.include?("*") }

    before_save :set_name, if: :file_name_changed?

    scope :with_file_type, ->(file_type) { where(file_mime_type: file_type) }

    # Instance methods

    def to_jq_upload
      {
        "name" => read_attribute(:file_name),
        "size" => read_attribute(:file_size),
        "error" => errors[:file].join,
      }
    end

    def url(options = {})
      return unless file.present?
      Rails.application.routes.url_helpers.rails_blob_path(file, only_path: true)
      # if file
      #   self.class.url_class.new(self).call(options)
      # end
    end

    # An url save filename without format suffix
    def slug
      CGI.escape(file_name.gsub(/\.#{extension}$/, "").tr(".", " "))
    end

    alias_method :urlname, :slug
    deprecate urlname: :slug, deprecator: Alchemy::Deprecation

    # Checks if the attachment is restricted, because it is attached on restricted pages only
    def restricted?
      pages.any? && pages.not_restricted.blank?
    end

    # File format suffix
    def extension
      file_name.split(".").last
    end

    alias_method :suffix, :extension

    # Returns a css class name for kind of file
    #
    def icon_css_class
      case file_mime_type
      when "application/pdf"
        "file-pdf"
      when "application/msword"
        "file-word"
      when *TEXT_FILE_TYPES
        "file-alt"
      when *EXCEL_FILE_TYPES
        "file-excel"
      when *VCARD_FILE_TYPES
        "address-card"
      when *ARCHIVE_FILE_TYPES
        "file-archive"
      when *AUDIO_FILE_TYPES
        "file-audio"
      when *IMAGE_FILE_TYPES
        "file-image"
      when *VIDEO_FILE_TYPES
        "file-video"
      else
        "file"
      end
    end

    private

    def set_fields
      return unless file.attached?
      self.file_mime_type = file.blob.content_type
      self.file_name = file.blob.filename
      self.file_size = file.blob.byte_size
    end

    def set_name
      self.name = convert_to_humanized_name(file_name, File.extname(file_name))
    end
  end
end
