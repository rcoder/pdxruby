class ArticlesController < ApplicationController
  before_filter :member_is_author, :only => [ :edit, :create, :destroy, :update ]
  before_filter :authenticate, :only => [ :new ]
  
  def index
    list
    render :action => 'list'
  end

  def list
    @article_pages, @articles = paginate :article, :per_page => 10, :order_by => 'modified_at'
  end

  def show
    @article = Article.find(params[:id])
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(params[:article])
    if @article.save
      flash[:notice] = 'Article was successfully created.'
      redirect_to :action => 'list'
    else
      render :action => 'new'
    end
  end

  def edit
    @article = Article.find(params[:id])
  end

  def update
    @article = Article.find(params[:id])
    if @article.update_attributes(params[:article])
      flash[:notice] = 'Article was successfully updated.'
      redirect_to :action => 'show', :id => @article
    else
      render :action => 'edit'
    end
  end

  def destroy
    Article.find(params[:id]).destroy
    flash[:notice] = 'Article deleted.'
    redirect_to :action => 'list'
  end
  
  private 
  
  def member_is_author
    if !member_is_this_member? Article.find(params[:id]).member.id
      flash[:notice] = "Only the author can edit or remove articles."
      redirect_to :action => 'list'
      return false
    end
  end
end
