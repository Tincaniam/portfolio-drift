CI.run do
  step "Setup", "bin/setup --skip-server"
  step "Tests", "bin/rails test"
  step "Ruby style", "bin/rubocop"
  step "Security", "bin/brakeman --quiet --no-pager --exit-on-warn --exit-on-error"
end
