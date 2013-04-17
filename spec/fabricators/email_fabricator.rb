# encoding: utf-8

Fabricator(:email, class_name: "Email") do
  label "email"
  id "9"
  email_to "test@example.com, debug@example.com"
end

Fabricator(:email_one, class_name: "Email") do
  label "email_one"
  id "1"
  email_to "test@example.com, debug@example.com"
end

Fabricator(:email_two, class_name: "Email") do
  label "email_two"
  id "2"
  email_to "test@example.com, debug@example.com"
end

Fabricator(:email_three, class_name: "Email") do
  label "email_three"
  id "3"
  email_to "test@example.com, debug@example.com"
end
