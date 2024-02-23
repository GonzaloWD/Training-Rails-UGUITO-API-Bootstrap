module Api
  module V1
    class NotesController < ApplicationController
      def index
        render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      def notes_filtered
        params[:note_type] = nil unless valid_type_param
        order, page, page_size = params.values_at(:order, :page, :page_size)
        order ||= :asc
        Note.all.where(filtering_params).order(created_at: order).page(page).per(page_size)
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def show_note
        Note.find(params.require(:id))
      end

      private

      def valid_type_param
        type = params[:note_type]
        Note.note_types.keys.include?(type) || type.nil?
      end
    end
  end
end
