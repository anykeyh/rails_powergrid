require '../test_helper'

class AuthorTest < ActiveSupport::TestCase
  test "Should fail if no email" do
     assert true
  end

  test "It should has password with less than 6 characters unallowd" do
    author = Author.new
    author.password = "TEST" #only 4 characters

    assert(author.save == false)

    assert(author.errors.messages[:password].length > 0)
  end

  test "test 3" do
    assert(true)
  end
end
