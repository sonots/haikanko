# encoding: utf-8

Fabricator(:host, class_name: "Host") do
  label "host"
  id "9"
end

Fabricator(:host_one, class_name: "Host") do
  label "host_one"
  id "1"
end

Fabricator(:host_two, class_name: "Host") do
  label "host_two"
  id "2"
end

Fabricator(:host_three, class_name: "Host") do
  label "host_three"
  id "3"
end
