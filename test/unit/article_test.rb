require File.dirname(__FILE__) + '/../test_helper'

class ArticleTest < Test::Unit::TestCase
  fixtures :articles, :members

  def setup
    @article = Article.new
  end

  def test_create_read_update_delete
    assert(@article.save)

    read_article = Article.find @article.id

    assert_equal(@article.id, read_article.id)

    @article.title = 'Just a test'

    assert(@article.save)

    assert(@article.destroy)
  end

  def test_associations
    assert_kind_of(Member, articles(:hamster).member)
  end

  def test_filtered_content
    @article.content = '<script>something bad</script> other'
    assert_equal('[script] other', @article.filtered_content)
  end
end
