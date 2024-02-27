module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        if valid_type_param
          render json: notes_filtered, status: :ok, each_serializer: IndexNoteSerializer
        else
          render json: { error: I18n.t('note.type_not_allowed') }, status: :not_acceptable
        end
      end

      def show
        render json: show_note, status: :ok, serializer: ShowNoteSerializer
      end

      private

      def notes
        current_user.notes
      end

      def notes_filtered
        order, page, page_size = params.values_at(:order, :page, :page_size)
        order ||= :asc
        notes.all.where(filtering_params).order(created_at: order).page(page).per(page_size)
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def show_note
        notes.find(params.require(:id))
      end

      def valid_type_param
        type = params[:note_type]
        notes.note_types.keys.include?(type) || type.nil?
      end
    end
  end
end
