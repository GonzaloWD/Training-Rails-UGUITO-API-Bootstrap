require 'rails_helper'

describe Api::V1::NotesController, type: :controller do
  describe 'GET #index' do
    let(:note_size) { Faker::Number.between(from: 3, to: 6) }
    let(:expected_note_keys) { %w[id title note_type content_length] }

    before { create_list(:note, 5) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'
      before { create_list(:note, note_size, :critique, user: user) }

      context 'when fetching all the notes for user' do
        before { get :index }

        it 'responds with the expected note count' do
          expect(response_body.count).to eq(note_size)
        end

        it 'responds with the expected note keys' do
          expect(response_body.first.keys).to match_array(expected_note_keys)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes with page and page size params' do
        let(:page)            { 1 }
        let(:page_size)       { 2 }

        before { get :index, params: { page: page, page_size: page_size } }

        it 'responds with the expected note count' do
          expect(response_body.count).to eq(page_size)
        end

        it 'responds with the expected note keys' do
          expect(response_body.first.keys).to match_array(expected_note_keys)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching notes using filter note_type with valid type' do
        let(:note_type) { 'review' }

        let!(:review_notes) { create_list(:note, 2, note_type: :review, user: user) }

        before { get :index, params: { note_type: note_type } }

        it 'responds with the expected note count' do
          expect(response_body.count).to eq(review_notes.count)
        end

        it 'responds with the expected note keys' do
          expect(response_body.first.keys).to match_array(expected_note_keys)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching note using invalid type for filter note_type' do
        let(:note_type) { 'something_else' }

        before { get :index, params: { note_type: note_type } }

        it 'responds with 422 status' do
          expect(response).to have_http_status(:unprocessable_entity)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching all the notes for user' do
        before { get :index }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #show' do
    context 'when there is a user logged in' do
      let!(:expected_note_keys) { %w[id title note_type word_count created_at content content_length user] }

      include_context 'with authenticated user'

      context 'when fetching a valid note' do
        let(:note) { create(:note, user: user) }

        before { get :show, params: { id: note.id } }

        it 'responds with the expected detail note keys' do
          expect(response_body.keys).to match_array(expected_note_keys)
        end

        it 'responds with 200 status' do
          expect(response).to have_http_status(:ok)
        end
      end

      context 'when fetching another user note' do
        let(:another_user_notes) { create(:note) }

        before { get :show, params: { id: another_user_notes.id } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end

      context 'when fetching a invalid note' do
        before { get :show, params: { id: Faker::Number.number } }

        it 'responds with 404 status' do
          expect(response).to have_http_status(:not_found)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when fetching note' do
        before { get :show, params: { id: Faker::Number.number } }

        it_behaves_like 'unauthorized'
      end
    end
  end
end
