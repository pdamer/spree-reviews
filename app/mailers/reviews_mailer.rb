class ReviewsMailer < ActionMailer::Base

  helper "spree/base"

  def review_posted(review)
    subject = "[REVIEW POSTED] product: #{review.product.name}" 
    @review = review

    mail(:to => Spree::Reviews::Config[:notify_email], :subject => subject )
  end



end

