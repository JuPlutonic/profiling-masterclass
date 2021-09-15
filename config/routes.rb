Rails.application.routes.draw do
  get 'report(/:start_date/:finish_date)', action: :report, controller: 'report'
  root to: 'report#report'
end
