require 'rails_helper'

RSpec.describe Task, type: :model do
  it { should validate_presence_of(:description) }
  it { should allow_value(true).for(:done) }
  it { should allow_value(false).for(:done) }
  it { should belong_to(:parent).optional(polymorphic: true) }
  it { should have_many(:sub_tasks).dependent(:destroy) }
  it { should have_many(:sub_tasks).with_foreign_key(:parent_id) }

  describe "scopes" do
    describe ".only_parents" do
      it "only returns tasks without a parent" do
        parent_task = Task.create(description: "Parent Task")
        sub_task = parent_task.sub_tasks.create(description: "Sub Task")
        expect(Task.only_parents).to include(parent_task)
        expect(Task.only_parents).not_to include(sub_task)
      end
    end
  end

  describe "methods" do
    describe "#parent?" do
      it "returns true if the task has no parent" do
        parent_task = Task.create(description: "Parent Task")
        sub_task = parent_task.sub_tasks.create(description: "Sub Task")
        expect(parent_task.parent?).to be true
        expect(sub_task.parent?).to be false
      end
    end

    describe "#sub_task?" do
      it "returns true if the task has a parent" do
        parent_task = Task.create(description: "Parent Task")
        sub_task = parent_task.sub_tasks.create(description: "Sub Task")
        expect(parent_task.sub_task?).to be false
        expect(sub_task.sub_task?).to be true
      end
    end

    describe "#symbol" do
      it "returns the correct symbol for each status" do
        pending_task = Task.create(description: "Pending Task", due_date: 1.day.from_now)
        done_task = Task.create(description: "Done Task", done: true)
        expired_task = Task.create(description: "Expired Task", due_date: 1.day.ago)
        expect(pending_task.symbol).to eq("»")
        expect(done_task.symbol).to eq("✓")
        expect(expired_task.symbol).to eq("✕")
      end
    end

    describe "#css_color" do
      it "returns the correct CSS class for each status" do
        pending_task = Task.create(description: "Pending Task", due_date: 1.day.from_now)
        done_task = Task.create(description: "Done Task", done: true)
        expired_task = Task.create(description: "Expired Task", due_date: 1.day.ago)
        expect(pending_task.css_color).to eq("primary")
        expect(done_task.css_color).to eq("success")
        expect(expired_task.css_color).to eq("danger")
      end
    end

    describe "#status" do
      context "when due date is in the future and task is not done" do
        it "returns 'pending'" do
          task = Task.create(description: "Task", due_date: 1.day.from_now, done: false)
          expect(task.send(:status)).to eq("pending")
        end
      end

      context "when due date is in the past and task is not done" do
        it "returns 'expired'" do
          task = Task.create(description: "Task", due_date: 1.day.ago, done: false)
          expect(task.send(:status)).to eq("expired")
        end
      end

      context "when task is done" do
        it "returns 'done'" do
          task = Task.create(description: "Task", done: true)
          expect(task.send(:status)).to eq("done")
        end
      end
    end
  end

  describe Task do
    let(:task) { create(:task) }
  
    describe "factories" do
      it "has a valid default factory" do
        expect(task).to be_valid
      end
  
      it "creates a task with parent" do
        task_with_parent = create(:task, :with_parent)
        expect(task_with_parent.parent).to be_a(Task)
      end
  
      it "creates a task with sub tasks" do
        task_with_sub_tasks = create(:task, :with_sub_tasks)
        expect(task_with_sub_tasks.sub_tasks.count).to eq(3)
      end
    end
  end  
end