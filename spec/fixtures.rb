module Fixtures
  module_function

  def user_fixture(id: 1, first_name: "John", last_name: "Smith")
    "user,#{id},#{first_name},#{last_name},0"
  end
end
