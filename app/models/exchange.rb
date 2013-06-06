# book_id => owner book id
#user_id => requester user id

class Exchange < ActiveRecord::Base
  attr_accessible :book_id, :user_id, :status, :package, :duration,
    :starting_date, :ending_date, :amount, :counter_offer, :counter_offer_last_made_by

  attr_accessor :declined, :declined_reason
  
  belongs_to :book
  belongs_to :user
  has_many :dashboard_notifications, :as => :dashboardable
  has_one :payment

  validates :duration, :numericality => true, :unless => Proc.new{|b| b.package == "semester"}
  validates :package, :inclusion => {:in => ["daily", "weekly", "monthly", "semester", "buy"]}

  STATUS = {
    :accepted => "ACCEPTED",
    :returned => "RETURNED",
    :pending => "PENDING",
    :not_returned => "NOT-RETURNED"
  }

  before_create :compute_amount, :avilable_in_date?, :set_status, :set_counter_offer_maker
  before_create :set_ending_date, :if => Proc.new{|b| b.ending_date == nil}

  scope :accepted, where(:status => STATUS[:accepted])

  def set_counter_offer_maker
    if self.counter_offer.present?
      self.counter_offer_last_made_by = self.user.id
    end
  end

  def destroy_other_pending_requests
    book = self.book_id
    borrower = self.user_id
    @other_pending_requests = Exchange.where("book_id = ? and user_id != ?", book, borrower)
    @other_pending_requests.each {|e| e.destroy} if @other_pending_requests.any?
  end

  def set_status
    self.status = Exchange::STATUS[:pending]
  end

  def set_ending_date
    if self.package == "semester"
      fall_semester = self.user.school.fall_semester
      spring_semester = self.user.school.spring_semester
      if fall_semester.month > spring_semester.month
        if fall_semester.month >= Date.today.month and Date.today.month >= spring_semester.month
          self.ending_date = fall_semester - 1.day
        else
          self.ending_date = spring_semester - 1.day
        end
      end
      
      if fall_semester.month < spring_semester.month
        if fall_semester.month <= Date.today.month and Date.today.month <= spring_semester.month
          self.ending_date = spring_semester - 1.day
        else
          self.ending_date = fall_semester - 1.day
        end
      end
    end
  end

  def avilable_in_date?
    if self.package == "semester"
      return true
    elsif self.package == "buy"
      return true
    else
      if self.package == "daily"
        self.ending_date = self.starting_date + self.duration.days
      elsif self.package == "weekly"
        self.ending_date = self.starting_date + self.duration.weeks
      elsif self.package == "monthly"
        self.ending_date = self.starting_date + self.duration.months
      end
      if self.starting_date >= self.book.available_from and self.ending_date <= self.book.returning_date
        return true
      else
        errors[:base] << "The book is not available in that requested time."
        return false
      end
    end
  end
  
  def compute_amount
    if self.package == "daily"
      rate = self.book.loan_daily
    elsif self.package == "weekly"
      rate = self.book.loan_weekly
    elsif self.package == "monthly"
      rate = self.book.loan_monthly
    elsif self.package == "semester"
      rate = self.book.loan_semester
    elsif self.package == "buy"
      rate = self.book.price
    end
    if self.package == "semester" or self.package == "buy"
      total_amount = rate
    else
      total_amount = rate * self.duration
    end
    self.amount = total_amount
  end
  
  def charge
    begin
      response = self.user.billing_setting.charge(self.amount, "Book renting charge - #{self.amount}")
      if self.payment.present?
        payment = self.payment
        payment.charge_id = response.id
        payment.status = Payment::STATUS[:pending]
      else
        payment = self.build_payment(:payment_amount => self.amount, :charge_id => response.id, :status => Payment::STATUS[:pending])
      end
      
      if payment.save
        Notify.borrower_proposal_accept(self)
      end
      return true
    rescue => e
      logger.error e.message
      self.errors.add(:base, e.message)
      self.declined = e.message
      self.destroy
      return false
    end
  end

  def other_pending_payment_present?
    book = self.book_id
    borrower = self.user_id
    @other_pending_requests = Exchange.where("book_id = ? and user_id != ?", book, borrower)
    if @other_pending_requests.present? and @other_pending_requests.each {|p| p.payment}.present?
      return true if @other_pending_requests.each {|p| p.payment.status == Payment::STATUS[:pending]}.present?
    else
      return false
    end
  end
end
