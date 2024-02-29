module Api
  module V1
    class NotesController < ApplicationController
      def index
        unless valid_type_param?
          return render json: { error: I18n.t('note.type_not_allowed') }, status: :not_acceptable
        end
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      def notes
        Note.where(filtering_params).order(created_at: params[:order] || :asc)
            .page(params[:page])
            .per(params[:page_size])
      end

      def filtering_params
        params.permit(%i[note_type])
      end

      def note
        Note.find(params.require(:id))
      end

      private

      def valid_type_param?
        type.nil? || Note.note_types.keys.include?(type)
      end

      def type
        params[:note_type]
      end
    end
  end
end
