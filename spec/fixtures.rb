module Fixtures
  module_function

  def user_fixture(id: 1, first_name: "John", last_name: "Smith")
    "user,#{id},#{first_name},#{last_name},0"
  end

  def session_fixture(id: 1, user_id: 1, browser: "Firefox 12", duration_minutes: 123, date: '2017-03-28')
    "session,#{user_id},#{id},#{browser},#{duration_minutes},#{date}"
  end

  def chrome_session_fixture(**attrs)
    session_fixture(**attrs, browser: "Chrome 14")
  end

  def ie_session_fixture(**attrs)
    session_fixture(**attrs, browser: "Internet Explorer 11")
  end
end
