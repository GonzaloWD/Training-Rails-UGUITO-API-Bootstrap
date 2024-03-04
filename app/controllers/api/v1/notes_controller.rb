module Api
  module V1
    class NotesController < ApplicationController
      def index
        return render_type_error unless valid_type_param?
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      private

      def notes
        Note.with_type_order(filtering_params, order)
            .page(params[:page])
            .per(params[:page_size])
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def note
        Note.find(params.require(:id))
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
