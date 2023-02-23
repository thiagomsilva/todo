FactoryBot.define do
    factory :task do
        description { Faker::Lorem.sentence }
        due_date { Faker::Date.between(from: Date.today, to: 1.month.from_now) }
        done { Faker::Boolean.boolean }

        trait :with_parent do
            parent { create(:task) }
        end
  
        trait :with_sub_tasks do
            after(:create) do |task|
                create_list(:task, 3, parent: task)
            end
        end
    end
end
  