# frozen_string_literal: true

module Alchemy
  class AttachmentsController < BaseController
    before_action :load_attachment
    authorize_resource class: Alchemy::Attachment

    # sends file inline. i.e. for viewing pdfs/movies in browser
    def show
      response.headers["Content-Length"] = @attachment.file_size
      redirect_to @attachment.url
    end

    # sends file as attachment. aka download
    def download
      response.headers["Content-Length"] = @attachment.file_size
      send_data(
        @attachment.file.download, {
          filename: @attachment.file_name,
          type: @attachment.file_mime_type,
        }
      )
    end

    private

    def load_attachment
      @attachment = Attachment.find(params[:id])
    end
  end
end
