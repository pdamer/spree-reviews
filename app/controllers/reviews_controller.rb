class ReviewsController < Spree::BaseController
  helper Spree::BaseHelper
  helper_method :can_review?
  before_filter :load_product, :only => [:index, :new, :create]
  rescue_from ActiveRecord::RecordNotFound, :with => :render_404

  def index
    @approved_reviews = Review.approved.find_all_by_product_id(@product.id) 
    render :layout => !request.xhr?
  end

  def new
    @review = Review.new(:product => @product)
    authorize! :new, @review, :message => "You must log in to review."
    render :layout => !request.xhr?
  end

  # save if all ok
  def create
    params[:review][:rating].sub!(/\s*stars/,'') unless params[:review][:rating].blank?

    @review = Review.new(params[:review])
    @review.product = @product
    @review.user = current_user if user_signed_in?
    @review.ip_address = request.remote_ip
    
    authorize! :create, @review, :message => "You must log in to review."
    
    if @review.save
      flash[:notice] = t('review_successfully_submitted')
      redirect_to (product_path(@product))
    else
      render :action => "new", :layout => !request.xhr?
    end
  end
  
  def terms
  end
  
  private
    
    def load_product
      @product = Product.find_by_permalink!(params[:product_id])
    end

    def can_review?
      (current_user and current_user.purchased_products.include?(@product)) or !Spree::Reviews::Config[:require_purchase]
    end

end
