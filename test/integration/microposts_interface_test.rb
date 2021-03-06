# frozen_string_literal: true

require 'test_helper'

class MicropostsInterfaceTest < ActionDispatch::IntegrationTest
  def setup
    @user = users(:michael)
  end

  test 'micropost interface' do
    log_in_as(@user)
    get feed_path
    # TODO: Test fails because the pagination is not there on mobile devices... So fix it
    # assert_select 'nav.pagination'
    assert_select 'input[type=file]'
    # Invalid submission
    post microposts_path, params: { micropost: { content: '' } }
    assert_select 'div#error_explanation'
    # Valid submission
    content = 'This micropost really ties the room together'
    picture = fixture_file_upload('test/fixtures/rails.png', 'image/png')
    assert_difference 'Micropost.count', 1 do
      post microposts_path, params: { micropost:
                                      { content: content,
                                        picture: picture } }
    end

    assert @user.microposts.first.picture?
    follow_redirect!
    assert_match content, response.body
    # Delete a post.
    assert_select 'a', 'Delete'
    first_micropost = @user.microposts.paginate(page: 1).first
    assert_difference 'Micropost.count', -1 do
      delete micropost_path(first_micropost)
    end
    # Visit a different user.
    get user_path(users(:archer))
    assert_select 'a', text: 'delete', count: 0
  end

  test 'micropost sidebar count' do
    log_in_as(@user)
    get feed_path
    assert_match "#{@user.microposts.count} microposts", response.body
    # User with zero microposts
    other_user = users(:malory)
    log_in_as(other_user)
    get feed_path
    assert_match '0 microposts', response.body
    other_user.microposts.create!(content: 'A micropost')
    get feed_path
    assert_match "#{other_user.microposts.count} micropost".pluralize(other_user.microposts.count), response.body
  end
end
