# yard-dash

This `yard` plugin will generate a `Dash` **dockset** in addition to the normal HTML directory for a gem. The HTML code is copied from the standard yard source and is unchanged.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'yard-dash'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install yard-dash

## Usage

Just run `yardoc` and the **dockset** will be created on top off the standard HTML tree.
The name of the gem inside **dockset** will be defined by the name inside the `gemspec` file.


