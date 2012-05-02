User.class_eval do
  def line_items
    LineItem.joins(:order => :user).where(:users => {:id => self.id}).where('orders.completed_at is not null')
  end

  def purchased_products
    line_items.collect {|li| li.variant.try(:product)}
  end
end
