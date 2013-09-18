require 'spree_core'

module SpreeReviews
  
  class AbilityDecorator
    include CanCan::Ability

    def initialize(user)
      can :create, Review do |review|
        (user.has_role?(:user) || !Spree::Reviews::Config[:require_login]) and
        (user.purchased_products.include? review.product or !Spree::Reviews::Config[:require_purchase])
      end
      can :create, FeedbackReview do |review|
        user.has_role?(:user) || !Spree::Reviews::Config[:require_login]
      end
    end
  end

  class Engine < Rails::Engine

    config.autoload_paths += %W(#{config.root}/lib)

    def self.activate
      Dir.glob(File.join(File.dirname(__FILE__), "../app/**/*_decorator*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
      Dir.glob(File.join(File.dirname(__FILE__), "../app/overrides/*.rb")) do |c|
        Rails.application.config.cache_classes ? require(c) : load(c)
      end
      ProductsHelper.send(:include, ReviewsHelper)
      Admin::ReviewsController.cache_sweeper :review_sweeper
      Ability.register_ability(AbilityDecorator)
    end

    config.to_prepare &method(:activate).to_proc
  end
end
