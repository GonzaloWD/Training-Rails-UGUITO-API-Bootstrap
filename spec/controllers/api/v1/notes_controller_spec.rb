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
        let(:another_user) { create(:user) }
        let(:note) { create(:note, user: another_user) }

        before { get :show, params: { id: note.id } }

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

  describe 'POST #create' do
    let(:title) { Faker::Lorem.word }
    let(:note_type) { :review }
    let(:content) { Faker::Lorem.sentence(word_count: rand(20..50)) }

    context 'when there is a user logged in' do
      include_context 'with authenticated user'

      before { post :create, params: params }

      let(:params) { { note: { title: title, note_type: note_type, content: content } } }

      context 'when creating a valid note' do
        it 'responds with 201 status' do
          expect(response).to have_http_status :created
        end

        it 'render note created message' do
          expect(response_body['message']).to eq I18n.t('note.created_successfully')
        end

        it 'expectated to create a note that belongs to user' do
          expect { post(:create, params: params) }.to change { user.notes.count }.by(1)
        end
      end

      context 'when creating a note with missing params' do
        context 'when missing one param' do
          let(%i[title note_type content].sample) { nil }

          it 'responds with 400 status' do
            expect(response).to have_http_status :bad_request
          end

          it 'render note missing params error' do
            expect(response_body['error']).to eq I18n.t('note.missing_params')
          end

          it 'expectated a note not to be added' do
            expect { post(:create, params: params) }.not_to change(Note, :count)
          end
        end

        context 'when missing all params' do
          let(:params) { { note: {} } }

          it 'responds with 400 status' do
            expect(response).to have_http_status :bad_request
          end

          it 'render note missing params error' do
            expect(response_body['error']).to eq I18n.t('note.missing_params')
          end

          it 'expectated a note not to be added' do
            expect { post(:create, params: params) }.not_to change(Note, :count)
          end
        end
      end

      context 'when creating a note with wrong note_type' do
        let(:note_type) { 'wrong_type' }

        it 'responds with 422 status' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'render note wrong type error' do
          expect(response_body['error']).to eq I18n.t('note.type_not_allowed')
        end

        it 'expectated a note not to be added' do
          expect { post(:create, params: params) }.not_to change(Note, :count)
        end
      end

      context 'when creating a note with invalid content length' do
        let(:note_type) { :review }
        let(:content) { 'rep ' * 80 }

        it 'responds with 422 status' do
          expect(response).to have_http_status :unprocessable_entity
        end

        it 'render note invalid content length' do
          expect(response_body['error']).to eq I18n.t('note.validate_content_length')
        end

        it 'expectated a note not to be added' do
          expect { post(:create, params: params) }.not_to change(Note, :count)
        end
      end
    end

    context 'when there is not a user logged in' do
      context 'when creation note' do
        before { post :create }

        it_behaves_like 'unauthorized'
      end
    end
  end

  describe 'GET #index_async' do
    context 'when the user is authenticated' do
      include_context 'with authenticated user'

      let(:author) { Faker::Book.author }
      let(:params) { { author: author } }
      let(:worker_name) { 'RetrieveNotesWorker' }
      let(:parameters) { [user.id, params] }

      before { get :index_async, params: params }

      it 'returns status code accepted' do
        expect(response).to have_http_status(:accepted)
      end

      it 'returns the response id and url to retrive the data later' do
        expect(response_body.keys).to contain_exactly('response', 'job_id', 'url')
      end

      it 'enqueues a job' do
        expect(AsyncRequest::JobProcessor.jobs.size).to eq(1)
      end

      it 'creates the right job' do
        expect(AsyncRequest::Job.last.worker).to eq(worker_name)
      end

      it 'creates a job with given parameters' do
        expect(AsyncRequest::Job.last.params).to eq(parameters)
      end
    end

    context 'when the user is not authenticated' do
      before { get :index_async }

      it 'returns status code unauthorized' do
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end
end
