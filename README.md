# Devise::Basecamper

Devise-Basecamper was built to allow users of [Devise](https://github.com/plataformatec/devise) to implement "Basecamp" style subdomain scoped authentication with
support for multiple users.  There are a lot of [great tutorials](https://github.com/RailsApps/rails3-subdomains) out
there on doing subdomain authentication with devise, but none of them seemed to fit my particular use cases.  So I took
a stab at extending the functionality of [Devise](https://github.com/plataformatec/devise), which has been a great
Gem, and community, to work with.

### Use Case
User authentication that is scoped to an account, which is identified by the subdomain of the URL.  This allows for better
multi-tenancy, as well as for re-use of usernames under different accounts.

## Installation

Add this line to your application's Gemfile:

    gem 'devise-basecamper'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install devise-basecamper

## Usage

To make Devise-Basecamper work properly, there are several steps that need to be taken to adjust the "out-of-the-box"
behavior of Devise.  None of the changes require doing any "hacking" of Devise, as they are all steps/actions and
configuration options that are already a part of Devise itself.

### Devise Configuration
Open the Devise initializer file, which can be found in `config/initializers/devise.rb`.  Add `:subdomain` to the
`config.request_keys` array like below.

    config.request_keys = [:subdomain]

This will make sure to pass the subdomain value from the request to the appropriate Devise methods.

### Configuring models

Which ever model you would like to have subdomain based authentication scoping on, just add `:basecamper` to your
included devise modules.

```
class User
	include Mongoid::Document
	include Mongoid::Timestamps

	devise	:database_authenticatable,
		:recoverable,
		:trackable,
		:validatable,
		:basecamper
	...
end
```

By default, Devise-Basecamper assumes that your devise model "belongs to" an Account and has a field called `account_id`
as the foreign key to that table.  Devise-Basecamper also assumes that the subdomain field exists in your Account model
and is called `subdomain`.  Now that's a lot of assumptions, but never fear...they can be changed.

If you need to change any of these assumptions, you can do so by calling the `devise_basecamper` method in your devise
model.

```
class User
	include Mongoid::Document
	include Mongoid::Timestamps

	devise	:database_authenticatable,
		:recoverable,
		:trackable,
		:validatable,
		:basecamper

	devise_basecamper :subdomain_class => :my_parent_class,
			  :subdomain_field => :my_field_name,
			  :scope_field     => :field_to_scope_against

	...
end
```

The `devise_basecamper` method has 3 options that can be set: subdomain_class, subdomain_field and scope_field.

**subdomain_class**

This option allows you to specify which model your subdomains are defined in.  By default, devise_basecamper assumes this
to be an `Account` object.

**subdomain_field**

This option allows you to specify the name of the field within the `subdomain_class` that the subdomain string is stored
in.  By default, devise_basecamper assumes this to be `subdomain`.

**scope_field**

This option allows you to specify the name of the field within the devise model (e.g. - User) stores the ID of the account
you want to create a scope against.  By default, devise_basecamper assumes that this is a field called `account_id`.

If your application follows the assumptions, you DO NOT need to define any of these options.

### Configuring multiple models

You can configure multiple models accordingly just as you can in Devise.  If you have a Devise model that does not need
the additional features offered by Devise-Basecamper, simple do not include the module.  Devise will work just as expected.

### Add some helpers to your Application controller

You will need to add a helper method to your application controller, I would also recommend the validation for dealing with subdomains that do not belong
to an account.

**Helper Methods**
```
class ApplicationController < ActionController::Base
	protect_from_forgery
	helper_method :subdomain, :current_account
	before_filter :validate_subdomain, :authenticate_user!

	private # ----------------------------------------------------

	def current_acount
		# The where clause is assuming you are using Mongoid, change appropriately
		# for ActiveRecord or a different supported ORM.
		@current_account ||= Association.where(subdomain: subdomain).first
	end

	def subdomain
		request.subdomain
	end

	# This will redirect the user to your 404 page if the account can not be found
	# based on the subdomain.  You can change this to whatever best fits your
	# application.
	def validate_subdomain
		redirect_to '/404.html' if current_account.nil?
	end
end
```
### Devise Recoverable ###

Devise provides the Recoverable module to implement standard password recovery practices.  This module needs a little help working with the *basecamp style*
authentication, making sure to find the correct user account, under the correct subdomain.

To implement subdomain-based lookups using the devise Recoverable module, you will need to uncomment the `reset_password_keys` section in `devise.rb`.
This should be around line 158 in your devise.rb file.  Then update the line to look like the following:

```
# ==> Configuration for :recoverable
#
# Defines which key will be used when recovering the password for an account
config.reset_password_keys = [ :email, :subdomain ]
```
You can add whatever field name you would like here, but :subdomain is probably the best choice.

Next we will need to override the default view for the passwords controller.  Follow the directions from the
[devise readme](https://github.com/plataformatec/devise) if you don't know how to do this.  Find the proper view
equivelant in your application for `devise/passwords/new.html.erb` and add a hidden field for the subdomain value.
You will then want to default its value to the subdomain we are scoping to.  This value will then be included in the
form submit and processed properly by devise-basecamper.

Example form:
```
<h2>Forgot your password?</h2>
<%= render "flashes" %>
<%= simple_form_for resource, :as => resource_name, :url => password_path(resource_name), :html => { :method => :post } do |f| %>
	<%= hidden_field_tag 'user[subdomain]', subdomain %>
	<%= f.input :email %>
	<%= f.button :submit, "Send me reset password instructions" %>
<% end %>

<%= render "devise/shared/links" %>
```
**NOTE** Notice that the hidden field is named 'user[subdomain]'.  This is absolutely necessary to make sure that the value is passed
to the handling devise methods.  However, *user* is **NOT** the hard rule, use whatever the appropriate model name is for your application.

### ORM Compatability

Devise-Basecamper has very minimal interaction with your data layer, however it uses the same `orm_adapter` gem as Devise
and should work just fine with all of the ORM's supported by Devise.

MORE TO COME

### Contributing ###

If you would like to contribute to this project, please fork it and submit pull requests with your code changes.  I'm pretty much making updates to this as needed for my own projects right now, so it doesn't change super often and help would definately be appreciated.

## License

MIT License.  Copyright &copy; 2012 Digital Opera, LLC. [www.digitalopera.com](http://www.digitalopera.com/ "Digital Opera, LLC")
