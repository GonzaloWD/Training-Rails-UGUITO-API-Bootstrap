module Api
  module V1
    class NotesController < ApplicationController
      before_action :authenticate_user!

      rescue_from ActiveRecord::RecordInvalid, with: :render_invalid_content_length_error
      rescue_from ActionController::ParameterMissing, with: :render_missing_params_error

      def index
        return render_type_error unless valid_type_param?
        render json: notes, status: :ok, each_serializer: NoteSerializer
      end

      def show
        render json: note, status: :ok, serializer: NoteDetailSerializer
      end

      def create
        return render_type_error unless valid_create_type_param?
        Note.create!(note_params.merge(user: current_user))
        render_created_note_message
      end

      private

      def current_user_notes
        current_user.notes
      end

      def notes
        current_user_notes.with_type_order(filtering_params, order)
                          .page(params[:page])
                          .per(params[:page_size])
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

      def valid_create_type_param?
        Note.note_types.keys.include?(note_params[:note_type])
      end

      def type
        params[:note_type]
      end

      def order
        params[:order] || :asc
      end

      def note_params
        params.require(:note).require(%i[title note_type content])
        params.require(:note).permit(:title, :note_type, :content)
      end

      def render_created_note_message
        render json: { message: I18n.t('note.created_successfully') }, status: :created
      end

      def render_invalid_content_length_error
        render json: { error: I18n.t('note.validate_content_length') },
               status: :unprocessable_entity
      end

      def render_missing_params_error
        render json: { error: I18n.t('note.missing_params') }, status: :bad_request
      end

      def render_type_error
        render json: { error: I18n.t('note.type_not_allowed') }, status: :unprocessable_entity
      end
    end
  end
end
