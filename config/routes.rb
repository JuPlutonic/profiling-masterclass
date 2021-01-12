Rails.application.routes.draw do
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
  concern :report do
    root to: 'report#users'
    get 'report' => 'report#call', as: :report
  end
end
