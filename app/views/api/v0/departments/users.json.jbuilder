# frozen_string_literal: true

json.prettify!

json.array! @users.group_by(&:department).each(department, users {
  json.code department&.code
  json.name department&.name
  json.id   department&.id
  json.users users.each(u {
    json.email u.email
  })
})
