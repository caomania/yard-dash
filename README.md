# yard-dash

This `yard` plugin will generate a `Dash` **dockset** for a *Gem* in addition to the normal `HTML` *doc* directory. 

This plugin piggybacks on the standard `HTML` generation code from `Yard` by injecting a callback that will take care of the generation. 

Just for the record the original code in `Yard` is unchanged.

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

Just run `yardoc` and the **dockset** will be created in addition to the standard HTML tree in the `doc` directory.

The **dockset** will get the same name as the *name* in the `gemspec`.


```ruby
Gem::Specification.new do |s|
  s.name = 'gemexample'
  ...
end
```

Given the above specification the **dockset** will get the name `gemexample.docset`.


