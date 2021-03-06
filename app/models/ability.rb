# encoding: utf-8

class Ability
  include CanCan::Ability

  def initialize(user)
    user ||= User.new
    
    if user.has_role? :admin
      # Role Admin
      can :manage, :all
      
    elsif user.has_role? :readonly_user
      can :read, :all
      can :search, Account
      cannot :manage, [Import, ImportAccount, ImportContact]
      
    elsif user.has_role? :restricted_user
      # Role Restricted User
      can :read, Account
	  can :search, Account
	  can :update, Account, :user_id => user.id
	  can :create, Account
	  cannot :destroy, Account
      can :read, Alias
	  can :update, Alias, :user_id => user.id
	  can :create, Account
	  cannot :destroy, Account	  
      can :read, Tag    
      can :read, Contact
	  can :update, Contact, :account => {:user_id => user.id}
	  can :create, Contact, :account => {:user_id => user.id}      
	  cannot :destroy, Contact
      can :read, Event
	can :update, Event, :user_id => user.id 
	can :create, Event, :account => {:user_id => user.id}
	can :destroy, Event, :user_id => user.id
      can :read, Relation
	  can :update, Relation, :account => {:user_id => user.id}
	  can :create, Relation, :account => {:user_id => user.id}
	  can :destroy, Relation, :account => {:user_id => user.id}
      can :manage, Opportunity
	  cannot :destroy, Opportunity
      can :manage, Quotation
	  cannot :destroy, Quotation
      can :manage, QuotationLine
      can :manage, Document
	  cannot :destroy, Document
      can :read, User
      can :manage, Task
      cannot :destroy, Task
      can :manage, Email
      cannot :destroy, Email
      cannot :manage, [Import, ImportAccount, ImportContact]
      
    elsif user.has_role? :user	
      # Role User
      can :manage, Task
      cannot :destroy, Task do |task|
        task.user_id != user.id
      end
      can :manage, Email
      can :manage, Account
	  cannot :destroy, Account
      can :manage, Contact
	  cannot :destroy, Contact
      can :read, Event
	can :update, Event, :user_id => user.id 
	can :create, Event
	can :destroy, Event, :user_id => user.id
      can :manage, Relation
      can :manage, Opportunity
      can :manage, Quotation
      can :manage, QuotationLine
      can :manage, Document
      can :read, User
      can :read, QuotationTemplate
      can :read, Tag
      can :read, Origin
      can :read, EventType
      cannot :write, QuotationTemplate
      cannot :write, Tag
      cannot :write, Origin
      cannot :write, EventType
      cannot :manage, [Import, ImportAccount, ImportContact]
      
      elsif user.has_role? :super_user
      # Role Super User
      can :manage, Task
      cannot :destroy, Task do |task|
        task.user_id != user.id
      end
      can :manage, Email
      can :manage, Account
      can :activate, Account
      can :deactivate, Account      
      can :manage, Contact
	  #cannot :destroy, Contact
      can :manage, Event
      can :manage, Relation
      can :manage, Opportunity
      can :manage, Quotation
      can :manage, QuotationLine
      can :manage, Document
      can :read, User      
      can :manage, QuotationTemplate
      can :manage, Tag
      can :manage, Origin
      can :manage, EventType
      # can   #index #show #update & #edit
      can :update, User
      # cannot  #new #create
      can :manage, [Import, ImportAccount, ImportContact]
      
    else
      # Role User by default
      can :manage, Task
      cannot :destroy, Task do |task|
        task.user_id != user.id
      end
      can :manage, Email
      can :manage, Account
	  cannot :destroy, Account
      can :manage, Contact
	  cannot :destroy, Contact
      can :read, Event
	can :update, Event, :user_id => user.id 
	can :create, Event
	can :destroy, Event, :user_id => user.id
      can :manage, Relation
      can :manage, Opportunity
      can :manage, Quotation
      can :manage, QuotationLine
      can :manage, Document
      can :read, User
      can :read, QuotationTemplate
      can :read, Tag
      can :read, Origin
      can :read, EventType
      cannot :write, QuotationTemplate
      cannot :write, Tag
      cannot :write, Origin
      cannot :write, EventType
      cannot :manage, [Import, ImportAccount, ImportContact]
    end  
  end
    
    
    
    # Define abilities for the passed in user here. For example:
    #
    #   user ||= User.new # guest user (not logged in)
    #   if user.admin?
    #     can :manage, :all
    #   else
    #     can :read, :all
    #   end
    #
    # The first argument to `can` is the action you are giving the user 
    # permission to do.
    # If you pass :manage it will apply to every action. Other common actions
    # here are :read, :create, :update and :destroy.
    #
    # The second argument is the resource the user can perform the action on. 
    # If you pass :all it will apply to every resource. Otherwise pass a Ruby
    # class of the resource.
    #
    # The third argument is an optional hash of conditions to further filter the
    # objects.
    # For example, here the user can only update published articles.
    #
    #   can :update, Article, :published => true
    #
    # See the wiki for details:
    # https://github.com/ryanb/cancan/wiki/Defining-Abilities
end
