module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      def index
        return render_type_error unless valid_type_param?
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      private

      def current_user_notes
        current_user.notes
      end

      def notes
        current_user_notes.with_type_page_order(filtering_params, order, params[:page],
                                                params[:page_size])
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def note
        current_user_notes.find(params.require(:id))
      end

      def valid_type_param?
        type.nil? || Note.note_types.keys.include?(type)
      end

      def type
        params[:note_type]
      end

      def order
        params[:order] || :asc
      end

      def render_type_error
        render json: { error: I18n.t('note.type_not_allowed') }, status: :unprocessable_entity
      end
    end
  end
end
