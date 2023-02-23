require 'rails_helper'

RSpec.describe TasksController, type: :request do
  before(:each) do
    username = Rails.application.credentials.authentication[:username]
    password = Rails.application.credentials.authentication[:password]
    @credentials = ActionController::HttpAuthentication::Basic.encode_credentials(username, password)
  end

  describe "GET #new" do
    it "renders the new template" do
      get new_task_path, headers: { "Authorization": @credentials }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "creates a new task and redirects to index" do
        expect {
          post tasks_path, params: { task: FactoryBot.attributes_for(:task) }, headers: { "Authorization": @credentials }
        }.to change(Task, :count).by(1)

        expect(response).to redirect_to(tasks_path)
        expect(flash[:notice]).to eq("A Task foi criada com sucesso.")
      end
    end

    context "with invalid attributes" do
      it "does not create a new task and renders the new template" do
        expect {
          post tasks_path, params: { task: FactoryBot.attributes_for(:task, description: nil) }, headers: { "Authorization": @credentials }
        }.to_not change(Task, :count)

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:new)
        expect(flash[:alert]).to_not be_empty
      end
    end
  end

  describe "GET #edit" do
    let(:task) { FactoryBot.create(:task) }

    it "renders the edit template" do
      get edit_task_path(task), headers: { "Authorization": @credentials }
      expect(response).to have_http_status(:ok)
      expect(response).to render_template(:edit)
    end
  end

  describe "PUT #update" do
    let(:task) { FactoryBot.create(:task) }

    context "with valid attributes" do
      it "updates the task and redirects to index" do
        put task_path(task), params: { task: { description: "New Description" } }, headers: { "Authorization": @credentials }

        task.reload
        expect(task.description).to eq("New Description")

        expect(response).to redirect_to(tasks_path)
        expect(flash[:notice]).to eq("A Task foi atualizada com sucesso.")
      end
    end

    context "with invalid attributes" do
      it "does not update the task and renders the edit template" do
        put task_path(task), params: { task: { description: "" } }, headers: { "Authorization": @credentials }

        task.reload
        expect(task.description).to_not be_empty

        expect(response).to have_http_status(:unprocessable_entity)
        expect(response).to render_template(:edit)
        expect(flash[:alert]).to_not be_empty
      end
    end
  end

  describe "DELETE #destroy" do
    let!(:task) { FactoryBot.create(:task) }

    it "destroys the task and redirects to index" do
      expect {
        delete task_path(task), headers: { "Authorization": @credentials }
      }.to change(Task, :count).by(-1)

      expect(response).to have_http_status(:redirect)
      expect(response).to redirect_to(tasks_path)
      expect(flash[:notice]).to eq("A Task foi removida com sucesso.")
    end
  end
end
