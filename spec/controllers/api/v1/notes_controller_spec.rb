require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:notes) { create_list(:note, 5) }

    context 'without need of loggin' do
      let!(:expected) do
        ActiveModel::Serializer::CollectionSerializer.new(notes_expected,
                                                          serializer: NoteSerializer).to_json
      end

      context 'when fetching all the notes' do
        let(:notes_expected) { notes }

        before { get :index }

        it 'responds with the expected notes json' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }
        let(:notes_expected) { notes.first(2) }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using filter note_type with valid type' do
        let(:note_type) { 'review' }

        let!(:notes_custom) { create_list(:note, 2, note_type: :review) }
        let(:notes_expected) { notes_custom }

        before { get :index, params: { note_type: note_type } }

        it 'responds with expected notes' do
          expect(response_body.to_json).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching note using invalid type for filter note_type' do
        let(:note_type) { 'something_else' }

        let(:notes_expected) { [] }

        before { get :index, params: { note_type: note_type } }

        it 'responds with 406 status' do
          expect(response).to have_http_status(:not_acceptable)
        end
      end
    end
  end

  describe 'GET #show' do
    context 'without need of loggin' do
      let(:expected) { NoteDetailSerializer.new(note, root: false).to_json }

      context 'when fetching a valid note' do
        let(:note) { create(:note) }

        before { get :show, params: { id: note.id } }

        it 'responds with the note json' do
          expect(response.body).to eq(expected)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching a invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end
  end
end
